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

enum FreshnessState {
	FRESH,
	STALE,
	SPOILED,
}

func get_freshness_state() -> FreshnessState:
	if freshness >= GameConstants.Inventory.FRESH_THRESHOLD:
		return FreshnessState.FRESH
	elif freshness >= GameConstants.Inventory.STALE_THRESHOLD:
		return FreshnessState.STALE
	else:
		return FreshnessState.SPOILED

func get_sell_multiplier() -> float:
	match get_freshness_state():
		FreshnessState.FRESH:
			return GameConstants.Inventory.FRESH_PRICE_MULTIPLIER
		FreshnessState.STALE:
			return GameConstants.Inventory.STALE_PRICE_MULTIPLIER
		FreshnessState.SPOILED:
			return GameConstants.Inventory.SPOILED_PRICE_MULTIPLIER
	return 0.0

func merge_with(other: InventoryItem) -> void:
	var total_amt = self.amount + other.amount
	if total_amt > 0:
		self.freshness = (self.freshness * self.amount + other.freshness * other.amount) / total_amt
	self.amount = total_amt
