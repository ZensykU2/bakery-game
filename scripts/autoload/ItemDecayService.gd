extends Node
class_name ItemDecayService

var inv: Node:
	get: return Services.inventory

func _ready() -> void:
	TimeManager.minutes_passed.connect(_on_time_minutes_passed)

func _on_time_minutes_passed(elapsed_minutes: int) -> void:
	_tick_inventory_decay(elapsed_minutes)

func _decay_array(slots: Array, minutes: int, modifier: float) -> bool:
	var changed = false
	for item in slots:
		if item == null:
			continue
		var item_id = item.item_id if "item_id" in item else item.get("item_id", "")
		var rate = ItemDB.get_decay_rate(item_id)
		
		if rate > 0.0:
			var freshness = item.freshness if "freshness" in item else item.get("freshness", 1.0)
			var new_fresh = clamp(freshness - (rate * minutes * modifier), 0.0, GameConstants.Inventory.DEFAULT_DECAY_MODIFIER)
			if "freshness" in item:
				item.freshness = new_fresh
			else:
				item["freshness"] = new_fresh
			changed = true
	return changed

func _tick_inventory_decay(minutes: int) -> void:
	var changed = false
	var state = inv.state
	
	if _decay_array(state.inventory_slots, minutes, GameConstants.Inventory.DEFAULT_DECAY_MODIFIER): changed = true
	if _decay_array(state.fridge_slots, minutes, GameConstants.Inventory.FRIDGE_DECAY_MODIFIER): changed = true
	if _decay_array(state.counter_slots, minutes, GameConstants.Inventory.DEFAULT_DECAY_MODIFIER): changed = true
	
	var active_level = SceneManager.get_active_level()
	if active_level:
		var active_drops = active_level.find_children("*", "DroppedItem", true, false)
		var drop_items: Array[InventoryItem] = []
		for d in active_drops:
			if d.item: drop_items.append(d.item)
		if _decay_array(drop_items, minutes, GameConstants.Inventory.DEFAULT_DECAY_MODIFIER): changed = true
	
	var cur_path = SceneManager.current_scene_path
	var offline_drops = []
	for drop in state.dropped_items:
		if drop.scene_path != cur_path:
			offline_drops.append(drop)
			
	if _decay_array(offline_drops, minutes, GameConstants.Inventory.DEFAULT_DECAY_MODIFIER): changed = true
	for casing_id in state.casing_slots.keys():
		var slots = state.casing_slots[casing_id]
		if _decay_array(slots, minutes, GameConstants.Inventory.DEFAULT_DECAY_MODIFIER): changed = true
		
	if changed:
		inv.inventory_changed.emit()
