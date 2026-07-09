extends Node

var recipes := {
	"bread": {
		"ingredients": {
			"flour": 1,
			"eggs": 1,
		},
		"sell_price": 12,
		"bake_time": 5.0,
	},
	"cookies": {
		"ingredients": {
			"flour": 1,
			"sugar": 1,
			"butter": 1,
		},
		"sell_price": 18,
		"bake_time": 8.0,
	},
	"berry_tart": {
		"ingredients": {
			"flour": 1,
			"sugar": 1,
			"butter": 1,
			"berries": 1,
		},
		"sell_price": 25,
		"bake_time": 12.0
	},
}

func has_recipe(recipe_name: String) -> bool:
	return recipes.has(recipe_name)

func get_recipe(recipe_name: String) -> Dictionary:
	return recipes.get(recipe_name, {})
