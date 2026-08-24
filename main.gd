extends Node2D

var score: int = 0
var best_score: int = 0
var next_difficulty_score: int = 3
var first_mouse_caught: bool = false

const SAVE_PATH := "user://mouse_rush_score.cfg"

@onready var score_label: Label = $UI/ScoreLabel
@onready var best_score_label: Label = $UI/BestScoreLabel

@onready var collectible = $Collectible
@onready var enemy = $Enemy
@onready var player = $Player
@onready var game_over_ui = $GameOverUI

@onready var mouse_pickup_sound: AudioStreamPlayer = $MousePickupSound
@onready var game_over_sound: AudioStreamPlayer = $GameOverSound
@onready var speed_boost_sound: AudioStreamPlayer = $SpeedBoostSound


func _ready() -> void:
	load_best_score()

	collectible.collected.connect(_on_collectible_collected)
	enemy.player_caught.connect(_on_player_caught)

	update_score_labels()


func _on_collectible_collected(mouse_type: String) -> void:
	if not first_mouse_caught:
		first_mouse_caught = true
		enemy.start_chase()

	match mouse_type:
		"normal":
			mouse_pickup_sound.play()
			score += 1

		"purple":
			speed_boost_sound.play()
			score += 3
			player.apply_speed_boost(120.0, 4.0)

		"gold":
			speed_boost_sound.play()
			score += 10
			player.apply_speed_boost(170.0, 7.0)

	while score >= next_difficulty_score:
		enemy.increase_speed(15.0)
		next_difficulty_score += 3

	if score > best_score:
		best_score = score
		save_best_score()

	update_score_labels()


func update_score_labels() -> void:
	score_label.text = str(score)
	best_score_label.text = "BEST " + str(best_score)


func save_best_score() -> void:
	var config := ConfigFile.new()

	config.set_value("scores", "best", best_score)
	config.save(SAVE_PATH)


func load_best_score() -> void:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)

	if error == OK:
		best_score = int(config.get_value("scores", "best", 0))
	else:
		best_score = 0


func _on_player_caught() -> void:
	player.show_defeated()
	game_over_sound.play()
	game_over_ui.show_game_over(score)
