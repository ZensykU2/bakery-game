extends TextureRect

@onready var item_icon: TextureRect = $ItemIcon
@onready var count_label: Label = $CountLabel
@onready var freshness_bar: ProgressBar = $FreshnessBar
@onready var selection_border: ReferenceRect = $SelectionBorder

@export var slot_index: int = -1
@export var slot_background_texture: Texture2D = null


func set_item(item: InventoryItem) -> void:
	
	item_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item_icon.stretch_mode = TextureRect.STRETCH_SCALE
	
	if InventoryManager.is_trash_slot(slot_index):
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
			if decay_rate == 0.0 or not InventoryManager.show_freshness_bars:
				freshness_bar.visible = false
			else:
				freshness_bar.visible = true
				freshness_bar.value = item.freshness * 100.0
				
				var sb = StyleBoxFlat.new()
				match item.get_freshness_state():
					InventoryItem.FreshnessState.FRESH:
						sb.bg_color = Color(0.2, 0.8, 0.2)
					InventoryItem.FreshnessState.STALE:
						sb.bg_color = Color(0.9, 0.6, 0.1)
					InventoryItem.FreshnessState.SPOILED:
						sb.bg_color = Color(0.8, 0.2, 0.2)
				
				freshness_bar.add_theme_stylebox_override("fill", sb)

func set_selected(is_selected: bool) -> void:
	if selection_border:
		selection_border.visible = is_selected

func _ready() -> void:
	if slot_background_texture:
		texture = slot_background_texture
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)

func set_slot_background(tex: Texture2D) -> void:
	texture = tex


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
