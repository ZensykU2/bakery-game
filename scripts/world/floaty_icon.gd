extends Sprite2D

func start(item_texture: Texture2D) -> void:
	self.texture = item_texture
	
	self.z_index = 10
	
	self.scale = Vector2.ZERO
	self.modulate = Color(1, 1, 1, 0) 
	
	var tween = create_tween().set_parallel(true)
	
	var target_pos = position - Vector2(0, 24)
	tween.tween_property(self, "position", target_pos, 0.5)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
		
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3)
	
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.4)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	tween.chain().set_parallel(false)

	await get_tree().create_timer(1.2).timeout
	
	
	var fade_out = create_tween().set_parallel(true)
	fade_out.tween_property(self, "position", target_pos - Vector2(0, 12), 0.4)
	fade_out.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.4)
	await fade_out.finished
	
	queue_free()
