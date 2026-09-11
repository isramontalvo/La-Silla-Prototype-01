extends CharacterBody2D

@export var base_speed: float = 250.0
@export var rush_speed_bonus: float = 120.0

# Clockwise from right; Godot's positive Y direction points down the screen.
const WALK_ANIMATIONS := [
	&"right", &"down_right", &"down", &"down_left",
	&"left", &"up_left", &"up", &"up_right"
]

const DEFEATED_SPRITE_SCALE := Vector2(0.1, 0.1)
const DEFEATED_SPRITE_POSITION := Vector2(0.0, 13.0)
const PURPLE_PICKUP_PULSE_SCALE := 1.08
const PURPLE_PICKUP_PUNCH_DURATION := 0.06
const PURPLE_PICKUP_SETTLE_DURATION := 0.09

var current_speed: float
var touch_active: bool = false
var target_position: Vector2
var defeated: bool = false

var rush_active: bool = false
var rush_effect_time: float = 0.0
var movement_sprite_scale: Vector2
var purple_pickup_pulse_tween: Tween

@onready var sprite: AnimatedSprite2D = $Sprite2D


func _ready() -> void:
	current_speed = base_speed
	target_position = global_position
	movement_sprite_scale = sprite.scale

	rush_active = false
	rush_effect_time = 0.0

	sprite.modulate = Color.WHITE
	sprite.animation = "down"
	sprite.stop()

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
	if direction.is_zero_approx():
		return

	var direction_index := posmod(roundi(direction.angle() / (PI / 4.0)), 8)
	var animation_name: StringName = WALK_ANIMATIONS[direction_index]

	if sprite.animation != animation_name:
		# Keep the current footfall when turning, instead of restarting the cycle.
		var frame := sprite.frame
		var progress := sprite.frame_progress
		sprite.play(animation_name)
		sprite.set_frame_and_progress(frame, progress)

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


func play_purple_pickup_pulse() -> void:
	if defeated:
		return

	if purple_pickup_pulse_tween != null and purple_pickup_pulse_tween.is_valid():
		purple_pickup_pulse_tween.kill()

	# Always restart from the recorded scene scale so repeated pickups cannot drift.
	sprite.scale = movement_sprite_scale
	purple_pickup_pulse_tween = create_tween()
	purple_pickup_pulse_tween.tween_property(
		sprite,
		"scale",
		movement_sprite_scale * PURPLE_PICKUP_PULSE_SCALE,
		PURPLE_PICKUP_PUNCH_DURATION
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	purple_pickup_pulse_tween.tween_property(
		sprite,
		"scale",
		movement_sprite_scale,
		PURPLE_PICKUP_SETTLE_DURATION
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)


func freeze_for_catch() -> void:
	if purple_pickup_pulse_tween != null and purple_pickup_pulse_tween.is_valid():
		purple_pickup_pulse_tween.kill()

	defeated = true
	touch_active = false
	velocity = Vector2.ZERO
	rush_active = false
	current_speed = base_speed
	rush_effect_time = 0.0
	sprite.modulate = Color.WHITE
	sprite.scale = movement_sprite_scale
	sprite.stop()
	z_index = 50
	queue_redraw()


func play_defeated() -> void:
	sprite.position = DEFEATED_SPRITE_POSITION
	sprite.scale = DEFEATED_SPRITE_SCALE
	sprite.play(&"defeated")
