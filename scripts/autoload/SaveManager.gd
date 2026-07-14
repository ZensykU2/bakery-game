extends Node

const SAVE_SLOT_TEMPLATE: String = "user://savegame_slot_%d.json"

func get_save_path(slot_index: int) -> String:
	return SAVE_SLOT_TEMPLATE % slot_index

func save_game(data: Dictionary, slot_index: int) -> bool:
	var file = FileAccess.open(get_save_path(slot_index), FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file for writing on slot %d" % slot_index)
		return false

	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	return true

func delete_save(slot_index: int) -> bool:
	var path = get_save_path(slot_index)
	if FileAccess.file_exists(path):
		var error = DirAccess.remove_absolute(path)
		if error == OK:
			return true
		else:
			push_error("Failed to delete save file for slot %d, error code: %d" % [slot_index, error])
			return false
	return false
		

func load_game(slot_index: int) -> Dictionary:
	var path = get_save_path(slot_index)
	if not FileAccess.file_exists(path):
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open save file for reading on slot %d" % slot_index)
		return {}

	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(content)

	if error != OK:
		push_error("Failed to parse save file on slot %d" % slot_index)
		return {}

	return json.data if json.data is Dictionary else {}

func get_slot_metadata(slot_index: int) -> Dictionary:
	var path = get_save_path(slot_index)
	if not FileAccess.file_exists(path):
		return {}
		
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
		
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(content) == OK and json.data is Dictionary:
		return json.data.get("metadata", {})
	return {}
