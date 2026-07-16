extends Resource
class_name  ShopItem

@export var item_id: String = ""
@export var shop_types: Array[String] = []
@export var costs: Array[Requirement] = []
@export var unlock_conditions: Array[UnlockCondition] = []

func is_unlocked() -> bool:
	for condition in unlock_conditions:
		if condition and not condition.is_unlocked():
			return false
	return true
