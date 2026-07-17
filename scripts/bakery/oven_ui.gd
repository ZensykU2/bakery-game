extends Control

@onready var recipe_list: VBoxContainer = $Panel/RecipeList
var current_oven_id: String = ""

func _ready() -> void:
	add_to_group(UIOverlayManager.OVERLAY_GROUP)
	InventoryManager.inventory_changed.connect(update_buttons)
	BakingManager.baking_updated.connect(update_buttons)
	setup_recipe_buttons()

func open_for_oven(oven_id: String) -> void:
	current_oven_id = oven_id
	update_buttons()
	visible = true

func setup_recipe_buttons() -> void:
	for child in recipe_list.get_children():
		child.queue_free()
	
	for recipe_id in ItemDB.get_recipe_names():
		var button := Button.new()
		button.set_meta("recipe_id", recipe_id)
		
		button.gui_input.connect(_on_recipe_button_gui_input.bind(recipe_id))
		
		recipe_list.add_child(button)

	update_buttons()

func update_buttons() -> void:
	var current_bake = BakingManager.get_bake_for_oven(current_oven_id)
	
	for button in recipe_list.get_children():
		if button is Button and button.has_meta("recipe_id"):
			var recipe_id: String = button.get_meta("recipe_id")
			var recipe := ItemDB.get_recipe_resource(recipe_id)
			var recipe_name := recipe.output_item_id if recipe else recipe_id
			
			if current_bake == null:
				button.text = "Bake %s" % recipe_name.capitalize()
				button.disabled = not CraftingService.can_craft(recipe_id)
			elif current_bake.recipe_id == recipe_id:
				if not current_bake.is_finished:
					button.text = "Baking %s (%.0fm)" % [recipe_name.capitalize(), current_bake.time_remaining]
					button.disabled = true
				else:
					button.text = "%s Ready! (Right-Click)" % recipe_name.capitalize()
					button.disabled = false
			else:
				button.text = "Oven Busy..."
				button.disabled = true

func _on_recipe_button_gui_input(event: InputEvent, recipe_id: String) -> void:
	if event is InputEventMouseButton and event.pressed:
		var current_bake = BakingManager.get_bake_for_oven(current_oven_id)
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if current_bake == null:
				if BakingManager.start_bake(current_oven_id, recipe_id):
					print("Started baking ", recipe_id, " in ", current_oven_id)
			elif current_bake.is_finished:
				print("Right-click to harvest!")

		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if current_bake != null and current_bake.recipe_id == recipe_id and current_bake.is_finished:
				if BakingManager.try_harvest(current_oven_id):
					print("Harvested baked good!")


func close_overlay() -> void:
	visible = false


func is_overlay_open() -> bool:
	return visible


func _unhandled_input(event: InputEvent) -> void:
	if visible and (
		event.is_action_pressed("toggle_inventory")
		or event.is_action_pressed("ui_cancel")
		or event.is_action_pressed("ui_accept")
	):
		close_overlay()
		get_viewport().set_input_as_handled()
