extends Node

func save_game(data: Dictionary) -> bool:
	var file = FileAccess.open(GameConstants.Paths.SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file for writing.")
		return false

	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	return true

func load_game() -> Dictionary:
	if not FileAccess.file_exists(GameConstants.Paths.SAVE_PATH):
		return {}

	var file = FileAccess.open(GameConstants.Paths.SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open save file for reading.")
		return {}

	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)

	if error != OK:
		push_error("Failed to parse save file.")
		return {}

	return json.data if json.data is Dictionary else {}
