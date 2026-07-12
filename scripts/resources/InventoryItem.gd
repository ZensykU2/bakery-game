extends Resource
class_name InventoryItem

@export var item_id: String

@export var amount: int = 1

@export var freshness: float = 1.0

func clone(new_amount: int = -1) -> InventoryItem:
	var copy = get_script().new()
	copy.item_id = self.item_id
	copy.amount = new_amount if new_amount != -1 else self.amount
	copy.freshness = self.freshness
	return copy

static func from_dict(d: Dictionary) -> InventoryItem:
	var item = InventoryItem.new()
	item.item_id = d.get("item_id", "")
	item.amount = d.get("amount", 1)
	item.freshness = d.get("freshness", 1.0)
	return item
