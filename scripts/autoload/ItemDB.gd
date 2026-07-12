extends Node

# Central database defining ALL item properties (raw ingredients & baked goods)
var items := {
	"flour": {
		"buy_price": 3,         # Cost to buy at the shop
		"decay_rate": 0.0,      # Never decays
		"stackable": true,
		"icon_fresh": preload("res://art/sprites/bakery/ingredients/Flour.png"),
		"icon_stale": preload("res://art/sprites/bakery/ingredients/Flour.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/ingredients/Flour.png")
	},
	"sugar": {
		"buy_price": 2,
		"decay_rate": 0.0,
		"stackable": true,
		"icon_fresh": preload("res://art/sprites/coin.png"),
		"icon_stale": preload("res://art/sprites/coin.png"),
		"icon_spoiled": preload("res://art/sprites/coin.png")
	},
	"butter": {
		"buy_price": 4,
		"decay_rate": 0.0002,
		"stackable": true,
		"icon_fresh": preload("res://art/sprites/platforms.png"),
		"icon_stale": preload("res://art/sprites/platforms.png"),
		"icon_spoiled": preload("res://art/sprites/platforms.png")
	},
	"eggs": {
		"buy_price": 2,
		"decay_rate": 0.0005,
		"stackable": true,
		"icon_fresh": preload("res://art/sprites/bakery/ingredients/Egg.png"),
		"icon_stale": preload("res://art/sprites/bakery/ingredients/Egg.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/ingredients/Egg.png")
	},
	"berries": {
		"buy_price": 5,
		"decay_rate": 0.001,
		"stackable": true,
		"icon_fresh": preload("res://art/sprites/fruit.png"),
		"icon_stale": preload("res://art/sprites/fruit.png"),
		"icon_spoiled": preload("res://art/sprites/fruit.png")
	},
	"milk": {
		"buy_price": 8,
		"decay_rate": 0.012,
		"stackable": true,
		"icon_fresh": preload("res://art/sprites/bakery/ingredients/Milk.png"),
		"icon_stale": preload("res://art/sprites/bakery/ingredients/Milk.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/ingredients/Milk.png")
	},
	"chocolate": {
		"buy_price": 6,
		"decay_rate": 0.0005,
		"stackable": true,
		"icon_fresh": preload("res://art/sprites/bakery/ingredients/Chocolate.png"),
		"icon_stale": preload("res://art/sprites/bakery/ingredients/Chocolate.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/ingredients/Chocolate.png")
	},
	"strawberry": {
		"buy_price": 2,
		"decay_rate": 0.001,
		"stackable": true,
		"icon_fresh": preload("res://art/sprites/bakery/ingredients/Strawberry.png"),
		"icon_stale": preload("res://art/sprites/bakery/ingredients/Strawberry.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/ingredients/Strawberry.png")
	},
	"bread": {
		"ingredients": {
			"flour": 1,
			"eggs": 1,
		},
		"sell_price": 12,
		"bake_time": 5.0,
		"decay_rate": 0.0008,
		"stackable": false,
		"icon_fresh": preload("res://art/sprites/bakery/food/Bread.png"),
		"icon_stale": preload("res://art/sprites/bakery/food/Bread.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/food/Bread.png")
	},
	"cookies": {
		"ingredients": {
			"flour": 1,
			"sugar": 1,
			"butter": 1,
			"chocolate": 1,
		},
		"sell_price": 18,
		"bake_time": 8.0,
		"decay_rate": 0.0003,
		"stackable": false,
		"icon_fresh": preload("res://art/sprites/bakery/food/Cookie.png"),
		"icon_stale": preload("res://art/sprites/bakery/food/Cookie.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/food/Cookie.png")
	},
	"berry_tart": {
		"ingredients": {
			"flour": 1,
			"sugar": 1,
			"butter": 1,
			"berries": 2,
		},
		"sell_price": 25,
		"bake_time": 12.0,
		"decay_rate": 0.0012,
		"stackable": false,
		"icon_fresh": preload("res://art/sprites/bakery/food/BerryTart.png"),
		"icon_stale": preload("res://art/sprites/bakery/food/BerryTart.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/food/BerryTart.png")
	},
	"apple_pie": {
		"ingredients": {
			"flour": 1,
			"sugar": 1,
			"butter": 1,
			"milk": 1,
		},
		"sell_price": 24,
		"bake_time": 12.0,
		"decay_rate": 0.0012,
		"stackable": false,
		"icon_fresh": preload("res://art/sprites/bakery/food/ApplePie.png"),
		"icon_stale": preload("res://art/sprites/bakery/food/ApplePie.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/food/ApplePie.png")
	},
	"black_forest_cake": {
		"ingredients": {
			"flour": 2,
			"sugar": 2,
			"butter": 1,
			"chocolate": 1,
		},
		"sell_price": 28,
		"bake_time": 18.0,
		"decay_rate": 0.0012,
		"stackable": false,
		"icon_fresh": preload("res://art/sprites/bakery/food/BlackForestCake.png"),
		"icon_stale": preload("res://art/sprites/bakery/food/BlackForestCake.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/food/BlackForestCake.png")
	},
	"cherry_pie": {
		"ingredients": {
			"flour": 1,
			"sugar": 1,
			"butter": 1,
			"berries": 2,
		},
		"sell_price": 28,
		"bake_time": 18.0,
		"decay_rate": 0.0012,
		"stackable": false,
		"icon_fresh": preload("res://art/sprites/bakery/food/CherryPie.png"),
		"icon_stale": preload("res://art/sprites/bakery/food/CherryPie.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/food/CherryPie.png")
	},
	"donut": {
		"ingredients": {
			"flour": 1,
			"butter": 1,
			"choclate": 1,
		},
		"sell_price": 12,
		"bake_time": 8.0,
		"decay_rate": 0.0012,
		"stackable": false,
		"icon_fresh": preload("res://art/sprites/bakery/food/Donut.png"),
		"icon_stale": preload("res://art/sprites/bakery/food/Donut.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/food/Donut.png")
	},
	"tiramisu": {
		"ingredients": {
			"flour": 1,
			"sugar": 1,
			"butter": 1,
			"milk": 1,
		},
		"sell_price": 38,
		"bake_time": 40.0,
		"decay_rate": 0.0012,
		"stackable": false,
		"icon_fresh": preload("res://art/sprites/bakery/food/Tiramisu.png"),
		"icon_stale": preload("res://art/sprites/bakery/food/Tiramisu.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/food/Tiramisu.png")
	}
}

func get_item_data(item_id: String) -> Dictionary:
	return items.get(item_id, {})

func is_stackable(item_id: String) -> bool:
	return items.get(item_id, {}).get("stackable", true)

func get_decay_rate(item_id: String) -> float:
	return items.get(item_id, {}).get("decay_rate", 0.0)

func get_item_icon(item_id: String, freshness: float) -> Texture2D:
	var data = get_item_data(item_id)
	if data.is_empty():
		return null
		
	if freshness <= 0.0:
		return data.get("icon_spoiled", null)
	elif freshness <= 0.5:
		return data.get("icon_stale", null)
	else:
		return data.get("icon_fresh", null)

func has_recipe(item_id: String) -> bool:
	var data = get_item_data(item_id)
	return not data.is_empty() and data.has("ingredients")

func get_recipe(item_id: String) -> Dictionary:
	var data = get_item_data(item_id)
	if not data.is_empty() and not data.has("icon"):
		data["icon"] = data.get("icon_fresh", null)
	return data

func get_recipe_names() -> Array[String]:
	var list: Array[String] = []
	for key in items.keys():
		if items[key].has("ingredients"):
			list.append(key)
	return list
