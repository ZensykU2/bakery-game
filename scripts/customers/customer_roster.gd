extends Resource
class_name CustomerRoster

@export var resident_profiles: Array[CustomerProfile] = []

func get_resident_template(customer_id: String) -> CustomerProfile:
	for profile in resident_profiles:
		if profile != null and profile.customer_id == customer_id:
			return profile
	
	return null

func create_runtime_profile(customer_id: String) -> CustomerProfile:
	var template := get_resident_template(customer_id)
	
	if template == null:
		return null
	
	# Runtime customers must not mutate the authored resident asset.
	return CustomerProfile.from_dict(template.to_dict())

func validate() -> Array[String]:
	var errors: Array[String] = []
	var known_ids: Dictionary[String, bool] = {}
	
	for profile in resident_profiles:
		if profile == null:
			errors.append("Resident roster contains an empty profile.")
			continue
	
		if profile.customer_id.is_empty():
			errors.append("Resident roster contains a profile without an ID")
			continue
		
		if known_ids.has(profile.customer_id):
			errors.append("Duplicate resident ID: %s" % profile.customer_id)
		
		if not profile.is_resident():
			errors.append(
				"Resident '%s' must use RESIDENT origin." % profile.customer_id
			)
		
		known_ids[profile.customer_id] = true
	
	return errors
