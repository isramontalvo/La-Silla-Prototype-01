extends CanvasLayer

@onready var overlay: ColorRect = $Overlay
@onready var panel: PanelContainer = $Overlay/CenterContainer/PanelContainer
@onready var game_over_label: Label = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GameOverLabel
@onready var final_score_label: Label = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/FinalScoreLabel
@onready var restart_button: Button = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RestartButton

var game_over_active: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	overlay.hide()
	restart_button.hide()

	var strip := StyleBoxFlat.new()
	strip.bg_color = Color(0.0, 0.0, 0.0, 0.22)
	strip.corner_radius_top_left = 0
	strip.corner_radius_top_right = 0
	strip.corner_radius_bottom_left = 0
	strip.corner_radius_bottom_right = 0
	panel.add_theme_stylebox_override("panel", strip)

	game_over_label.text = "BUSTED!"
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.add_theme_font_size_override("font_size", 56)
	game_over_label.add_theme_color_override("font_color", Color(0.92, 0.08, 0.08, 1.0))
	game_over_label.add_theme_color_override("font_outline_color", Color(0.1, 0.0, 0.0, 0.9))
	game_over_label.add_theme_constant_override("outline_size", 4)

	final_score_label.text = "tap to retry"
	final_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	final_score_label.add_theme_font_size_override("font_size", 18)
	final_score_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.45))
	final_score_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.35))
	final_score_label.add_theme_constant_override("outline_size", 1)
	final_score_label.show()


func show_game_over(_final_score: int) -> void:
	game_over_active = true

	overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	overlay.show()

	get_tree().paused = true


func _input(event: InputEvent) -> void:
	if not game_over_active:
		return

	if event is InputEventScreenTouch and event.pressed:
		restart_game()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		restart_game()


func restart_game() -> void:
	game_over_active = false
	get_tree().paused = false
	get_tree().reload_current_scene()
