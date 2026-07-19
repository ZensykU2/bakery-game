extends CharacterBody2D
class_name Customer

signal profile_assigned(profile: CustomerProfile)
signal lifecycle_changed(previous_state: int, new_state: int)

enum LifecycleState {
	SPAWNING,
	ACTIVE,
	LEAVING,
	DESPAWNED,
}

var profile: CustomerProfile
var lifecycle_state: LifecycleState = LifecycleState.SPAWNING


func initialize(customer_profile: CustomerProfile) -> void:
	profile = customer_profile
	profile_assigned.emit(profile)


func activate() -> void:
	_set_lifecycle_state(LifecycleState.ACTIVE)


func begin_leaving() -> void:
	_set_lifecycle_state(LifecycleState.LEAVING)


func mark_despawned() -> void:
	_set_lifecycle_state(LifecycleState.DESPAWNED)


func _set_lifecycle_state(next_state: LifecycleState) -> void:
	if lifecycle_state == next_state:
		return

	var previous_state := lifecycle_state
	lifecycle_state = next_state
	lifecycle_changed.emit(previous_state, lifecycle_state)

func get_navigation_controller() -> CustomerNavigationController:
	return get_node_or_null("NavigationController") as CustomerNavigationController
