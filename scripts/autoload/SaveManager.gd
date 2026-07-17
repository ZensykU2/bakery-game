extends Node

signal save_completed(slot_index: int)
signal save_failed(slot_index: int, reason: String)
signal backup_recovered(slot_index: int)

const SAVE_SLOT_TEMPLATE: String = "user://savegame_slot_%d.json"
const BACKUP_SUFFIX: String = ".bak"
const TEMP_SUFFIX: String = ".tmp"

func get_save_path(slot_index: int) -> String:
	return SAVE_SLOT_TEMPLATE % slot_index

func get_backup_path(slot_index: int) -> String:
	return get_save_path(slot_index) + BACKUP_SUFFIX

func has_save(slot_index: int) -> bool:
	return FileAccess.file_exists(get_save_path(slot_index)) \
	or FileAccess.file_exists(get_backup_path(slot_index))

func save_game(data: Dictionary, slot_index: int) -> bool:
	var save_path := get_save_path(slot_index)
	var temp_path := save_path + TEMP_SUFFIX
	var json_string := JSON.stringify(data, "\t")
	
	if not _write_temp_file(temp_path, json_string, slot_index):
		return false
	
	if not _is_valid_save_json(temp_path):
		_cleanup_file(temp_path)
		return _fail_save(slot_index, "Temporary save file could not be validated.")
	
	if not _create_backup(save_path, slot_index):
		_cleanup_file(temp_path)
		return false
	
	if not _replace_primary_with_temp(temp_path, save_path, slot_index):
		_restore_backup(save_path, slot_index)
		_cleanup_file(temp_path)
		return false
	
	save_completed.emit(slot_index)
	return true

func load_game(slot_index: int) -> Dictionary:
	var primary_data := load_primary_game(slot_index)
	if not primary_data.is_empty():
		return primary_data
	
	var backup_data := load_backup_game(slot_index)
	if not backup_data.is_empty():
		backup_recovered.emit(slot_index)
		return backup_data
	
	return {}

func load_primary_game(slot_index: int) -> Dictionary:
	return _load_data_from_path(get_save_path(slot_index))

func load_backup_game(slot_index: int) -> Dictionary:
	return _load_data_from_path(get_backup_path(slot_index))

func report_backup_recovery(slot_index: int) -> void:
	push_warning("Loaded backup save for slot %d." % slot_index)
	backup_recovered.emit(slot_index)

func delete_save(slot_index: int) -> bool:
	var removed_any := false
	for path in [get_save_path(slot_index), get_backup_path(slot_index)]:
		if FileAccess.file_exists(path):
			var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
			if error != OK:
				push_error("Failed to delete save file for slot %d, error code: %d" % [
					slot_index,
					error
				])
				return false
			removed_any = true
	
	return removed_any


func get_slot_metadata(slot_index: int) -> Dictionary:
	var data := load_game(slot_index)
	return data.get("metadata", {}) if not data.is_empty() else {}

func _write_temp_file(temp_path: String, content: String, slot_index: int) -> bool:
	_cleanup_file(temp_path)
	
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return _fail_save(slot_index, "Could not open temporary save file.")
	
	file.store_string(content)
	file.flush()
	file.close()
	return true

func _is_valid_save_json(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	
	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	file.close()
	
	return parse_error == OK and json.data is Dictionary

func _create_backup(save_path: String, slot_index: int) -> bool:
	if not FileAccess.file_exists(save_path):
		return true
	
	var backup_path := get_backup_path(slot_index)
	_cleanup_file(backup_path)
	
	var error := DirAccess.copy_absolute(
		ProjectSettings.globalize_path(save_path),
		ProjectSettings.globalize_path(backup_path)
	)
	
	if error != OK:
		return _fail_save(slot_index, "Could not create backup save file.")
	
	return true

func _replace_primary_with_temp(temp_path: String, save_path: String, slot_index: int) -> bool:
	if FileAccess.file_exists(save_path):
		var remove_error := DirAccess.remove_absolute(
			ProjectSettings.globalize_path(save_path)
		)
		
		if remove_error != OK:
			return _fail_save(slot_index, "Could not replace the existing save file.")
		
	var rename_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(temp_path),
		ProjectSettings.globalize_path(save_path)
	)
	
	if rename_error != OK:
		return _fail_save(slot_index, "Could not finalize the new save file.")
	
	return true

func _restore_backup(save_path: String, slot_index: int) -> void:
	var backup_path := get_backup_path(slot_index)
	if not FileAccess.file_exists(backup_path):
		return
	
	DirAccess.copy_absolute(
		ProjectSettings.globalize_path(backup_path),
		ProjectSettings.globalize_path(save_path)
	)

func _load_data_from_path(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	
	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	file.close()
	
	if parse_error != OK or not json.data is Dictionary:
		return {}
	
	return json.data

func _cleanup_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _fail_save(slot_index: int, reason: String) -> bool:
	push_error("Save slot %d failed: %s" % [slot_index, reason])
	save_failed.emit(slot_index, reason)
	return false
