extends Node
class_name SfxPlayerComponent

@export var sfx_stream: AudioStream = null
@export var volume_db: float = 0.0
@export var pitch_scale: float = 1.0
@export var pitch_randomness: float = 0.0

func play_sound() -> void:
	if not sfx_stream:
		return
	
	var final_pitch = pitch_scale 
	if pitch_randomness > 0.0:
		final_pitch += randf_range(-pitch_randomness, pitch_randomness)
		
		SfxManager.play_sfx(sfx_stream, volume_db, final_pitch)
