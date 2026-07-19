extends RefCounted
class_name SaleService


static func get_total_value(items: Array[InventoryItem]) -> int:
	var total_value := 0.0

	for item in items:
		total_value += get_item_value(item) * (item.amount if item != null else 0)

	return int(total_value)


static func get_item_value(item: InventoryItem) -> int:
	if item == null:
		return 0

	var item_data := ItemDB.get_item_resource(item.item_id)
	var base_price := item_data.sell_price if item_data else 0
	return int(base_price * item.get_sell_multiplier())


static func sell_all(items: Array[InventoryItem]) -> int:
	var total_value := get_total_value(items)
	if total_value <= 0:
		return 0

	for index in range(items.size()):
		items[index] = null

	GameManager.add_money(total_value)
	InventoryManager.inventory_changed.emit()
	return total_value
