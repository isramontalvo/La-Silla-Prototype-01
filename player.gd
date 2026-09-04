extends CharacterBody2D

@export var base_speed: float = 250.0
@export var rush_speed_bonus: float = 120.0

var current_speed: float
var touch_active: bool = false
var target_position: Vector2
var defeated: bool = false

var rush_active: bool = false
var rush_effect_time: float = 0.0

@onready var boost_timer: Timer = $BoostTimer
@onready var sprite: AnimatedSprite2D = $Sprite2D


func _ready() -> void:
	current_speed = base_speed
	target_position = global_position

	rush_active = false
	rush_effect_time = 0.0

	sprite.modulate = Color.WHITE
	sprite.animation = "down"
	sprite.stop()

	boost_timer.stop()

	queue_redraw()


func _input(event: InputEvent) -> void:
	if defeated:
		return

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


func _physics_process(delta: float) -> void:
	if defeated:
		velocity = Vector2.ZERO
		sprite.stop()
		return

	if rush_active:
		rush_effect_time += delta
		queue_redraw()

	if touch_active:
		var distance_to_target := global_position.distance_to(target_position)

		if distance_to_target > 16.0:
			var direction := global_position.direction_to(target_position)

			velocity = direction * current_speed

			update_walk_animation(direction)
		else:
			velocity = Vector2.ZERO
			sprite.stop()
	else:
		velocity = Vector2.ZERO
		sprite.stop()

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


func update_walk_animation(direction: Vector2) -> void:
	var animation_name: String

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0.0:
			animation_name = "right"
		else:
			animation_name = "left"
	else:
		if direction.y > 0.0:
			animation_name = "down"
		else:
			animation_name = "up"

	if sprite.animation != animation_name:
		sprite.animation = animation_name

	if not sprite.is_playing():
		sprite.play()


func _draw() -> void:
	if not rush_active:
		return

	var pulse := (sin(rush_effect_time * 8.0) + 1.0) * 0.5
	var radius := 34.0 + pulse * 5.0

	draw_arc(
		Vector2.ZERO,
		radius,
		0.0,
		TAU,
		48,
		Color(0.8, 0.4, 1.0, 0.9),
		4.0,
		true
	)


func set_rush_active(active: bool) -> void:
	if defeated:
		return

	rush_active = active

	if rush_active:
		current_speed = base_speed + rush_speed_bonus
		rush_effect_time = 0.0
		sprite.modulate = Color(0.75, 0.45, 1.0)
	else:
		current_speed = base_speed
		rush_effect_time = 0.0
		sprite.modulate = Color.WHITE

	queue_redraw()


func show_defeated() -> void:
	defeated = true
	touch_active = false
	velocity = Vector2.ZERO
	sprite.stop()
	z_index = 50


func _on_boost_timer_timeout() -> void:
	pass
