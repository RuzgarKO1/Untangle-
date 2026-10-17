extends Camera2D

const DEAD_ZONE = 200.0
const CAMERA_STRENGTH = 0.5

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var viewport_center = get_viewport_rect().size * 0.5
		var target = event.position - viewport_center

		if target.length() < DEAD_ZONE:
			position = Vector2.ZERO
		else:
			position = target.normalized() * \
				(target.length() - DEAD_ZONE) * CAMERA_STRENGTH
