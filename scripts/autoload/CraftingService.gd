extends Node

func _ready() -> void:
	Services.crafting = self

func can_craft(recipe_name: String) -> bool:
	if not ItemDB.has_recipe(recipe_name):
		return false
	var recipe = ItemDB.get_recipe(recipe_name)
	
	# 1. Check legacy dictionary ingredients
	var ingredients: Dictionary = recipe.get("ingredients", {})
	for item in ingredients.keys():
		if InventoryManager.get_item_count(item) < ingredients[item]:
			return false
			
	# 2. Check unified resource-based requirements
	var item_res = ItemDB.item_resources.get(recipe_name, null)
	if item_res and "recipe_requirements" in item_res:
		for req in item_res.recipe_requirements:
			if req and not req.is_met():
				return false
				
	return true

func consume_ingredients(recipe_name: String) -> void:
	if not can_craft(recipe_name):
		return
	var recipe = ItemDB.get_recipe(recipe_name)
	
	# 1. Deduct legacy dictionary ingredients
	var ingredients: Dictionary = recipe.get("ingredients", {})
	for item in ingredients.keys():
		InventoryManager.deduct_item(item, ingredients[item])
		
	# 2. Deduct unified resource-based requirements
	var item_res = ItemDB.item_resources.get(recipe_name, null)
	if item_res and "recipe_requirements" in item_res:
		for req in item_res.recipe_requirements:
			if req:
				req.consume()
