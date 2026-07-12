extends Interactable

@export var casing_id: String = "Casing1"
@export var slot_count: int = 4

var display_sprites: Array[Sprite2D] = []

func _on_ready() -> void:
	if not GameManager.state.casing_slots.has(casing_id):
		var slots: Array[InventoryItem] = []
		slots.resize(slot_count)
		GameManager.state.casing_slots[casing_id] = slots
	
	for i in range(1, slot_count + 1):
		var sprite = get_node_or_null("Display" + str(i))
		if sprite:
			display_sprites.append(sprite)
	
	InventoryManager.inventory_changed.connect(update_display_shelf)
	update_display_shelf()

func ui_accept(_player: CharacterBody2D) -> void:
	var container_ui = SceneManager.get_container_ui()
	if container_ui:
		container_ui.open(GameManager.state.casing_slots[casing_id])

func _close_ui() -> void:
	var container_ui = SceneManager.get_container_ui()
	if container_ui and container_ui.visible:
		var active_array = container_ui.active_container_array
		var casing_array = GameManager.state.casing_slots.get(casing_id, null)
		if active_array == casing_array:
			container_ui.close()

func update_display_shelf() -> void:
	var slots = GameManager.state.casing_slots.get(casing_id, [])
	for i in range(display_sprites.size()):
		if i < slots.size() and slots[i] != null:
			display_sprites[i].texture = ItemDB.get_item_icon(slots[i].item_id, slots[i].freshness)
			display_sprites[i].visible = true
		else:
			display_sprites[i].texture = null
			display_sprites[i].visible = false
