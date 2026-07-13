extends Control

@onready var slot_1_btn: Button = $CenterContainer/VBoxContainer/Slot1Button
@onready var slot_2_btn: Button = $CenterContainer/VBoxContainer/Slot2Button
@onready var slot_3_btn: Button = $CenterContainer/VBoxContainer/Slot3Button
@onready var back_btn: Button = $CenterContainer/VBoxContainer/BackButton

func _ready() -> void:
	back_btn.pressed.connect(func(): SceneManager.go_to_title_screen())
	
	_setup_slot_button(1, slot_1_btn)
	_setup_slot_button(2, slot_2_btn)
	_setup_slot_button(3, slot_3_btn)

func _on_slot_selected(slot_index: int, is_empty: bool) -> void:
	if is_empty:
		GameManager.new_game(slot_index)
		SceneManager.go_to_main_game()
	else:
		var dialog := ConfirmationDialog.new()
		dialog.title = "Load Save"
		dialog.dialog_text = "Would you like to load this slot, or overwrite it with a new game?"
		dialog.ok_button_text = "Load"
		
		var overwrite_btn = dialog.add_button("Overwrite", true, "overwrite")
		
		dialog.confirmed.connect(func():
			GameManager.load_game(slot_index)
			SceneManager.go_to_main_game()
			dialog.queue_free()
		)
		
		dialog.custom_action.connect(func(action):
			if action == "overwrite":
				GameManager.new_game(slot_index)
				SceneManager.go_to_main_game()
				dialog.queue_free()
		)
		
		add_child(dialog)
		dialog.popup_centered()
	
func _setup_slot_button(slot_index: int, button: Button) -> void:
	var metadata = SaveManager.get_slot_metadata(slot_index)
	if metadata.is_empty():
		button.text = "Slot %d: Empty" % slot_index
	else:
		var time_dict = metadata.get("saved_at", {})
		var time_str = "%02d/%02d/%d %02d:%02d" % [
			time_dict.get("day", 1),
			time_dict.get("month", 1),
			time_dict.get("year", 2026),
			time_dict.get("hour", 0),
			time_dict.get("minute", 0),
		]
		button.text = "Slot %d: Day %d | $%d\n(%s)" % [
			slot_index,
			metadata.get("day", 1),
			metadata.get("money", 0),
			time_str,
		]
	
	button.pressed.connect(func(): _on_slot_selected(slot_index, metadata.is_empty()))
