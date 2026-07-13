extends ColorRect

signal backdrop_clicked

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	gui_input.connect(_on_gui_input)
	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if InventoryManager.held_item != null:
			InventoryManager.drop_held_item_to_world()
			get_viewport().set_input_as_handled()
		else:
			backdrop_clicked.emit()
			get_viewport().set_input_as_handled()
