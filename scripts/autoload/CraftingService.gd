extends Node

func can_craft(recipe_id: String) -> bool:
	if not ItemDB.has_recipe(recipe_id):
		return false

	for requirement in ItemDB.get_recipe_requirements(recipe_id):
		if requirement and not requirement.is_met():
			return false
			
	return true

func consume_requirements(recipe_id: String) -> void:
	try_consume_requirements(recipe_id)


func try_consume_requirements(recipe_id: String) -> bool:
	if not ItemDB.has_recipe(recipe_id):
		return false

	var requirements := ItemDB.get_recipe_requirements(recipe_id)
	for requirement in requirements:
		if requirement and not requirement.is_met():
			return false

	for requirement in requirements:
		if requirement:
			requirement.consume()

	return true
