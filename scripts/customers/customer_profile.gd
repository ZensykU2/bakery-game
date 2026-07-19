extends Resource
class_name CustomerProfile

@export var customer_id: String = ""
@export var display_name: String = ""

@export var origin: Origin = Origin.RESIDENT
@export var age_group: AgeGroup = AgeGroup.ADULT
@export var wealth_tier: WealthTier = WealthTier.STANDARD
@export var personality: Personality = Personality.FRIENDLY

@export var generation_seed: int = 0

# Used later by the persistent tourist-roster system.
var visit_count: int = 0
var last_selected_day: int = 0

enum Origin {
	RESIDENT,
	TOURIST,
}

enum AgeGroup {
	CHILD,
	TEENAGER,
	YOUNG_ADULT,
	ADULT,
	OLDER_ADULT,
}

enum WealthTier {
	POOR,
	STANDARD,
	AFFLUENT,
}

enum Personality {
	FRIENDLY,
	PATIENT,
	HURRIED,
	FRUGAL,
	FOODIE,
	TRADITIONAL,
}



func is_resident() -> bool:
	return origin == Origin.RESIDENT

func is_tourist() -> bool:
	return origin == Origin.TOURIST

func to_dict() -> Dictionary:
	return {
		"customer_id": customer_id,
		"display_name": display_name,
		"origin": origin,
		"age_group": age_group,
		"wealth_tier": wealth_tier,
		"personality": personality,
		"visit_count": visit_count,
		"last_selected_day": last_selected_day,
		"generation_seed": generation_seed,
	}

static func from_dict(data: Dictionary) -> CustomerProfile:
	var profile := CustomerProfile.new()
	profile.customer_id = String(data.get("customer_id", ""))
	profile.display_name = String(data.get("display_name", ""))
	
	profile.origin = clampi(
		int(data.get("origin", Origin.RESIDENT)),
		Origin.RESIDENT,
		Origin.TOURIST
	)
	profile.age_group = clampi(
		int(data.get("age_group", AgeGroup.YOUNG_ADULT)),
		AgeGroup.CHILD,
		AgeGroup.OLDER_ADULT
	)
	profile.wealth_tier = clampi(
		int(data.get("wealth_tier", WealthTier.STANDARD)),
		WealthTier.POOR,
		WealthTier.AFFLUENT,
	)
	profile.personality = clampi(
		int(data.get("personality", Personality.FRIENDLY)),
		Personality.FRIENDLY,
		Personality.TRADITIONAL,
	)
	
	profile.visit_count = maxi(0, int(data.get("visit_count", 0)))
	profile.last_selected_day = maxi(0, int(data.get("last_selected_day", 0)))
	profile.generation_seed = int(data.get("generation_seed", 0))
	return profile
