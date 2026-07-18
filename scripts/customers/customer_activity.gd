extends RefCounted
class_name CustomerActivity

func enter(_customer: Customer) -> void:
	pass

func tick(_customer: Customer, _delta: float) -> void:
	pass

func exit(_customer: Customer) -> void:
	pass

func is_finished(_customer: Customer) -> bool:
	return false
