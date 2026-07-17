extends RefCounted
class_name SaveMigrator

const CURRENT_VERSION: int = 2

static func migrate(raw_data: Dictionary) -> Dictionary:
	if raw_data.is_empty():
		return {}
	
	var migrated := raw_data.duplicate(true)
	var version := int(migrated.get("save_version", 0))

	if version < 0 or version > CURRENT_VERSION:
		push_error("Unsupported save version: %d" % version)
		return {}

	while version < CURRENT_VERSION:
		match version:
			0:
				migrated = _migrate_v0_to_v1(migrated)
			1:
				migrated = _migrate_v1_to_v2(migrated)
			_:
				push_error("Unsupported save version: %d" % version)
				return {}

		version += 1

	migrated["save_version"] = CURRENT_VERSION
	
	if not _is_valid_current_save(migrated):
		return _invalid_save("Current save has invalid structure.")
	
	return migrated


static func _migrate_v0_to_v1(legacy_data: Dictionary) -> Dictionary:
	var game_state := legacy_data.duplicate(true)
	game_state.erase("metadata")
	game_state.erase("save_version")

	return {
		"save_version": 1,
		"game_state": game_state,
		"clock": {
			"time_in_minutes": GameConstants.TimeManage.DEFAULT_START_TIME
		},
		"metadata": legacy_data.get("metadata", {})
	}

static func _migrate_v1_to_v2(save_data: Dictionary) -> Dictionary:
	save_data["location"] = {}
	return save_data

static func _is_valid_v0_save(data: Dictionary) -> bool:
	return data.has("day") and data.has("money")

static func _is_valid_v1_save(data: Dictionary) -> bool:
	return _has_dictionary(data, "game_state") \
	and _has_dictionary(data, "clock") \
	and _has_dictionary(data, "metadata")

static func _is_valid_current_save(data: Dictionary) -> bool:
	if not _has_dictionary(data, "game_state"):
		return false
	
	var game_state: Dictionary = data["game_state"]
	
	return game_state.has("day") \
	and game_state.has("money") \
	and _has_dictionary(data, "clock") \
	and _has_dictionary(data, "location") \
	and _has_dictionary(data, "metadata")
	
static func _has_dictionary(data: Dictionary, key: String) -> bool:
	return data.has(key) and data[key] is Dictionary

static func _invalid_save(reason: String) -> Dictionary:
	push_error("Invalid save: %s" % reason)
	return {}
