extends Control

@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Enable continue only if at least one slot has a file
	var has_save = FileAccess.file_exists(SaveManager.get_save_path(1)) or \
				   FileAccess.file_exists(SaveManager.get_save_path(2)) or \
				   FileAccess.file_exists(SaveManager.get_save_path(3))
	
	continue_button.disabled = not has_save
	continue_button.pressed.connect(_on_continue_pressed)
	
func _on_continue_pressed() -> void:
	var target_slot = 1
	for i in [1, 2, 3]:
		if FileAccess.file_exists(SaveManager.get_save_path(i)):
			target_slot = i
			break
	GameManager.load_game(target_slot)
	SceneManager.go_to_main_game()  

func _on_play_pressed() -> void:
	SceneManager.go_to_save_selector() 

func _on_settings_pressed() -> void:
	SceneManager.open_settings_panel(self)

func _on_quit_pressed() -> void:
	get_tree().quit()
