extends Sprite2D

signal harvest_requested

@onready var click_area: Area2D = $ClickArea
@onready var floaty_label: Label = $FloatyLabel

var item_id: String = ""

func start(recipe_id: String, item_texture: Texture2D) -> void:
	item_id = recipe_id
	self.texture = item_texture
	self.z_index = 10
	
	if floaty_label:
		floaty_label.text = ""
		floaty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	click_area.input_event.connect(_on_click_area_input_event)
	_run_pop_animation()

func start_text(text: String, text_color: Color = Color.WHITE) -> void:
	self.texture = null 
	self.z_index = 12   
	
	click_area.input_pickable = false
	
	if floaty_label:
		floaty_label.text = text
		floaty_label.add_theme_color_override("font_color", text_color)
		floaty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	_run_pop_animation()

func _run_pop_animation() -> void:
	self.modulate.a = 0.0
	
	var tween = create_tween().set_parallel(true)
	var target_pos = position - Vector2(0, 24)
	
	tween.tween_property(self, "position", target_pos, 0.5)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3)
		
	if item_id == "":
		tween.chain().set_parallel(false)
		tween.tween_interval(1.0) 
		
		var fade_out = tween.chain().set_parallel(true)
		fade_out.tween_property(self, "position:y", target_pos.y - 16.0, 0.4)
		fade_out.tween_property(self, "modulate:a", 0.0, 0.4)
		
		tween.chain().tween_callback(queue_free)

func _on_click_area_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		print("Floaty ClickArea received event: button_index=", event.button_index, " pressed=", event.pressed)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			harvest_requested.emit()

func play_harvest_animation() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished
	queue_free()
