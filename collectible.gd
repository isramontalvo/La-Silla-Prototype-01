extends Area2D

signal collected(is_special: bool)

@export_range(0.0, 1.0) var special_chance: float = 0.20

var is_special: bool = false

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

	if is_special:
		modulate = Color(0.65, 0.25, 1.0)
	else:
		modulate = Color.WHITE
