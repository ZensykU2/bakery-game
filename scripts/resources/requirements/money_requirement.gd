extends Requirement
class_name MoneyRequirement

@export var amount: int = 0

func is_met() -> bool:
	return GameManager.get_money() >= amount

func consume() -> void:
	GameManager.add_money(-amount)

func get_description() -> String:
	return "$%d" % amount
