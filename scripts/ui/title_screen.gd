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
	var has_save = SaveManager.has_save(1) \
	or SaveManager.has_save(2) \
	or SaveManager.has_save(3)
	
	continue_button.disabled = not has_save
	continue_button.pressed.connect(_on_continue_pressed)
	
func _on_continue_pressed() -> void:
	var target_slot := -1
	var latest_modified_time := 0

	for slot_index in [1, 2, 3]:
		if not SaveManager.has_save(slot_index):
			continue

		var modified_time := FileAccess.get_modified_time(
			SaveManager.get_save_path(slot_index)
		)
		if modified_time > latest_modified_time:
			latest_modified_time = modified_time
			target_slot = slot_index

	if target_slot != -1:
		GameManager.load_game(target_slot)
		SceneManager.go_to_main_game()

func _on_play_pressed() -> void:
	SceneManager.go_to_save_selector() 

func _on_settings_pressed() -> void:
	SceneManager.open_settings_panel(self)

func _on_quit_pressed() -> void:
	get_tree().quit()
