extends Area2D

signal collected(is_special: bool)

@export_range(0.0, 1.0) var special_chance: float = 0.20

@export var mouse_sprite: Sprite2D

var is_special: bool = false

const NORMAL_MOUSE_RECT := Rect2(500, 80, 500, 400)
const PURPLE_MOUSE_RECT := Rect2(0, 500, 500, 500)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	choose_collectible_type()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		collected.emit(is_special)
		move_to_random_position()
		choose_collectible_type()

func move_to_random_position() -> void:
	var screen_size := get_viewport_rect().size
	var margin := 50.0

	position = Vector2(
		randf_range(margin, screen_size.x - margin),
		randf_range(margin, screen_size.y - margin)
	)

func choose_collectible_type() -> void:
	is_special = randf() < special_chance
	mouse_sprite.region_enabled = true

	if is_special:
		mouse_sprite.region_rect = PURPLE_MOUSE_RECT
	else:
		mouse_sprite.region_rect = NORMAL_MOUSE_RECT
