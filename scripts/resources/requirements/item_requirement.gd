extends Requirement
class_name ItemRequirement

@export var item_id: String = ""
@export var amount: int = 1

func is_met() -> bool:
	return InventoryManager.get_item_count(item_id) >= amount

func consume() -> void:
	InventoryManager.deduct_item(item_id, amount)

func get_description() -> String:
	var data = ItemDB.get_item_data(item_id)
	var display_name = data.get("name", item_id.capitalize()) if data else item_id.capitalize()
	return "%dx %s" % [amount, display_name]

func get_icon() -> Texture2D:
	var data = ItemDB.get_item_data(item_id)
	return data.get("icon_fresh", null) if data else null
