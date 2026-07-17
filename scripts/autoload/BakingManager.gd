extends Node

signal baking_updated

var active_bakes: Dictionary:
	get: return GameManager.state.active_bakes

func _ready() -> void:
	TimeManager.minutes_passed.connect(_on_time_minutes_passed)

func _on_time_minutes_passed(elapsed_minutes: int) -> void:
	var state_changed := false
	var bake_completed := false

	for oven_id in active_bakes.keys():
		var bake = active_bakes[oven_id]

		if bake is BakeStrategy:
			var was_finished = bake.is_finished

			if bake.tick(elapsed_minutes):
				state_changed = true

			if not was_finished and bake.is_finished:
				bake_completed = true

	if state_changed:
		baking_updated.emit()

	if bake_completed:
		GameManager.save_game()

func get_bake_for_oven(oven_id: String) -> Variant:
	return active_bakes.get(oven_id, null)

func can_start_bake(oven_id: String, recipe_id: String) -> bool:
	if active_bakes.has(oven_id):
		return false
	return CraftingService.can_craft(recipe_id)

func start_bake(oven_id: String, recipe_id: String) -> bool:
	if not can_start_bake(oven_id, recipe_id):
		return false

	var recipe := ItemDB.get_recipe_resource(recipe_id)
	if recipe == null:
		return false
	
	if not CraftingService.try_consume_requirements(recipe_id):
		return false

	var strategy = BakeStrategy.new()
	strategy.recipe_id = recipe_id
	strategy.time_remaining = recipe.bake_duration_minutes
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
	
	var recipe := ItemDB.get_recipe_resource(bake.recipe_id)
	if recipe == null:
		push_error("BakingManager: Missing recipe '%s' while harvesting." % bake.recipe_id)
		return false
	
	if InventoryManager.add_item(recipe.output_item_id, 1):
		active_bakes.erase(oven_id)
		baking_updated.emit()
		GameManager.save_game()
		return true
	else:
		print("Inventory Full! Cannot harvest.")
		return false
