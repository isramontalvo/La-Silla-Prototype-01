extends Area2D

signal collected(mouse_type: String, catch_position: Vector2)

@export var minimum_enemy_distance: float = 180.0
@export var house_restricted_zone := Rect2(0, 0, 648, 300)

@export var wander_speed: float = 25.0
@export var wander_min_time: float = 0.6
@export var wander_max_time: float = 1.4

@onready var mouse_sprite: AnimatedSprite2D = $Sprite2D
@onready var enemy: CharacterBody2D = $"../Enemy"
@onready var player: CharacterBody2D = $"../Player"

var mouse_type: String = "normal"

var wander_direction: Vector2 = Vector2.ZERO
var wander_time: float = 0.0

var effect_time: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	move_to_random_position()
	choose_mouse_type()
	choose_new_wander_direction()

	mouse_sprite.animation = "down"
	mouse_sprite.play()


func _physics_process(delta: float) -> void:
	effect_time += delta
	queue_redraw()

	wander_time -= delta

	if wander_time <= 0.0:
		choose_new_wander_direction()

	var proposed_position := global_position + wander_direction * wander_speed * delta
	var screen_size := get_viewport_rect().size
	var margin := 50.0

	var outside_screen := (
		proposed_position.x < margin
		or proposed_position.x > screen_size.x - margin
		or proposed_position.y < margin
		or proposed_position.y > screen_size.y - margin
	)

	var blocked := (
		house_restricted_zone.has_point(proposed_position)
		or is_position_blocked(proposed_position)
	)

	if outside_screen or blocked:
		choose_new_wander_direction()
	else:
		global_position = proposed_position
		update_scurry_animation(wander_direction)


func update_scurry_animation(direction: Vector2) -> void:
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

	if mouse_sprite.animation != animation_name or not mouse_sprite.is_playing():
		mouse_sprite.play(animation_name)


func _draw() -> void:
	var pulse := (sin(effect_time * 5.0) + 1.0) * 0.5

	var glow_color: Color

	match mouse_type:
		"purple":
			glow_color = Color(0.8, 0.4, 1.0, 0.85)

		_:
			glow_color = Color(1.0, 1.0, 1.0, 0.85)

	var radius := 22.0 + pulse * 4.0

	draw_arc(
		Vector2.ZERO,
		radius,
		0.0,
		TAU,
		40,
		glow_color,
		4.0,
		true
	)


func _on_body_entered(body: Node2D) -> void:
	if body != player:
		return

	var caught_at := global_position

	collected.emit(mouse_type, caught_at)

	move_to_random_position()
	choose_mouse_type()
	choose_new_wander_direction()


func move_to_random_position() -> void:
	var screen_size := get_viewport_rect().size
	var margin := 50.0

	var new_position := Vector2(
		randf_range(margin, screen_size.x - margin),
		randf_range(margin, screen_size.y - margin)
	)

	while new_position.distance_to(enemy.global_position) < minimum_enemy_distance \
	or house_restricted_zone.has_point(new_position) \
	or is_position_blocked(new_position):
		new_position = Vector2(
			randf_range(margin, screen_size.x - margin),
			randf_range(margin, screen_size.y - margin)
		)

	position = new_position


func choose_new_wander_direction() -> void:
	wander_direction = Vector2.RIGHT.rotated(randf_range(0.0, TAU))
	wander_time = randf_range(wander_min_time, wander_max_time)

	update_scurry_animation(wander_direction)


func is_position_blocked(test_position: Vector2) -> bool:
	var query := PhysicsPointQueryParameters2D.new()

	query.position = test_position
	query.collision_mask = 1

	var hits := get_world_2d().direct_space_state.intersect_point(query, 8)

	for hit in hits:
		if hit.collider is StaticBody2D:
			return true

	return false


func choose_mouse_type() -> void:
	var roll := randf()

	effect_time = 0.0

	if roll < 0.60:
		mouse_type = "normal"
		mouse_sprite.modulate = Color.WHITE

	else:
		mouse_type = "purple"
		mouse_sprite.modulate = Color(0.75, 0.45, 1.0)
