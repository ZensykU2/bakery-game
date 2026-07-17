extends RefCounted
class_name SaleService


static func get_total_value(items: Array[InventoryItem]) -> int:
	var total_value := 0.0

	for item in items:
		if item == null:
			continue

		var item_data := ItemDB.get_item_resource(item.item_id)
		var base_price := item_data.sell_price if item_data else 0
		total_value += base_price * item.get_sell_multiplier() * item.amount

	return int(total_value)


static func sell_all(items: Array[InventoryItem]) -> int:
	var total_value := get_total_value(items)
	if total_value <= 0:
		return 0

	for index in range(items.size()):
		items[index] = null

	GameManager.add_money(total_value)
	InventoryManager.inventory_changed.emit()
	return total_value
