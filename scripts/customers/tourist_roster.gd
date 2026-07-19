extends RefCounted
class_name TouristRoster

var profiles: Array[CustomerProfile] = []
var _profile_factory := TouristProfileFactory.new()


func ensure_population(
		current_day: int,
		rng: RandomNumberGenerator = null
	) -> void:
	var active_rng := _get_rng(rng)
	var existing_ids := _get_existing_ids()
	while profiles.size() < GameConstants.Customers.MAX_TOURISTS:
		var profile := _profile_factory.create_profile(active_rng, current_day, existing_ids)
		profiles.append(profile)
		existing_ids[profile.customer_id] = true


func refresh_population(
		current_day: int,
		rng: RandomNumberGenerator = null
	) -> void:
	retire_inactive(current_day)
	ensure_population(current_day, rng)


func select_tourist(
		current_day: int,
		excluded_ids: Array[String] = [],
		rng: RandomNumberGenerator = null
	) -> CustomerProfile:
	refresh_population(current_day, rng)
	var eligible_profiles: Array[CustomerProfile] = []
	for profile in profiles:
		if not excluded_ids.has(profile.customer_id):
			eligible_profiles.append(profile)

	if eligible_profiles.is_empty():
		return null

	var active_rng := _get_rng(rng)
	var selected := eligible_profiles[active_rng.randi_range(0, eligible_profiles.size() - 1)]
	selected.visit_count += 1
	selected.last_selected_day = current_day
	return selected


func retire_inactive(current_day: int) -> int:
	var remaining_profiles: Array[CustomerProfile] = []
	var retired_count := 0
	for profile in profiles:
		var inactive_days := current_day - profile.last_selected_day
		if inactive_days >= GameConstants.Customers.TOURIST_RETIRE_AFTER_DAYS:
			retired_count += 1
			continue
		remaining_profiles.append(profile)
	profiles = remaining_profiles
	return retired_count


func to_dict() -> Dictionary:
	var saved_profiles: Array[Dictionary] = []
	for profile in profiles:
		if profile != null and profile.is_tourist():
			saved_profiles.append(profile.to_dict())
	return {"profiles": saved_profiles}


func from_dict(data: Dictionary) -> void:
	profiles.clear()
	var saved_profiles: Array = data.get("profiles", [])
	for saved_profile in saved_profiles:
		if saved_profile is Dictionary:
			var profile := CustomerProfile.from_dict(saved_profile)
			if profile.is_tourist() and not profile.customer_id.is_empty():
				profiles.append(profile)


func _get_existing_ids() -> Dictionary[String, bool]:
	var existing_ids: Dictionary[String, bool] = {}
	for profile in profiles:
		if profile != null:
			existing_ids[profile.customer_id] = true
	return existing_ids


func _get_rng(provided_rng: RandomNumberGenerator) -> RandomNumberGenerator:
	if provided_rng != null:
		return provided_rng
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return rng
