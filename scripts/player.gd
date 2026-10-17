extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const COYOTE_TIME = 0.16
const REGRAB_DELAY = 0.25

# A tiny vertical-speed tolerance counts as the jump apex, not normal ascent.
const APEX_GRAB_TOLERANCE = 20.0

# These coordinates match the supplied 128x128 ledge animations.
const HANG_CENTER = Vector2(-16.0, 15.0)
const STAND_CENTER = Vector2(14.0, -29.2)

enum Mode { NORMAL, CATCH, HANG, CLIMB }

@export_flags_2d_physics var ledge_mask: int = 1
@export var ledge_reach: float = 36.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ledge_sprite: AnimatedSprite2D = $LedgeSprite
@onready var body_shape: CollisionShape2D = $CollisionShape2D

var run_starting := false
var coyote_timer := 0.0
var mode: Mode = Mode.NORMAL
var facing := 1.0
var ledge_corner := Vector2.ZERO
var hang_center := Vector2.ZERO
var upper_center := Vector2.ZERO
var stand_center := Vector2.ZERO
var regrab_timer := 0.0
var ledge_animation_done := false
var climb_requested := false


func _ready() -> void:
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	ledge_sprite.animation_finished.connect(_on_ledge_animation_finished)
	# FPS values are controlled only in the SpriteFrames editor.
	animated_sprite_2d.sprite_frames.set_animation_loop("run_start", false)
	ledge_sprite.sprite_frames.set_animation_loop("ledge_catch", false)
	ledge_sprite.sprite_frames.set_animation_loop("ledge_hang", true)
	ledge_sprite.sprite_frames.set_animation_loop("ledge_climb", false)
	ledge_sprite.centered = true
	ledge_sprite.hide()
	animated_sprite_2d.play("idle")


func _physics_process(delta: float) -> void:
	regrab_timer = maxf(regrab_timer - delta, 0.0)

	if mode != Mode.NORMAL:
		_update_ledge()
		return

	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0

	var direction := Input.get_axis("move_left", "move_right")
	if not is_zero_approx(direction):
		facing = signf(direction)
		animated_sprite_2d.flip_h = facing < 0.0

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	move_and_slide()

	var can_grab := (
		not is_on_floor()
		and velocity.y >= -APEX_GRAB_TOLERANCE
		and not Input.is_action_pressed("move_down")
		and not is_zero_approx(direction)
		and regrab_timer <= 0.0
	)
	if can_grab and _try_grab_ledge():
		return

	update_animation(direction)


func _ray(from: Vector2, to: Vector2) -> Dictionary:
	var query := PhysicsRayQueryParameters2D.create(from, to, ledge_mask)
	query.exclude = [get_rid()]
	query.collide_with_areas = false
	return get_world_2d().direct_space_state.intersect_ray(query)


func _shape_clear_at(root_position: Vector2) -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = body_shape.shape
	var shape_transform := body_shape.global_transform
	shape_transform.origin += root_position - global_position
	query.transform = shape_transform
	query.collision_mask = collision_mask
	query.exclude = [get_rid()]
	query.collide_with_areas = false
	query.margin = 0.02
	return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


func _path_clear(from: Vector2, to: Vector2) -> bool:
	var start_transform := global_transform
	start_transform.origin = from
	return not test_move(start_transform, to - from)


func _try_grab_ledge() -> bool:
	# Scan the hand-height band instead of looking below thin platforms.
	# Called only near the jump apex or while falling; clearance still applies.
	var wall: Dictionary = {}
	var probe_heights: Array[float] = [0.0]
	for step in range(1, 16):
		probe_heights.append(-2.0 * step)
	probe_heights.append_array([2.0, 4.0, 6.0, 8.0])
	for height in probe_heights:
		var origin := global_position + Vector2(0.0, height)
		var result := _ray(origin, origin + Vector2(facing * ledge_reach, 0.0))
		if result.is_empty():
			continue
		var normal: Vector2 = result["normal"]
		if normal.dot(Vector2(-facing, 0.0)) >= 0.95:
			wall = result
			break
	if wall.is_empty():
		return false

	var wall_point: Vector2 = wall["position"]
	var inside_x := wall_point.x + facing * 3.0
	var top := _ray(
		Vector2(inside_x, global_position.y - 40.0),
		Vector2(inside_x, wall_point.y + 1.0)
	)
	if top.is_empty():
		return false
	var top_normal: Vector2 = top["normal"]
	if top_normal.dot(Vector2.UP) < 0.95:
		return false
	var top_point: Vector2 = top["position"]
	var candidate := Vector2(wall_point.x, top_point.y)
	var hand_height := global_position.y - candidate.y
	if hand_height < -4.0 or hand_height > 30.0:
		return false

	# A continuing wall above the candidate means this is not an open edge.
	var above := Vector2(global_position.x, candidate.y - 2.0)
	if not _ray(above, Vector2(inside_x, above.y)).is_empty():
		return false

	var desired_hang := candidate + Vector2(HANG_CENTER.x * facing, HANG_CENTER.y)
	# Fit the real collision shape, including its local position.
	var collider_bottom := body_shape.position.y + body_shape.shape.get_rect().end.y
	var desired_stand := candidate + Vector2(STAND_CENTER.x * facing, -collider_bottom - 0.2)
	var desired_upper := Vector2(desired_hang.x, desired_stand.y)

	# Require support, standing room and a collision-free route above the lip.
	if not _has_support(candidate, facing):
		return false
	var positions: Array[Vector2] = [desired_hang, desired_upper, desired_stand]
	for i in range(positions.size()):
		if not _shape_clear_at(positions[i]):
			return false
	if not _path_clear(global_position, desired_hang):
		return false
	if not _path_clear(desired_hang, desired_upper):
		return false
	if not _path_clear(desired_upper, desired_stand):
		return false

	# Snap only across the checked short reach; keep collision enabled.
	var hit := move_and_collide(desired_hang - global_position)
	if hit != null:
		return false

	ledge_corner = candidate
	hang_center = desired_hang
	upper_center = desired_upper
	stand_center = desired_stand
	velocity = Vector2.ZERO
	coyote_timer = 0.0
	run_starting = false
	climb_requested = false
	mode = Mode.CATCH
	animated_sprite_2d.hide()
	ledge_sprite.show()
	ledge_sprite.flip_h = facing < 0.0
	ledge_sprite.offset = Vector2(-12.0 * facing, 0.0)
	_pin_ledge_visual()
	_play_ledge("ledge_catch")
	return true


func _has_support(corner: Vector2, side: float) -> bool:
	# Sprite mirroring does not mirror CollisionShape2D's local X offset.
	var bounds := body_shape.shape.get_rect()
	var center_x := STAND_CENTER.x * side + body_shape.position.x
	var left_x := center_x + bounds.position.x + 0.5
	var right_x := center_x + bounds.end.x - 0.5
	for x_offset in [left_x, right_x]:
		var p := corner + Vector2(x_offset, -1.0)
		var hit := _ray(p, p + Vector2(0.0, 5.0))
		if hit.is_empty():
			return false
		var normal: Vector2 = hit["normal"]
		if normal.dot(Vector2.UP) < 0.95:
			return false
	return true


func _play_ledge(animation_name: StringName) -> void:
	ledge_animation_done = false
	ledge_sprite.play(animation_name)
	ledge_sprite.set_frame_and_progress(0, 0.0)


func _pin_ledge_visual() -> void:
	# The animation already contains the body's visual movement around the corner.
	ledge_sprite.global_position = ledge_corner


func _update_ledge() -> void:
	velocity = Vector2.ZERO

	if mode != Mode.CLIMB:
		if Input.is_action_just_pressed("move_down"):
			_leave_ledge(true)
			return
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("move_up"):
			climb_requested = true

	if mode == Mode.CATCH and ledge_animation_done:
		mode = Mode.HANG
		_play_ledge("ledge_hang")

	if mode == Mode.HANG and climb_requested:
		climb_requested = false
		if _shape_clear_at(upper_center) and _shape_clear_at(stand_center):
			if _path_clear(global_position, upper_center) and _path_clear(upper_center, stand_center):
				if _has_support(ledge_corner, facing):
					mode = Mode.CLIMB
					_play_ledge("ledge_climb")

	if mode == Mode.CLIMB:
		var count := ledge_sprite.sprite_frames.get_frame_count("ledge_climb")
		var progress := (float(ledge_sprite.frame) + ledge_sprite.frame_progress) / float(count)
		if ledge_animation_done:
			progress = 1.0

		# Physical movement goes UP first, then ACROSS, avoiding the solid corner.
		# Progress follows the actual animation, so changing editor FPS stays in sync.
		var raised := hang_center.lerp(upper_center, minf(progress / 0.65, 1.0))
		if _move_climb_body(Vector2(global_position.x, raised.y)):
			return
		if progress > 0.65:
			var across := upper_center.lerp(stand_center, (progress - 0.65) / 0.35)
			if _move_climb_body(across):
				return

		if ledge_animation_done:
			_leave_ledge(false)
			return

	_pin_ledge_visual()


func _move_climb_body(target: Vector2) -> bool:
	var motion := target - global_position
	if motion.length_squared() < 0.000001:
		return false
	if move_and_collide(motion) != null:
		_leave_ledge(true)
		return true
	return false


func _leave_ledge(dropping: bool) -> void:
	mode = Mode.NORMAL
	ledge_sprite.stop()
	ledge_sprite.hide()
	animated_sprite_2d.show()
	animated_sprite_2d.flip_h = facing < 0.0
	regrab_timer = REGRAB_DELAY
	coyote_timer = 0.0
	run_starting = false
	climb_requested = false
	velocity = Vector2(0.0, 30.0 if dropping else 0.0)
	animated_sprite_2d.play("jump" if dropping else "idle")


func update_animation(direction: float) -> void:
	if not is_on_floor():
		run_starting = false
		animated_sprite_2d.play("jump")
		return
	if is_zero_approx(direction):
		run_starting = false
		animated_sprite_2d.play("idle")
		return
	if run_starting or animated_sprite_2d.animation == &"run":
		return
	run_starting = true
	animated_sprite_2d.play("run_start")
	animated_sprite_2d.set_frame_and_progress(0, 0.0)


func _on_animation_finished() -> void:
	if mode != Mode.NORMAL:
		return
	if animated_sprite_2d.animation != &"run_start" or not run_starting:
		return
	run_starting = false
	if not is_on_floor():
		animated_sprite_2d.play("jump")
		return
	var direction := Input.get_axis("move_left", "move_right")
	if is_zero_approx(direction):
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("run")
		animated_sprite_2d.set_frame_and_progress(1, 0.0)


func _on_ledge_animation_finished() -> void:
	# Movement queries run in _physics_process, never in this signal callback.
	ledge_animation_done = true
