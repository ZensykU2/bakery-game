extends Node

signal baking_updated

var active_bakes: Dictionary:
	get: return GameManager.state.active_bakes

func _process(delta: float) -> void:
	var state_changed_flag = false
	for oven_id in active_bakes.keys():
		var bake = active_bakes[oven_id]
		if not bake.is_finished:
			bake.time_remaining -= delta
			state_changed_flag = true
			if bake.time_remaining <= 0.0:
				bake.time_remaining = 0.0
				bake.is_finished = true
	if state_changed_flag:
		baking_updated.emit()

func get_bake_for_oven(oven_id: String) -> Variant:
	return active_bakes.get(oven_id, null)

func can_start_bake(oven_id: String, recipe_name: String) -> bool:
	if active_bakes.has(oven_id):
		return false
	return GameManager.can_craft(recipe_name)

func start_bake(oven_id: String, recipe_name: String) -> bool:
	if not can_start_bake(oven_id, recipe_name):
		return false
	
	var recipe = RecipeDB.get_recipe(recipe_name)
	var ingredients: Dictionary = recipe.get("ingredients", {})
	for item in ingredients.keys():
		GameManager.state.inventory[item] -= ingredients[item]

	active_bakes[oven_id] = {
		"recipe_name": recipe_name,
		"time_remaining": recipe.get("bake_time", 5.0),
		"is_finished": false
	}
	
	GameManager.inventory_changed.emit()
	baking_updated.emit()
	GameManager.save_game()
	return true

func harvest_bake(oven_id: String) -> bool:
	if not active_bakes.has(oven_id):
		return false
	var bake = active_bakes[oven_id]
	if not bake.is_finished:
		return false
	
	var recipe_name = bake.recipe_name
	GameManager.state.bakery_stock[recipe_name] = GameManager.state.bakery_stock.get(recipe_name, 0) + 1
	active_bakes.erase(oven_id)
	
	GameManager.inventory_changed.emit()
	baking_updated.emit()
	GameManager.save_game()
	return true
	
	
	
		
