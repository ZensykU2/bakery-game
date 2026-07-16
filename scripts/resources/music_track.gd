extends Resource
class_name MusicTrack

@export var stream: AudioStream
@export var volume_db: float = 0.0

# If empty, this track matches any scene. Otherwise, matches if scene path contains one of these
@export var allowed_scenes: Array[String]

@export_enum("Any", "Morning", "Day", "Evening", "Night") var time_of_day: String = "Any"

@export_enum("Any", "Spring", "Summer", "Fall", "Winter") var season: String = "Any"

@export_enum("Any", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" ) var weekday: String = "Any"

@export_enum("Any", "Sunny", "Rainy", "Snowy", "Windy") var weather: String = "Any"

@export var priority: int = 0
