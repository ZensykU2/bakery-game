extends Node
class_name DroppedItemManager

var inv: Node:
	get: return InventoryManager

func _ready() -> void:
	TimeManager.minutes_passed.connect(_on_time_minutes_passed)

func _on_time_minutes_passed(elapsed_minutes: int) -> void:
	_tick_dropped_items_despawn(elapsed_minutes)

func drop_held_item_to_world() -> void:
	if inv.held_item == null:
		return
		
	var player = SceneManager.get_player()
	if player:
		var drop_pos = player.global_position + GameConstants.Inventory.DROP_OFFSET
		
		enforce_hard_limit()
		
		inv.item_dropped.emit(inv.held_item, drop_pos)
		inv.held_item = null
		inv.inventory_changed.emit()
		GameManager.save_game()

func enforce_hard_limit() -> void:
	var scene_manager = get_node_or_null("/root/SceneManager")
	if scene_manager and scene_manager.has_method("_serialize_active_dropped_items"):
		scene_manager._serialize_active_dropped_items()
	
	while inv.state.dropped_items.size() >= GameConstants.Inventory.HARD_MAX_DROPPED_ITEMS:
		_despawn_oldest_item()

func _despawn_oldest_item() -> void:
	if inv.state.dropped_items.is_empty():
		return
	
	var oldest_drop = inv.state.dropped_items[0]
	inv.state.dropped_items.remove_at(0)
	
	var active_level = SceneManager.get_active_level()
	if active_level and oldest_drop.scene_path == SceneManager.current_scene_path:
		var active_drops = active_level.find_children("*", "DroppedItem", true, false)
		for drop_node in active_drops:
			if drop_node.is_queued_for_deletion():
				continue
			if drop_node.item != null and oldest_drop.item != null \
				and drop_node.item.item_id == oldest_drop.item.item_id and \
				drop_node.global_position.distance_to(oldest_drop.position) < 2.0:
					drop_node.queue_free()
					break

func _tick_dropped_items_despawn(minutes: int) -> void:
	var state = inv.state
	var count = state.dropped_items.size()
	
	if count < GameConstants.Inventory.SOFT_MAX_DROPPED_ITEMS:
		if state.dropped_items_timer != -1.0:
			state.dropped_items_timer = -1.0
			GameManager.save_game()
		return
	
	if state.dropped_items_timer == -1.0:
		state.dropped_items_timer = float(GameConstants.Inventory.DESPAWN_TIMER_MINUTES)
		GameManager.save_game()
	
	state.dropped_items_timer -= float(minutes)
	
	var despawned_any = false
	var interval = float(GameConstants.Inventory.DESPAWN_INTERVAL_MINUTES)
	if interval <= 0.0:
		interval = 1.0
	
	while state.dropped_items_timer <= 0.0 and state.dropped_items.size() >= GameConstants.Inventory.SOFT_MAX_DROPPED_ITEMS:
		_despawn_oldest_item()
		state.dropped_items_timer += interval
		despawned_any = true
	
	if state.dropped_items.size() < GameConstants.Inventory.SOFT_MAX_DROPPED_ITEMS:
		state.dropped_items_timer = -1.0
		despawned_any = true
	
	if despawned_any:
		inv.inventory_changed.emit()
		GameManager.save_game()
