extends CharacterBody2D

@export var speed: float = 250.0

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction * speed
	move_and_slide()

	var screen_size := get_viewport_rect().size
	var margin := 20.0

	global_position.x = clampf(
		global_position.x,
		margin,
		screen_size.x - margin
	)

	global_position.y = clampf(
		global_position.y,
		margin,
		screen_size.y - margin
	)
