extends RefCounted
class_name CustomerVisitPlanner


func create_visit_request(
		resident_roster: CustomerRoster,
		tourist_roster: TouristRoster,
		current_day: int,
		minute_of_day: int,
		tourist_probability: float,
		rng: RandomNumberGenerator,
		excluded_customer_ids: Array[String] = []
	) -> CustomerVisitRequest:
	var profile := _select_profile(
		resident_roster,
		tourist_roster,
		current_day,
		tourist_probability,
		rng,
		excluded_customer_ids
	)
	if profile == null:
		return null
	return CustomerVisitRequest.new(profile, current_day, minute_of_day)


func _select_profile(
		resident_roster: CustomerRoster,
		tourist_roster: TouristRoster,
		current_day: int,
		tourist_probability: float,
		rng: RandomNumberGenerator,
		excluded_customer_ids: Array[String]
	) -> CustomerProfile:
	var use_tourist := rng.randf() < clampf(tourist_probability, 0.0, 1.0)
	if use_tourist:
		var tourist := tourist_roster.select_tourist(current_day, excluded_customer_ids, rng)
		if tourist != null:
			return tourist

	var resident := _select_resident(resident_roster, rng, excluded_customer_ids)
	if resident != null:
		return resident

	return tourist_roster.select_tourist(current_day, excluded_customer_ids, rng)


func _select_resident(
		resident_roster: CustomerRoster,
		rng: RandomNumberGenerator,
		excluded_customer_ids: Array[String]
	) -> CustomerProfile:
	if resident_roster == null or resident_roster.resident_profiles.is_empty():
		return null

	var valid_ids: Array[String] = []
	for profile in resident_roster.resident_profiles:
		if (
			profile != null
			and not profile.customer_id.is_empty()
			and not excluded_customer_ids.has(profile.customer_id)
		):
			valid_ids.append(profile.customer_id)

	if valid_ids.is_empty():
		return null

	var selected_id := valid_ids[rng.randi_range(0, valid_ids.size() - 1)]
	return resident_roster.create_runtime_profile(selected_id)
