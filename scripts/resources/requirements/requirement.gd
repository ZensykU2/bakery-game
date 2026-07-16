extends Resource
class_name Requirement

# Returns true if the requirement is currently met by the player
func is_met() -> bool:
	return false

# Consumes/deducts the requirement from the player's wallet/inventory/etc.
func consume() -> void:
	pass

# Returns a user-facing text description (e.g. "$10", "3x Apples")
func get_description() -> String:
	return ""
	
# Returns a texture to display alongside the description in UI (optional)
func get_icon() -> Texture2D:
	return null
	
