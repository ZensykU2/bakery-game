extends Control

@onready var recipe_list: VBoxContainer = $Panel/RecipeList

func _ready() -> void:
	GameManager.inventory_changed.connect(update_buttons)
	BakingManager.baking_updated.connect(update_buttons)
	setup_recipe_buttons()

func _process(_delta: float) -> void:
	if visible and not BakingManager.active_bakes.is_empty():
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
	for button in recipe_list.get_children():
		if button is Button and button.has_meta("recipe_name"):
			var recipe_name = button.get_meta("recipe_name")
			var bake = BakingManager.active_bakes.get(recipe_name, null)
			
			if bake == null:
				button.text = "Bake %s" % recipe_name.capitalize()
				button.disabled = not GameManager.can_craft(recipe_name)
			elif not bake.is_finished:
				button.text = "Baking %s (%.1fs)" % [recipe_name.capitalize(), bake.time_remaining]
				button.disabled = true
			else:
				button.text = "%s Ready! (Right-Click)" % recipe_name.capitalize()
				button.disabled = false

func _on_recipe_button_gui_input(event: InputEvent, recipe_name: String) -> void:
	if event is InputEventMouseButton and event.pressed:
		var bake = BakingManager.active_bakes.get(recipe_name, null)
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if bake == null:
				if BakingManager.start_bake(recipe_name):
					print("Started baking!")
			elif bake.is_finished:
				print("Right-click to harvest this!")
		
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if bake != null and bake.is_finished:
				if BakingManager.harvest_bake(recipe_name):
					print("Harvested baked good!")
