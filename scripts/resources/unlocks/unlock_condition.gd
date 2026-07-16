extends Resource
class_name UnlockCondition

# Returns true if this condition has been met to unlock the item/action
func is_unlocked() -> bool:
	return true

# Returns a user-facing explanation of the unlock requirement (e.g. "Unlocks at Day 3")
func get_lock_description() -> String:
	return ""
