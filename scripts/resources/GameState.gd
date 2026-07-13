extends RefCounted
class_name GameState

var day: int = GameConstants.TimeManage.DEFAULT_START_DAY
var money: int = GameConstants.Inventory.DEFAULT_START_MONEY

var max_inventory_slots: int = GameConstants.Inventory.DEFAULT_INVENTORY_SLOTS
var max_fridge_slots: int = GameConstants.Inventory.DEFAULT_FRIDGE_SLOTS
var max_counter_slots: int = GameConstants.Inventory.DEFAULT_COUNTER_SLOTS

var inventory_slots: Array[InventoryItem] = []
var fridge_slots: Array[InventoryItem] = []
var counter_slots: Array[InventoryItem] = []
var casing_slots: Dictionary = {}
var dropped_items: Array = []

var active_bakes := {}

func _init() -> void:
	inventory_slots.resize(max_inventory_slots)
	fridge_slots.resize(max_fridge_slots)
	counter_slots.resize(max_counter_slots)
	
	for item_id in GameConstants.Inventory.STARTING_ITEMS.keys():
		_add_initial_item(item_id, GameConstants.Inventory.STARTING_ITEMS[item_id])

func _add_initial_item(item_id: String, amount: int) -> void:
	for i in range(inventory_slots.size()):
		if inventory_slots[i] == null:
			var item = InventoryItem.new()
			item.item_id = item_id
			item.amount = amount
			inventory_slots[i] = item
			break

func _serialize_slots(slots: Array[InventoryItem]) -> Array:
	var data = []
	for item in slots:
		if item == null:
			data.append(null)
		else:
			data.append({
				"item_id": item.item_id,
				"amount": item.amount,
				"freshness": item.freshness
			})
	return data

func _deserialize_slots(data_list: Array, target_size: int) -> Array[InventoryItem]:
	var slots: Array[InventoryItem] = []
	slots.resize(target_size)
	for i in range(min(data_list.size(), target_size)):
		var item_data = data_list[i]
		if item_data != null:
			var item = InventoryItem.new()
			item.item_id = item_data.get("item_id", "")
			item.amount = item_data.get("amount", 1)
			item.freshness = item_data.get("freshness", 1.0)
			slots[i] = item
	return slots

func to_dict() -> Dictionary:
	var casing_data = {}
	for key in casing_slots.keys():
		casing_data[key] = _serialize_slots(casing_slots[key])
	
	var drops = []
	for drop in dropped_items:
		drops.append({
			"scene_path": drop.scene_path,
			"item_id": drop.item_id,
			"amount": drop.amount,
			"freshness": drop.freshness,
			"pos_x": drop.position.x,
			"pos_y": drop.position.y
		})
		
	return {
		"day": day,
		"money": money,
		"max_inventory_slots": max_inventory_slots,
		"max_fridge_slots": max_fridge_slots,
		"max_counter_slots": max_counter_slots,
		"active_bakes": active_bakes.duplicate(true),
		"inventory_slots": _serialize_slots(inventory_slots),
		"fridge_slots": _serialize_slots(fridge_slots),
		"casing_slots": casing_data,
		"counter_slots": _serialize_slots(counter_slots)
	}

func from_dict(data: Dictionary) -> void:
	day = data.get("day", GameConstants.TimeManage.DEFAULT_START_DAY)
	money = data.get("money", GameConstants.Inventory.DEFAULT_START_MONEY)
	max_inventory_slots = data.get("max_inventory_slots", GameConstants.Inventory.DEFAULT_INVENTORY_SLOTS)
	max_fridge_slots = data.get("max_fridge_slots", GameConstants.Inventory.DEFAULT_FRIDGE_SLOTS)
	max_counter_slots = data.get("max_counter_slots", GameConstants.Inventory.DEFAULT_COUNTER_SLOTS)
	
	active_bakes = data.get("active_bakes", {}).duplicate(true)
	
	inventory_slots = _deserialize_slots(data.get("inventory_slots", []), max_inventory_slots)
	fridge_slots = _deserialize_slots(data.get("fridge_slots", []), max_fridge_slots)
	counter_slots = _deserialize_slots(data.get("counter_slots", []), max_counter_slots)
	
	var casing_data = data.get("casing_slots", {})
	casing_slots.clear()
	for key in casing_data.keys():
		var list_data = casing_data[key]
		casing_slots[key] = _deserialize_slots(list_data, list_data.size())
	
	var drops_data = data.get("dropped_items", [])
	dropped_items.clear()
	for d in drops_data:
		dropped_items.append({
			"scene_path": d.get("scene_path", ""),
			"item_id": d.get("item_id", ""),
			"amount": d.get("amount", 1),
			"freshness": d.get("freshness", 1.0),
			"position": Vector2(d.get("pos_x", 0.0), d.get("pos_y", 0.0))
		})
