extends Resource
class_name RecipeData

@export var recipe_id: String = ""
@export var output_item_id: String = ""
@export_range(1.0, 999.0, 1.0, "or_greater") var bake_duration_minutes: float = 1.0
@export var requirements: Array[Requirement] = []
