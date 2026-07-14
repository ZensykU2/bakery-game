extends Node

signal baking_updated

var active_bakes: Dictionary:
	get: return GameManager.state.active_bakes

func _ready() -> void:
	Services.baking = self

func _process(delta: float) -> void:
	var state_changed_flag = false
	for oven_id in active_bakes.keys():
		var bake = active_bakes[oven_id]
		if bake is BakeStrategy:
			if bake.tick(delta):
				state_changed_flag = true
	if state_changed_flag:
		baking_updated.emit()

func get_bake_for_oven(oven_id: String) -> Variant:
	return active_bakes.get(oven_id, null)

func can_start_bake(oven_id: String, recipe_name: String) -> bool:
	if active_bakes.has(oven_id):
		return false
	return CraftingService.can_craft(recipe_name)

func start_bake(oven_id: String, recipe_name: String) -> bool:
	if not can_start_bake(oven_id, recipe_name):
		return false
	
	CraftingService.consume_ingredients(recipe_name)

	var recipe = ItemDB.get_recipe(recipe_name)
	var strategy = BakeStrategy.new()
	strategy.recipe_name = recipe_name
	strategy.time_remaining = recipe.get("bake_time", 5.0)
	strategy.is_finished = false
	
	active_bakes[oven_id] = strategy
	
	InventoryManager.inventory_changed.emit()
	baking_updated.emit()
	GameManager.save_game()
	return true

func try_harvest(oven_id: String) -> bool:
	if not active_bakes.has(oven_id):
		return false
	var bake = active_bakes[oven_id]
	if not bake.is_finished:
		return false
	
	if InventoryManager.add_item(bake.recipe_name, 1):
		active_bakes.erase(oven_id)
		baking_updated.emit()
		GameManager.save_game()
		return true
	else:
		print("Inventory Full! Cannot harvest.")
		return false
