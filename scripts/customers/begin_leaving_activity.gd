extends CustomerActivity
class_name BeginLeavingActivity

var _is_finished: bool = false


func enter(customer: Customer) -> void:
	customer.begin_leaving()
	_is_finished = true


func is_finished(_customer: Customer) -> bool:
	return _is_finished
