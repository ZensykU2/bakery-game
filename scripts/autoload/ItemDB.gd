extends Node

var item_resources := {}
var recipe_resources := {}
var _duplicate_item_ids: Array[String] = []
var _duplicate_recipe_ids: Array[String] = []

func _ready() -> void:
	load_all_items()
	load_all_recipes()

# Scans res://resources/items/ for all ItemData resource files
func load_all_items() -> void:
	item_resources.clear()
	_duplicate_item_ids.clear()
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
					if item_resources.has(item_id):
						_duplicate_item_ids.append(item_id)
					else:
						item_resources[item_id] = resource
			file_name = dir.get_next()
		dir.list_dir_end()
		print("ItemDB: Loaded %d item resources." % item_resources.size())
	else:
		push_error("ItemDB: Failed to open items directory: " + directory_path)


func load_all_recipes() -> void:
	recipe_resources.clear()
	_duplicate_recipe_ids.clear()
	var directory_path := "res://resources/recipes/"
	var dir := DirAccess.open(directory_path)
	if dir == null:
		push_error("ItemDB: Failed to open recipes directory: " + directory_path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".remap")):
			var clean_name := file_name.replace(".remap", "")
			var resource := load(directory_path + clean_name)
			if resource is RecipeData:
				var recipe_id: String = resource.recipe_id.strip_edges()
				if recipe_id == "":
					recipe_id = clean_name.get_basename()
				if recipe_resources.has(recipe_id):
					_duplicate_recipe_ids.append(recipe_id)
				else:
					recipe_resources[recipe_id] = resource
		file_name = dir.get_next()
	dir.list_dir_end()
	print("ItemDB: Loaded %d recipe resources." % recipe_resources.size())
	if OS.is_debug_build():
		_report_catalog_validation()

func get_item_resource(item_id: String) -> ItemData:
	var resource = item_resources.get(item_id, null)
	return resource as ItemData

func is_stackable(item_id: String) -> bool:
	var res := get_item_resource(item_id)
	return res.stackable if res else true

func get_decay_rate(item_id: String) -> float:
	var res := get_item_resource(item_id)
	return res.decay_rate if res else 0.0

func get_item_icon(item_id: String, freshness: float) -> Texture2D:
	var res := get_item_resource(item_id)
	if not res:
		return null
	
	if freshness >= GameConstants.Inventory.FRESH_THRESHOLD:
		return res.icon_fresh
	elif freshness >= GameConstants.Inventory.STALE_THRESHOLD:
		return res.icon_stale
	else:
		return res.icon_spoiled

func has_recipe(recipe_id: String) -> bool:
	return recipe_resources.has(recipe_id)


func get_recipe_resource(recipe_id: String) -> RecipeData:
	var resource = recipe_resources.get(recipe_id, null)
	return resource as RecipeData

func get_recipe_requirements(recipe_id: String) -> Array[Requirement]:
	var recipe := get_recipe_resource(recipe_id)
	if recipe == null:
		return []
	return recipe.requirements

func get_recipe_names() -> Array[String]:
	var list: Array[String] = []
	for key in recipe_resources.keys():
		list.append(key)
	list.sort()
	return list


func validate_catalog() -> Array[String]:
	var errors: Array[String] = []

	for item_id in _duplicate_item_ids:
		errors.append("Duplicate item ID: %s" % item_id)
	for recipe_id in _duplicate_recipe_ids:
		errors.append("Duplicate recipe ID: %s" % recipe_id)

	for item_id in item_resources:
		var item := get_item_resource(item_id)
		if item == null:
			errors.append("Invalid item resource for ID: %s" % item_id)
			continue

		if item.icon_fresh == null:
			errors.append("Item '%s' is missing a fresh icon." % item_id)


	for recipe_id in recipe_resources:
		var recipe := get_recipe_resource(recipe_id)
		if recipe == null:
			errors.append("Invalid recipe resource for ID: %s" % recipe_id)
			continue
		_validate_recipe(recipe_id, recipe, errors)

	return errors


func _validate_recipe(
	recipe_id: String,
	recipe: RecipeData,
	errors: Array[String]
) -> void:
	if recipe.bake_duration_minutes <= 0.0:
		errors.append("Recipe '%s' has no bake duration." % recipe_id)

	if recipe.output_item_id == "" or not item_resources.has(recipe.output_item_id):
		errors.append("Recipe '%s' has an invalid output item '%s'." % [recipe_id, recipe.output_item_id])
	if recipe.requirements.is_empty():
		errors.append("Recipe '%s' has no requirements." % recipe_id)

	for requirement in recipe.requirements:
		if requirement == null:
			errors.append("Recipe '%s' contains an empty requirement." % recipe_id)
		elif requirement is ItemRequirement:
			if not item_resources.has(requirement.item_id):
				errors.append(
					"Recipe '%s' references missing requirement item '%s'." % [
						recipe_id,
						requirement.item_id
					]
				)
			elif requirement.amount <= 0:
				errors.append(
					"Recipe '%s' has a non-positive requirement amount for '%s'." % [
						recipe_id,
						requirement.item_id
					]
				)


func _report_catalog_validation() -> void:
	var errors := validate_catalog()
	if errors.is_empty():
		return

	for validation_error in errors:
		push_error("ItemDB validation: %s" % validation_error)
