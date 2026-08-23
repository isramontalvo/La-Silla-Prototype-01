extends CanvasLayer


@onready var start_button: Button = $Background/StartButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	start_button.pressed.connect(_on_start_button_pressed)
	start_button.grab_focus()


func _on_start_button_pressed() -> void:
	get_tree().paused = false
	hide()
