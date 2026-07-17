extends Requirement
class_name ItemRequirement

@export var item_id: String = ""
@export var amount: int = 1

func is_met() -> bool:
	return InventoryManager.get_item_count(item_id) >= amount

func consume() -> void:
	InventoryManager.deduct_item(item_id, amount)

func get_description() -> String:
	var item_data := ItemDB.get_item_resource(item_id)
	var display_name := item_data.item_id.capitalize() if item_data else item_id.capitalize()
	return "%dx %s" % [amount, display_name]

func get_icon() -> Texture2D:
	var item_data := ItemDB.get_item_resource(item_id)
	return item_data.icon_fresh if item_data else null
