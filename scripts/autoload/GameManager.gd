extends Node

signal state_changed
signal inventory_changed
signal money_changed(new_money: int)
signal day_changed(new_day: int)

var state: GameState = GameState.new()

func _ready() -> void:
	load_game()

func sell_item(recipe_name: String) -> bool:
	if state.bakery_stock.get(recipe_name, 0) <= 0:
		return false
	
	state.bakery_stock[recipe_name] -= 1
	var price = RecipeDB.get_recipe(recipe_name).get("sell_price", 0)
	add_money(price)
	
	inventory_changed.emit()
	save_game()
	return true

func new_game() -> void:
	state = GameState.new()
	_emit_all_signals()

func save_game() -> void:
	SaveManager.save_game(state.to_dict())

func load_game() -> void:
	var data = SaveManager.load_game()
	if data.is_empty():
		state = GameState.new()
	else:
		state = GameState.new()
		state.from_dict(data)

	_emit_all_signals()

func can_craft(recipe_name: String) -> bool:
	if not RecipeDB.has_recipe(recipe_name):
		return false

	var recipe = RecipeDB.get_recipe(recipe_name)
	var ingredients: Dictionary = recipe.get("ingredients", {})

	for item in ingredients.keys():
		if state.inventory.get(item, 0) < ingredients[item]:
			return false

	return true

func next_day() -> void:
	state.day += 1
	state.inventory["berries"] = state.inventory.get("berries", 0) + 1
	state.inventory["eggs"] = state.inventory.get("eggs", 0) + 1

	day_changed.emit(state.day)
	inventory_changed.emit()
	state_changed.emit()
	save_game()

func add_money(amount: int) -> void:
	state.money += amount
	money_changed.emit(state.money)
	state_changed.emit()
	save_game()

func add_item(item_name: String, amount: int) -> void:
	state.inventory[item_name] = state.inventory.get(item_name, 0) + amount
	inventory_changed.emit()
	state_changed.emit()
	save_game()

func get_day() -> int:
	return state.day

func get_money() -> int:
	return state.money

func get_inventory() -> Dictionary:
	return state.inventory

func get_bakery_stock() -> Dictionary:
	return state.bakery_stock

func _emit_all_signals() -> void:
	day_changed.emit(state.day)
	money_changed.emit(state.money)
	inventory_changed.emit()
	state_changed.emit()
