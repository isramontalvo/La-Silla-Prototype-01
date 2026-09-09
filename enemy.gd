extends CharacterBody2D

signal player_caught

@export var speed: float = 130.0

# Clockwise from right, matching the cat's eight-direction facing.
const RUN_ANIMATIONS := [
	&"right", &"down_right", &"down", &"down_left",
	&"left", &"up_left", &"up", &"up_right"
]

var avoidance_direction: Vector2 = Vector2.ZERO
var avoidance_time: float = 0.0
var chase_active: bool = false

@onready var player: CharacterBody2D = $"../Player"
@onready var sprite: AnimatedSprite2D = $Sprite2D


func _ready() -> void:
	sprite.animation = "down"
	sprite.stop()


func _physics_process(delta: float) -> void:
	if not chase_active:
		velocity = Vector2.ZERO
		sprite.stop()
		return

	var direction := global_position.direction_to(player.global_position)

	if avoidance_time > 0.0:
		avoidance_time -= delta
		velocity = avoidance_direction * speed
	else:
		velocity = direction * speed

	update_run_animation(velocity.normalized())

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


func update_run_animation(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return

	var direction_index := posmod(roundi(direction.angle() / (PI / 4.0)), 8)
	var animation_name: StringName = RUN_ANIMATIONS[direction_index]

	if sprite.animation != animation_name:
		# Preserve the current footfall when changing direction.
		var frame := sprite.frame
		var progress := sprite.frame_progress
		sprite.play(animation_name)
		sprite.set_frame_and_progress(frame, progress)

	if not sprite.is_playing():
		sprite.play()


func start_chase() -> void:
	chase_active = true


func increase_speed(amount: float) -> void:
	speed += amount
