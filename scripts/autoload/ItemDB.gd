extends Node

var item_resources := {}

func _ready() -> void:
	load_all_items()

# Scans res://resources/items/ for all ItemData resource files
func load_all_items() -> void:
	item_resources.clear()
	var directory_path = "res://resources/items/"
	
	if not DirAccess.dir_exists_absolute(directory_path):
		DirAccess.make_dir_absolute(directory_path)
		
	var dir = DirAccess.open(directory_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".remap")):
				# Godot exports .tres files as .remap in release builds, so we support both
				var clean_name = file_name.replace(".remap", "")
				var res_path = directory_path + clean_name
				var resource = load(res_path)
				if resource is ItemData:
					var item_id = resource.item_id.strip_edges()
					if item_id == "":
						item_id = clean_name.get_basename()
					item_resources[item_id] = resource
			file_name = dir.get_next()
		dir.list_dir_end()
		print("ItemDB: Loaded %d item resources." % item_resources.size())
	else:
		push_error("ItemDB: Failed to open items directory: " + directory_path)

func get_item_data(item_id: String) -> Dictionary:
	var res = item_resources.get(item_id, null)
	if not res:
		return {}
	
	var data = {
		"buy_price": res.buy_price,
		"sell_price": res.sell_price,
		"decay_rate": res.decay_rate,
		"stackable": res.stackable,
		"icon_fresh": res.icon_fresh,
		"icon_stale": res.icon_stale,
		"icon_spoiled": res.icon_spoiled,
	}
	
	if res.bake_time > 0.0 or not res.ingredients.is_empty():
		data["ingredients"] = res.ingredients
		data["bake_time"] = res.bake_time
	
	return data

func is_stackable(item_id: String) -> bool:
	var res = item_resources.get(item_id, null)
	return res.stackable if res else true

func get_decay_rate(item_id: String) -> float:
	var res = item_resources.get(item_id, null)
	return res.decay_rate if res else 0.0

func get_item_icon(item_id: String, freshness: float) -> Texture2D:
	var res = item_resources.get(item_id, null)
	if not res:
		return null
	
	if freshness >= GameConstants.Inventory.FRESH_THRESHOLD:
		return res.icon_fresh
	elif freshness >= GameConstants.Inventory.STALE_THRESHOLD:
		return res.icon_stale
	else:
		return res.icon_spoiled

func has_recipe(item_id: String) -> bool:
	var res = item_resources.get(item_id, null)
	return res != null and not res.ingredients.is_empty()

func get_recipe(item_id: String) -> Dictionary:
	var data = get_item_data(item_id)
	if not data.is_empty() and not data.has("icon"):
		data["icon"] = data.get("icon_fresh", null)
	return data

func get_recipe_names() -> Array[String]:
	var list: Array[String] = []
	for key in item_resources.keys():
		var res = item_resources[key]
		if not res.ingredients.is_empty():
			list.append(key)
	return list
