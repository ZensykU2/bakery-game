extends Node

signal baking_updated

var active_bakes: Dictionary:
	get: return GameManager.state.active_bakes

func _process(delta: float) -> void:
	var state_changed_flag = false
	for recipe_name in active_bakes.keys():
		var bake = active_bakes[recipe_name]
		if not bake.is_finished:
			bake.time_remaining -= delta
			state_changed_flag = true
			if bake.time_remaining <= 0.0:
				bake.time_remaining = 0.0
				bake.is_finished = true
	if state_changed_flag:
		baking_updated.emit()

func can_start_bake(recipe_name: String) -> bool:
	if active_bakes.has(recipe_name):
		return false
	return GameManager.can_craft(recipe_name)

func start_bake(recipe_name: String) -> bool:
	if not can_start_bake(recipe_name):
		return false
	
	var recipe = RecipeDB.get_recipe(recipe_name)
	var ingredients: Dictionary = recipe.get("ingredients", {})
	for item in ingredients.keys():
		GameManager.state.inventory[item] -= ingredients[item]

	active_bakes[recipe_name] = {
		"time_remaining": recipe.get("bake_time", 5.0),
		"is_finished": false
	}
	
	GameManager.inventory_changed.emit()
	baking_updated.emit()
	GameManager.save_game()
	return true

func harvest_bake(recipe_name: String) -> bool:
	if not active_bakes.has(recipe_name) or not active_bakes[recipe_name].is_finished:
		return false
	
	GameManager.state.bakery_stock[recipe_name] = GameManager.state.bakery_stock.get(recipe_name, 0) + 1
	active_bakes.erase(recipe_name)
	
	GameManager.inventory_changed.emit()
	baking_updated.emit()
	GameManager.save_game()
	return true
	
	
	
		
