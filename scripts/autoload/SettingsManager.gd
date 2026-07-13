extends Node

const SETTINGS_FILE: String = "user://settings.json"

var master_volume: float = 0.8
var music_volume: float = 0.8
var sfx_volume: float = 0.8
var window_mode: int = 0 # 0 = Windowed, 1 = Fullscreen

func _ready() -> void:
	load_settings()

func apply_settings() -> void:
	if window_mode == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	_set_bus_volume("Master", master_volume)
	_set_bus_volume("Music", music_volume)
	_set_bus_volume("SFX", sfx_volume)

func _set_bus_volume(bus_name: String, volume_linear: float) -> void:
	var index = AudioServer.get_bus_index(bus_name)
	if index != -1:
		var db = linear_to_db(clamp(volume_linear, 0.0001, 1.0))
		AudioServer.set_bus_volume_db(index, db)
		AudioServer.set_bus_mute(index, volume_linear <= 0.01)

func save_settings() -> void:
	var data = {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"window_mode": window_mode,
	}
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_FILE):
		apply_settings()
		return

	var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		if json.parse(content) == OK and json.data is Dictionary:
			var data = json.data
			master_volume = data.get("master_volume", 0.8)
			music_volume = data.get("music_volume", 0.8)
			sfx_volume = data.get("sfx_volume", 0.8)
			window_mode = data.get("window_mode", 0)
	
	apply_settings()
	
	
	
	
	
	
	
	
	
		
		
