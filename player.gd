extends CharacterBody2D

@export var base_speed: float = 250.0

var current_speed: float

@onready var boost_timer: Timer = $BoostTimer
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	current_speed = base_speed
	boost_timer.timeout.connect(_on_boost_timer_timeout)

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction * current_speed
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
