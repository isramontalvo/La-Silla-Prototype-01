extends CharacterBody2D

signal player_caught

@export var speed: float = 130.0

var avoidance_direction: Vector2 = Vector2.ZERO
var avoidance_time: float = 0.0
var chase_active: bool = false

@onready var player: CharacterBody2D = $"../Player"


func _physics_process(delta: float) -> void:
	if not chase_active:
		velocity = Vector2.ZERO
		return

	var direction := global_position.direction_to(player.global_position)

	if avoidance_time > 0.0:
		avoidance_time -= delta
		velocity = avoidance_direction * speed
	else:
		velocity = direction * speed

	move_and_slide()

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)

		if collision.get_collider() == player:
			player_caught.emit()
			return

		var normal := collision.get_normal()

		var option_a := Vector2(-normal.y, normal.x)
		var option_b := -option_a

		if option_a.dot(direction) > option_b.dot(direction):
			avoidance_direction = option_a
		else:
			avoidance_direction = option_b

		avoidance_time = 0.45
		break


func start_chase() -> void:
	chase_active = true


func increase_speed(amount: float) -> void:
	speed += amount
