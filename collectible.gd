extends Area2D

signal collected(is_special: bool)

@export_range(0.0, 1.0) var special_chance: float = 0.20
@export var minimum_enemy_distance: float = 180.0
@export var house_restricted_zone := Rect2(0, 0, 648, 300)

@export var mouse_sprite: Sprite2D
@onready var enemy: CharacterBody2D = $"../Enemy"

var is_special: bool = false

const NORMAL_MOUSE_RECT := Rect2(500, 80, 500, 400)
const PURPLE_MOUSE_RECT := Rect2(0, 500, 500, 500)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	move_to_random_position()
	choose_collectible_type()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		collected.emit(is_special)
		move_to_random_position()
		choose_collectible_type()

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

func choose_collectible_type() -> void:
	is_special = randf() < special_chance
	mouse_sprite.region_enabled = true

	if is_special:
		mouse_sprite.region_rect = PURPLE_MOUSE_RECT
	else:
		mouse_sprite.region_rect = NORMAL_MOUSE_RECT
		
func is_position_blocked(test_position: Vector2) -> bool:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = test_position
	query.collision_mask = 1

	var hits := get_world_2d().direct_space_state.intersect_point(query, 8)

	for hit in hits:
		if hit.collider is StaticBody2D:
			return true

	return false		
