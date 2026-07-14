extends Node

func _ready() -> void:
	Services.crafting = self

func can_craft(recipe_name: String) -> bool:
	if not ItemDB.has_recipe(recipe_name):
		return false
	var recipe = ItemDB.get_recipe(recipe_name)
	var ingredients: Dictionary = recipe.get("ingredients", {})
	for item in ingredients.keys():
		if InventoryManager.get_item_count(item) < ingredients[item]:
			return false
	return true

func consume_ingredients(recipe_name: String) -> void:
	if not can_craft(recipe_name):
		return
	var recipe = ItemDB.get_recipe(recipe_name)
	var ingredients: Dictionary = recipe.get("ingredients", {})
	for item in ingredients.keys():
		InventoryManager.deduct_item(item, ingredients[item])
