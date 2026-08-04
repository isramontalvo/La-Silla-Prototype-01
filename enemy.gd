extends Area2D
signal player_caught
@export var speed: float = 100.0

@onready var player: CharacterBody2D = $"../Player"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var direction := global_position.direction_to(player.global_position)
	global_position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player_caught.emit()

func increase_speed(amount: float) -> void:
	speed += amount
