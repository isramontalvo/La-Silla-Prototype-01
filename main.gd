extends Node2D

var score: int = 0
var next_difficulty_score: int = 3

@onready var score_label: Label = $UI/ScoreLabel
@onready var collectible = $Collectible
@onready var enemy = $Enemy
@onready var player = $Player
@onready var game_over_ui = $GameOverUI

func _ready() -> void:
	collectible.collected.connect(_on_collectible_collected)
	enemy.player_caught.connect(_on_player_caught)
	update_score_label()

func _on_collectible_collected(is_special: bool) -> void:
	if is_special:
		score += 3
		player.apply_speed_boost(120.0, 4.0)
	else:
		score += 1

	while score >= next_difficulty_score:
		enemy.increase_speed(15.0)
		next_difficulty_score += 3

	update_score_label()

func update_score_label() -> void:
	score_label.text = "Score: " + str(score)
	
func _on_player_caught() -> void:
	game_over_ui.show_game_over(score)
