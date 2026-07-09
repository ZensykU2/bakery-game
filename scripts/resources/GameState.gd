extends RefCounted
class_name GameState

var day: int = 1
var money: int = 100

var inventory := {
	"flour": 5,
	"sugar": 3,
	"butter": 2,
	"eggs": 4,
	"berries": 3,
}

var bakery_stock := {
	"bread": 0,
	"cookies": 0,
	"berry_tart": 0,
}

var active_bakes := {}

func to_dict() -> Dictionary:
	return {
		"day": day,
		"money": money,
		"inventory": inventory.duplicate(true),
		"bakery_stock": bakery_stock.duplicate(true),
		"active_bakes": active_bakes.duplicate(true),
	}

func from_dict(data: Dictionary) -> void:
	day = data.get("day", 1)
	money = data.get("money", 100)
	inventory = data.get("inventory", {}).duplicate(true)
	bakery_stock = data.get("bakery_stock", {}).duplicate(true)
	active_bakes = data.get("active_bakes", {}).duplicate(true)
