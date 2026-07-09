extends Control

@onready var recipe_list: VBoxContainer = $Panel/RecipeList
var current_oven_id: String = ""

func _ready() -> void:
	GameManager.inventory_changed.connect(update_buttons)
	BakingManager.baking_updated.connect(update_buttons)
	setup_recipe_buttons()

func _process(_delta: float) -> void:
	if visible:
		var bake = BakingManager.get_bake_for_oven(current_oven_id)
		if bake and not bake.is_finished:
			update_buttons()

func setup_recipe_buttons() -> void:
	for child in recipe_list.get_children():
		child.queue_free()
	
	for recipe_name in RecipeDB.recipes.keys():
		var button := Button.new()
		button.set_meta("recipe_name", recipe_name)
		
		button.gui_input.connect(_on_recipe_button_gui_input.bind(recipe_name))
		
		recipe_list.add_child(button)

	update_buttons()

func update_buttons() -> void:
	var current_bake = BakingManager.get_bake_for_oven(current_oven_id)
	
	for button in recipe_list.get_children():
		if button is Button and button.has_meta("recipe_name"):
			var recipe_name = button.get_meta("recipe_name")
			
			if current_bake == null:
				button.text = "Bake %s" % recipe_name.capitalize()
				button.disabled = not GameManager.can_craft(recipe_name)
			elif current_bake.recipe_name == recipe_name:
				if not current_bake.is_finished:
					button.text = "Baking %s (%.1fs)" % [recipe_name.capitalize(), current_bake.time_remaining]
					button.disabled = true
				else:
					button.text = "%s Ready! (Right-Click)" % recipe_name.capitalize()
					button.disabled = false
			else:
				button.text = "Oven Busy..."
				button.disabled = true

func _on_recipe_button_gui_input(event: InputEvent, recipe_name: String) -> void:
	if event is InputEventMouseButton and event.pressed:
		var current_bake = BakingManager.get_bake_for_oven(current_oven_id)
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if current_bake == null:
				if BakingManager.start_bake(current_oven_id, recipe_name):
					print("Started baking ", recipe_name, " in ", current_oven_id)
			elif current_bake.is_finished:
				print("Right-click to harvest!")

		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if current_bake != null and current_bake.recipe_name == recipe_name and current_bake.is_finished:
				if BakingManager.harvest_bake(current_oven_id):
					print("Harvested baked good!")
