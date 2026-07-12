extends Node

# Central database defining ALL item properties (raw ingredients & baked goods)
var items := {
	"flour": {
		"buy_price": 3,         # Cost to buy at the shop
		"decay_rate": 0.0,      # Never decays
		"stackable": true,
		"icon_fresh": preload("res://art/sprites/bakery/KitchenSheet.png"),
		"icon_stale": preload("res://art/sprites/bakery/KitchenSheet.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/KitchenSheet.png")
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
		"icon_fresh": preload("res://art/sprites/fruit.png"),
		"icon_stale": preload("res://art/sprites/fruit.png"),
		"icon_spoiled": preload("res://art/sprites/fruit.png")
	},
	"berries": {
		"buy_price": 5,
		"decay_rate": 0.001,
		"stackable": true,
		"icon_fresh": preload("res://art/sprites/fruit.png"),
		"icon_stale": preload("res://art/sprites/fruit.png"),
		"icon_spoiled": preload("res://art/sprites/fruit.png")
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
		"icon_fresh": preload("res://art/sprites/bakery/Bread.png"),
		"icon_stale": preload("res://art/sprites/bakery/Bread.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/Bread.png")
	},
	"cookies": {
		"ingredients": {
			"flour": 1,
			"sugar": 1,
			"butter": 1,
		},
		"sell_price": 18,
		"bake_time": 8.0,
		"decay_rate": 0.0003,
		"stackable": false,
		"icon_fresh": preload("res://art/sprites/bakery/Cookie.png"),
		"icon_stale": preload("res://art/sprites/bakery/Cookie.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/Cookie.png")
	},
	"berry_tart": {
		"ingredients": {
			"flour": 1,
			"sugar": 1,
			"butter": 1,
			"berries": 1,
		},
		"sell_price": 25,
		"bake_time": 12.0,
		"decay_rate": 0.0012,
		"stackable": false,
		"icon_fresh": preload("res://art/sprites/bakery/BerryTart.png"),
		"icon_stale": preload("res://art/sprites/bakery/BerryTart.png"),
		"icon_spoiled": preload("res://art/sprites/bakery/BerryTart.png")
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
