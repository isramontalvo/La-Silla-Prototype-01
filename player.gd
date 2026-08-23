extends CharacterBody2D

@export var base_speed: float = 250.0

var current_speed: float
var touch_active: bool = false
var target_position: Vector2

@onready var boost_timer: Timer = $BoostTimer
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	current_speed = base_speed
	target_position = global_position
	boost_timer.timeout.connect(_on_boost_timer_timeout)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		touch_active = event.pressed
		target_position = event.position

	elif event is InputEventScreenDrag:
		touch_active = true
		target_position = event.position

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		touch_active = event.pressed
		target_position = event.position

	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		target_position = event.position


func _physics_process(_delta: float) -> void:
	if touch_active:
		var distance_to_target := global_position.distance_to(target_position)

		if distance_to_target > 8.0:
			var direction := global_position.direction_to(target_position)
			velocity = direction * current_speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO

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


func apply_speed_boost(amount: float = 120.0, duration: float = 4.0) -> void:
	current_speed = base_speed + amount
	sprite.modulate = Color(0.75, 0.45, 1.0)
	boost_timer.start(duration)


func _on_boost_timer_timeout() -> void:
	current_speed = base_speed
	sprite.modulate = Color.WHITE
