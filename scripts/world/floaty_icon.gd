extends Sprite2D

signal harvested

@onready var click_area: Area2D = $ClickArea
@onready var floaty_label: Label = $FloatyLabel

var item_id: String = ""

func start(recipe_id: String, item_texture: Texture2D) -> void:
	item_id = recipe_id
	self.texture = item_texture
	self.z_index = 10
	
	if floaty_label:
		floaty_label.text = ""
		
	click_area.input_event.connect(_on_click_area_input_event)
	_run_pop_animation()

func start_text(text: String, text_color: Color = Color.WHITE) -> void:
	self.texture = null 
	self.z_index = 12   
	
	click_area.input_pickable = false
	
	if floaty_label:
		floaty_label.text = text
		floaty_label.add_theme_color_override("font_color", text_color)
		
	_run_pop_animation()

func _run_pop_animation() -> void:
	self.scale = Vector2.ZERO
	self.modulate.a = 0.0
	
	var tween = create_tween().set_parallel(true)
	var target_pos = position - Vector2(0, 24)
	
	tween.tween_property(self, "position", target_pos, 0.5)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.4)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
		
	if item_id == "":
		tween.chain().set_parallel(false)
		tween.tween_interval(1.0) 
		
		var fade_out = tween.chain().set_parallel(true)
		fade_out.tween_property(self, "position:y", target_pos.y - 16.0, 0.4)
		fade_out.tween_property(self, "modulate:a", 0.0, 0.4)
		
		tween.chain().tween_callback(queue_free)

func _on_click_area_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_harvest_item()

func _harvest_item() -> void:
	var player = SceneManager.get_player()
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance > GameConstants.World.HARVEST_DISTANCE:
			print("Too far away to harvest!")
			return
	
	if InventoryManager.add_item(item_id, 1):
		print("Harvested item into slots: ", item_id)
		harvested.emit()
		
		var tween = create_tween().set_parallel(true)
		tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
		tween.tween_property(self, "modulate:a", 0.0, 0.2)
		await tween.finished
		queue_free()
	else:
		print("Inventory Full! Cannot harvest.")
