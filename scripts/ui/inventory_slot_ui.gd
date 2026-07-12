extends TextureRect

@onready var item_icon: TextureRect = $ItemIcon
@onready var count_label: Label = $CountLabel
@onready var freshness_bar: ProgressBar = $FreshnessBar
@onready var selection_border: ReferenceRect = $SelectionBorder

@export var slot_index: int = -1

func set_item(item: InventoryItem) -> void:
	
	item_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item_icon.stretch_mode = TextureRect.STRETCH_SCALE
	
	if slot_index == 999:
		count_label.text = ""
		if freshness_bar: freshness_bar.visible = false
		return
	
	if item == null:
		item_icon.texture = null
		count_label.text = ""
		if freshness_bar:
			freshness_bar.visible = false
	else:
		item_icon.texture = ItemDB.get_item_icon(item.item_id, item.freshness)
		count_label.text = str(item.amount) if item.amount > 1 else ""
		
		if freshness_bar:
			var decay_rate = ItemDB.get_decay_rate(item.item_id)
			if decay_rate == 0.0:
				freshness_bar.visible = false
			else:
				freshness_bar.visible = true
				freshness_bar.value = item.freshness * 100.0
				
				var sb = StyleBoxFlat.new()
				if item.freshness > 0.6:
					sb.bg_color = Color(0.2, 0.8, 0.2)
				elif item.freshness > 0.25:
					sb.bg_color = Color(0.9, 0.6, 0.1)
				else:
					sb.bg_color = Color(0.8, 0.2, 0.2)
				
				freshness_bar.add_theme_stylebox_override("fill", sb)

func set_selected(is_selected: bool) -> void:
	if selection_border:
		selection_border.visible = is_selected

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
				InventoryManager.handle_slot_double_click(slot_index)
				accept_event()
			elif event.button_index == MOUSE_BUTTON_LEFT:
				InventoryManager.handle_slot_click(slot_index, event.shift_pressed, true)
				accept_event()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				InventoryManager.handle_slot_right_click(slot_index)
				accept_event()
		else:
			if event.button_index == MOUSE_BUTTON_LEFT:
				InventoryManager.handle_slot_click(slot_index, event.shift_pressed, false)
				accept_event()

func _on_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		InventoryManager.paint_slot(slot_index)
