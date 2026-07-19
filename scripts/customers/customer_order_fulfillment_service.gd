extends RefCounted
class_name CustomerOrderFulfillmentService


func fulfill(
		order_intent: CustomerOrderIntent,
		casing_slots: Dictionary
	) -> CustomerOrderResult:
	var result := CustomerOrderResult.new()
	if order_intent == null or order_intent.item_id.is_empty():
		return result

	for slots in casing_slots.values():
		if not slots is Array:
			continue
		for slot_index in range(slots.size()):
			var item := slots[slot_index] as InventoryItem
			if item == null or item.item_id != order_intent.item_id:
				continue

			var sold_item := item.clone(1)
			var earned_money := SaleService.get_item_value(sold_item)
			if earned_money <= 0:
				return result

			item.amount -= 1
			if item.amount <= 0:
				slots[slot_index] = null

			result.fulfilled = true
			result.item_id = sold_item.item_id
			result.earned_money = earned_money
			return result

	return result
