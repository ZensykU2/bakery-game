extends UnlockCondition
class_name DayReachedCondition

@export var required_day: int = 1

func is_unlocked() -> bool:
	return GameManager.get_day() >= required_day

func get_lock_description() -> String:
	return "Unlocks on Day %d" % required_day
