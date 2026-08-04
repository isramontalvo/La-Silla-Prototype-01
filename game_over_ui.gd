extends CanvasLayer


@onready var overlay: ColorRect = $Overlay
@onready var final_score_label: Label = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/FinalScoreLabel
@onready var restart_button: Button = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RestartButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.hide()
	restart_button.pressed.connect(_on_restart_button_pressed)
func show_game_over(final_score: int) -> void:
	final_score_label.text = "🐭 %d" % final_score
	overlay.show()
	get_tree().paused = true
	restart_button.grab_focus()





func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
