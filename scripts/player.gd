extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const COYOTE_TIME = 0.12

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var run_starting := false
var coyote_timer := 0.0


func _ready() -> void:
	animated_sprite_2d.animation_finished.connect(
		_on_animation_finished
	)

	# Koşuya geçiş yalnızca bir kez oynasın.
	animated_sprite_2d.sprite_frames.set_animation_loop(
		"run_start", false
	)

	animated_sprite_2d.play("idle")


func _physics_process(delta: float) -> void:
	# Yerdeyken zıplama süresini hazır tut.
	# Kenardan ayrılınca geri saymaya başla.
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)
		velocity += get_gravity() * delta

	# Yerdeyken veya coyote time sürerken zıpla.
	if Input.is_action_just_pressed("jump") and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0

	var direction := Input.get_axis("move_left", "move_right")

	# Karakterin baktığı yön.
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

	# Yatay hareket.
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Güncel zemin durumuna göre animasyonu seç.
	update_animation(direction)


func update_animation(direction: float) -> void:
	if not is_on_floor():
		run_starting = false
		animated_sprite_2d.play("jump")
		return

	if is_zero_approx(direction):
		run_starting = false
		animated_sprite_2d.play("idle")
		return

	# Geçiş bitene kadar run ile üzerine yazma.
	if run_starting:
		return

	if animated_sprite_2d.animation == &"run":
		return

	run_starting = true
	animated_sprite_2d.play("run_start")
	animated_sprite_2d.set_frame_and_progress(0, 0.0)


func _on_animation_finished() -> void:
	if animated_sprite_2d.animation != &"run_start":
		return

	if not run_starting:
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

		# Geçişin son pozu, koşunun ilk karesiyle aynı.
		animated_sprite_2d.set_frame_and_progress(1, 0.0)
