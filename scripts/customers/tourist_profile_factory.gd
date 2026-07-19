extends RefCounted
class_name TouristProfileFactory

const FIRST_NAMES := ["Ari", "Clara", "Emil", "Fina", "Jonas", "Lina", "Mara", "Noel", "Sami", "Tessa"]
const LAST_NAMES := ["Berg", "Falk", "Keller", "Linden", "Meier", "Roth", "Stern", "Vogel"]


func create_profile(
		rng: RandomNumberGenerator,
		current_day: int,
		existing_ids: Dictionary[String, bool]
	) -> CustomerProfile:
	var profile := CustomerProfile.new()
	profile.customer_id = _create_unique_id(rng, existing_ids)
	profile.display_name = "%s %s" % [
		FIRST_NAMES[rng.randi_range(0, FIRST_NAMES.size() - 1)],
		LAST_NAMES[rng.randi_range(0, LAST_NAMES.size() - 1)],
	]
	profile.origin = CustomerProfile.Origin.TOURIST
	profile.age_group = rng.randi_range(
		CustomerProfile.AgeGroup.CHILD,
		CustomerProfile.AgeGroup.OLDER_ADULT
	)
	profile.wealth_tier = rng.randi_range(
		CustomerProfile.WealthTier.POOR,
		CustomerProfile.WealthTier.AFFLUENT
	)
	profile.personality = rng.randi_range(
		CustomerProfile.Personality.FRIENDLY,
		CustomerProfile.Personality.TRADITIONAL
	)
	profile.generation_seed = rng.randi()
	profile.last_selected_day = current_day
	return profile


func _create_unique_id(
		rng: RandomNumberGenerator,
		existing_ids: Dictionary[String, bool]
	) -> String:
	var candidate_id := ""
	while candidate_id.is_empty() or existing_ids.has(candidate_id):
		candidate_id = "tourist_%s" % str(rng.randi())
	return candidate_id
