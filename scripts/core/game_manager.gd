extends Node

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

var recipes := {
	"bread": {
		"ingredients": {"flour": 1, "eggs": 1},
		"sell_price": 12
	},
	"cookies": {
		"ingredients": {"flour": 1, "sugar": 1, "butter": 1},
		"sell_price": 18
	},
	"berry_tart": {
		"ingredients": {
			"flour": 1,
			"sugar": 1,
			"butter": 1,
			"berries": 1,
		},
		"sell_price": 25
	}
}

func can_craft(recipe_name: String) -> bool:
	if not recipes.has(recipe_name):
		return false
	
	var ingredients = recipes[recipe_name]["ingredients"]
	for item in ingredients.keys():
		if inventory.get(item, 0) < ingredients[item]:
			return false
	
	return true

func craft(recipe_name: String) -> bool:
	if not can_craft(recipe_name):
		return false
	
	var ingredients = recipes[recipe_name]["ingredients"]
	for item in ingredients.keys():
		inventory[item] -= ingredients[item]
	
	bakery_stock[recipe_name] += 1
	return true
	
func next_day() -> void:
	day += 1
	inventory["berries"] += 1
	inventory["eggs"] += 1
