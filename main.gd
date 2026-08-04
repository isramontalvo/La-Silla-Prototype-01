extends Node2D

var score: int = 0

@onready var score_label: Label = $UI/ScoreLabel
@onready var collectible: Area2D = $Collectible
@onready var enemy = $Enemy

func _ready() -> void:
	collectible.collected.connect(_on_collectible_collected)
	update_score_label()

func _on_collectible_collected() -> void:
	score += 1

	if score % 3 == 0:
		enemy.increase_speed(15.0)

	update_score_label()

func update_score_label() -> void:
	score_label.text = "Score: " + str(score)
