extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const COYOTE_TIME = 0.16

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ledge_controller = $LedgeController

var run_starting := false
var coyote_timer := 0.0


func _ready() -> void:
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	ledge_controller.movement_reset_requested.connect(_reset_movement_state)
	animated_sprite_2d.sprite_frames.set_animation_loop("run_start", false)
	animated_sprite_2d.play("idle")


func _physics_process(delta: float) -> void:
	# The ledge controller takes movement over while hanging or climbing.
	if ledge_controller.handle_physics(delta):
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
		animated_sprite_2d.flip_h = direction < 0.0
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	move_and_slide()
	if ledge_controller.try_grab(direction):
		return
	update_animation(direction)


func _reset_movement_state() -> void:
	run_starting = false
	coyote_timer = 0.0


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
	if ledge_controller.is_active():
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
