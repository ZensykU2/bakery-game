extends Control

@onready var slot_1_btn: Button = $CenterContainer/VBoxContainer/Slot1Container/Slot1Button
@onready var delete_1_btn: Button = $CenterContainer/VBoxContainer/Slot1Container/Delete1Button
@onready var slot_2_btn: Button = $CenterContainer/VBoxContainer/Slot2Container/Slot2Button
@onready var delete_2_btn: Button = $CenterContainer/VBoxContainer/Slot2Container/Delete2Button
@onready var slot_3_btn: Button = $CenterContainer/VBoxContainer/Slot3Container/Slot3Button
@onready var delete_3_btn: Button = $CenterContainer/VBoxContainer/Slot3Container/Delete3Button
@onready var back_btn: Button = $CenterContainer/VBoxContainer/BackButton

func _ready() -> void:
	back_btn.pressed.connect(func(): SceneManager.go_to_title_screen())

	_update_slot(1)
	_update_slot(2)
	_update_slot(3)

func _on_slot_selected(slot_index: int, is_empty: bool) -> void:
	if is_empty:
		GameManager.new_game(slot_index)
		SceneManager.go_to_main_game()
	else:
		# Immediately load game and enter, bypassing dialogs
		GameManager.load_game(slot_index)
		SceneManager.go_to_main_game()

func _on_delete_pressed(slot_index: int) -> void:
	SaveManager.delete_save(slot_index)
	_update_slot(slot_index)

func _update_slot(slot_index: int) -> void:
	var button: Button
	var delete_btn: Button
	match slot_index:
		1:
			button = slot_1_btn
			delete_btn = delete_1_btn
		2:
			button = slot_2_btn
			delete_btn = delete_2_btn
		3:
			button = slot_3_btn
			delete_btn = delete_3_btn
			
	# Clean up any existing connections from previous updates
	for conn in button.pressed.get_connections():
		button.pressed.disconnect(conn.callable)
	for conn in delete_btn.pressed.get_connections():
		delete_btn.pressed.disconnect(conn.callable)
		
	var metadata = SaveManager.get_slot_metadata(slot_index)
	if metadata.is_empty():
		button.text = "Slot %d: Empty" % slot_index
		delete_btn.visible = false
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
		delete_btn.visible = true
		
		# Vibrant crimson styling overrides for the delete action
		delete_btn.add_theme_color_override("font_color", Color(0.95, 0.25, 0.25))
		delete_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.4, 0.4))
		delete_btn.add_theme_color_override("font_pressed_color", Color(0.7, 0.15, 0.15))
		
	button.pressed.connect(func(): _on_slot_selected(slot_index, metadata.is_empty()))
	delete_btn.pressed.connect(func(): _on_delete_pressed(slot_index))
