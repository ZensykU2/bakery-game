extends CanvasLayer

@onready var resume_button: Button = $CenterContainer/VBoxContainer/ResumeButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var title_button: Button = $CenterContainer/VBoxContainer/TitleScreenButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:
	# Ensure the pause menu processes inputs when the tree is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	resume_button.pressed.connect(_on_resume)
	settings_button.pressed.connect(_on_settings)
	title_button.pressed.connect(_on_title_screen)
	quit_button.pressed.connect(_on_quit)

func _unhandled_input(event: InputEvent) -> void:
	# Pressing Escape again while paused will resume the game
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_ESCAPE):
		_on_resume()
		get_viewport().set_input_as_handled()

func _on_resume() -> void:
	get_tree().paused = false
	queue_free()

func _on_settings() -> void:
	SceneManager.open_settings_panel(self, true)

func _on_title_screen() -> void:
	get_tree().paused = false
	GameManager.save_game()
	Hud.visible = false
	SceneManager.go_to_title_screen()
	queue_free()

func _on_quit() -> void:
	GameManager.save_game()
	get_tree().quit()
