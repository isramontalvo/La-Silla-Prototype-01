extends Node2D

var score: int = 0
var next_difficulty_score: int = 3
var gate_unlocked: bool = false

@onready var score_label: Label = $UI/ScoreLabel
@onready var collectible = $Collectible
@onready var enemy = $Enemy
@onready var player = $Player
@onready var game_over_ui = $GameOverUI

@onready var mouse_pickup_sound: AudioStreamPlayer = $MousePickupSound
@onready var game_over_sound: AudioStreamPlayer = $GameOverSound
@onready var speed_boost_sound: AudioStreamPlayer = $SpeedBoostSound

@onready var gate_collision: CollisionShape2D = $GateObstacle/CollisionShape2D

@onready var win_area: Area2D = $WinArea


func _ready() -> void:
	win_area.body_entered.connect(_on_win_area_body_entered)
	collectible.collected.connect(_on_collectible_collected)
	enemy.player_caught.connect(_on_player_caught)
	
	update_score_label()


func _on_collectible_collected(is_special: bool) -> void:
	if is_special:
		speed_boost_sound.play()
		score += 3
		player.apply_speed_boost(120.0, 4.0)
	else:
		mouse_pickup_sound.play()
		score += 1

	while score >= next_difficulty_score:
		enemy.increase_speed(15.0)
		next_difficulty_score += 3

	check_gate_unlock()
	update_score_label()


func check_gate_unlock() -> void:
	if score >= 30 and not gate_unlocked:
		gate_unlocked = true
		gate_collision.set_deferred("disabled", true)


func update_score_label() -> void:
	score_label.text = str(score)


func _on_player_caught() -> void:
	game_over_sound.play()
	game_over_ui.show_game_over(score)
	
func _on_win_area_body_entered(body: Node2D) -> void:
	if body == player and gate_unlocked:
		get_tree().paused = true
		print("YOU WIN")	
