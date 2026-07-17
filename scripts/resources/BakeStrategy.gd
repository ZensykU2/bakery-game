extends Resource
class_name BakeStrategy

@export var recipe_id: String = ""
@export var time_remaining: float = 0.0
@export var is_finished: bool = false

func to_dict() -> Dictionary:
	return {
		"strategy_type": "timer",
		"recipe_id": recipe_id,
		"time_remaining": time_remaining,
		"is_finished": is_finished
	}

func from_dict(data: Dictionary) -> void:
	recipe_id = data.get("recipe_id", data.get("recipe_name", ""))
	time_remaining = data.get("time_remaining", 0.0)
	is_finished = data.get("is_finished", false)

func tick(elapsed_minutes: int) -> bool:
	if is_finished or elapsed_minutes <= 0:
		return false
	
	# Remaining in-game minutes.
	time_remaining -= float(elapsed_minutes)

	if time_remaining <= 0.0:
		time_remaining = 0.0
		is_finished = true

	return true

static func create_from_dict(data: Dictionary) -> BakeStrategy:
	var type = data.get("strategy_type", "timer")
	var strategy: BakeStrategy
	match type:
		"timer":
			strategy = BakeStrategy.new()
		# Add future strategies here (e.g. perishable, QTE, etc.)
		_:
			strategy = BakeStrategy.new()
			
	strategy.from_dict(data)
	return strategy
