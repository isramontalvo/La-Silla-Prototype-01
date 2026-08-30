extends Node2D

var score: int = 0
var best_score: int = 0
var run_start_best_score: int = 0
var new_best_announced: bool = false

var first_mouse_caught: bool = false

var rush_time_left: float = 0.0

const RUSH_ADD_TIME := 4.0
const RUSH_MAX_TIME := 10.0

const SAVE_PATH := "user://mouse_rush_score.cfg"

@onready var score_label: Label = $UI/ScoreLabel
@onready var best_score_label: Label = $UI/BestScoreLabel
@onready var rush_label: Label = $UI/RushLabel
@onready var rush_bar: ProgressBar = $UI/RushBar
@onready var ui = $UI

@onready var collectible = $Collectible
@onready var enemy = $Enemy
@onready var player = $Player
@onready var game_over_ui = $GameOverUI

@onready var mouse_pickup_sound: AudioStreamPlayer = $MousePickupSound
@onready var game_over_sound: AudioStreamPlayer = $GameOverSound
@onready var speed_boost_sound: AudioStreamPlayer = $SpeedBoostSound

@onready var calm_music: AudioStreamPlayer = $CalmMusic
@onready var rush_music: AudioStreamPlayer = $RushMusic

var grandpa_speed_timer: Timer


func _ready() -> void:
	load_best_score()
	run_start_best_score = best_score

	collectible.collected.connect(_on_collectible_collected)
	enemy.player_caught.connect(_on_player_caught)

	setup_grandpa_speed_timer()
	setup_rush_ui()
	update_score_labels()

	if calm_music.stream != null:
		calm_music.pitch_scale = 1.0
		calm_music.play()


func _process(delta: float) -> void:
	update_rush_timer(delta)


func setup_grandpa_speed_timer() -> void:
	grandpa_speed_timer = Timer.new()
	grandpa_speed_timer.wait_time = 5.0
	grandpa_speed_timer.one_shot = false

	add_child(grandpa_speed_timer)

	grandpa_speed_timer.timeout.connect(_on_grandpa_speed_timer_timeout)


func setup_rush_ui() -> void:
	rush_time_left = 0.0

	rush_label.text = "RUSH"

	rush_bar.min_value = 0.0
	rush_bar.max_value = RUSH_MAX_TIME
	rush_bar.value = 0.0
	rush_bar.show_percentage = false


func _on_collectible_collected(
	mouse_type: String,
	catch_position: Vector2
) -> void:

	if not first_mouse_caught:
		first_mouse_caught = true

		enemy.start_chase()
		grandpa_speed_timer.start()

		start_rush_music()
		show_rush_cue()

	match mouse_type:
		"normal":
			mouse_pickup_sound.play()

		"purple":
			speed_boost_sound.pitch_scale = 1.0
			speed_boost_sound.play()

			add_rush_time()

	score += 1

	var popup_color := get_mouse_popup_color(mouse_type)

	show_floating_points(
		1,
		catch_position,
		popup_color
	)

	pop_score_label()

	if score > best_score:
		best_score = score
		save_best_score()

	if not new_best_announced \
	and run_start_best_score > 0 \
	and score > run_start_best_score:

		new_best_announced = true
		show_new_best()

	update_score_labels()


func add_rush_time() -> void:
	rush_time_left = min(
		rush_time_left + RUSH_ADD_TIME,
		RUSH_MAX_TIME
	)

	player.set_rush_active(true)

	rush_bar.value = rush_time_left


func update_rush_timer(delta: float) -> void:
	if rush_time_left <= 0.0:
		return

	rush_time_left -= delta

	rush_time_left = max(
		rush_time_left,
		0.0
	)

	rush_bar.value = rush_time_left

	if rush_time_left <= 0.0:
		player.set_rush_active(false)


func get_mouse_popup_color(mouse_type: String) -> Color:
	if mouse_type == "purple":
		return Color(0.8, 0.4, 1.0)

	return Color.WHITE


func _on_grandpa_speed_timer_timeout() -> void:
	enemy.increase_speed(15.0)


func start_rush_music() -> void:
	if calm_music.playing:
		calm_music.stop()

	if rush_music.stream != null:
		rush_music.pitch_scale = 1.30
		rush_music.play()


func show_rush_cue() -> void:
	var label := Label.new()

	label.text = "RUSH!"
	label.position = Vector2(174.0, 480.0)
	label.size = Vector2(300.0, 90.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.z_index = 120

	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override(
		"font_color",
		Color(1.0, 0.82, 0.15)
	)
	label.add_theme_color_override(
		"font_outline_color",
		Color.BLACK
	)
	label.add_theme_constant_override("outline_size", 5)

	ui.add_child(label)

	var tween := create_tween()

	tween.tween_property(
		label,
		"scale",
		Vector2(1.15, 1.15),
		0.12
	)

	tween.tween_interval(0.25)

	tween.tween_property(
		label,
		"modulate:a",
		0.0,
		0.35
	)

	tween.tween_callback(label.queue_free)


func show_floating_points(
	points: int,
	catch_position: Vector2,
	popup_color: Color
) -> void:

	var label := Label.new()

	label.text = "+" + str(points)
	label.position = catch_position - Vector2(24.0, 20.0)
	label.z_index = 100

	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", popup_color)
	label.add_theme_color_override(
		"font_outline_color",
		Color.BLACK
	)
	label.add_theme_constant_override("outline_size", 3)

	ui.add_child(label)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		label,
		"position",
		label.position + Vector2(0.0, -45.0),
		0.7
	)

	tween.tween_property(
		label,
		"modulate:a",
		0.0,
		0.7
	)

	tween.chain().tween_callback(label.queue_free)


func pop_score_label() -> void:
	var original_scale := score_label.scale
	var tween := create_tween()

	tween.tween_property(
		score_label,
		"scale",
		original_scale * 1.20,
		0.08
	)

	tween.tween_property(
		score_label,
		"scale",
		original_scale,
		0.12
	)


func show_new_best() -> void:
	var label := Label.new()

	label.text = "NEW BEST!"
	label.position = Vector2(185.0, 210.0)
	label.size = Vector2(280.0, 60.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.z_index = 100

	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override(
		"font_color",
		Color(1.0, 0.85, 0.2)
	)
	label.add_theme_color_override(
		"font_outline_color",
		Color.BLACK
	)
	label.add_theme_constant_override("outline_size", 4)

	ui.add_child(label)

	var tween := create_tween()

	tween.tween_interval(1.0)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(label.queue_free)


func update_score_labels() -> void:
	score_label.text = str(score)
	best_score_label.text = "BEST " + str(best_score)


func save_best_score() -> void:
	var config := ConfigFile.new()

	config.set_value(
		"scores",
		"best",
		best_score
	)

	config.save(SAVE_PATH)


func load_best_score() -> void:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)

	if error == OK:
		best_score = int(
			config.get_value(
				"scores",
				"best",
				0
			)
		)
	else:
		best_score = 0


func _on_player_caught() -> void:
	if grandpa_speed_timer != null:
		grandpa_speed_timer.stop()

	player.show_defeated()

	game_over_sound.play()

	game_over_ui.show_game_over(score)
