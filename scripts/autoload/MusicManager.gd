extends Node

@export var track_list: Array[MusicTrack] = []

var player_a: AudioStreamPlayer
var player_b: AudioStreamPlayer
var current_player: AudioStreamPlayer = null
var current_track: MusicTrack = null
var active_tween: Tween = null

# Stores the playback position (seconds) keyed by the track's file path
var playback_positions: Dictionary = {}

# Guard to prevent signal storming in a single frame
var _is_evaluation_queued: bool = false

func _ready() -> void:
	# Instantiate two players routed to the "Music" bus for crossfades
	player_a = AudioStreamPlayer.new()
	player_a.bus = GameConstants.Audio.BUS_MUSIC
	player_a.volume_db = -GameConstants.Audio.FADE_VOL
	add_child(player_a)
	
	player_b = AudioStreamPlayer.new()
	player_b.bus = GameConstants.Audio.BUS_MUSIC
	player_b.volume_db = -GameConstants.Audio.FADE_VOL
	add_child(player_b)
	
	current_player = player_a

	
	SceneManager.scene_changed.connect(func(_path): queue_evaluation())
	TimeManager.time_changed.connect(func(_h, _m): queue_evaluation())
	GameManager.day_changed.connect(func(_d): 
		playback_positions.clear()
		queue_evaluation()
	)
	
	_load_all_tracks()
	queue_evaluation()

func get_resolved_path(path: String) -> String:
	if path.begins_with("uid://"):
		var id = ResourceUID.text_to_id(path)
		return ResourceUID.get_id_path(id)
	return path

func _load_all_tracks() -> void:
	var dir_path = "res://resources/music/"
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var track = load(dir_path + file_name)
				if track is MusicTrack:
					track_list.append(track)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		DirAccess.make_dir_absolute(dir_path)

func get_time_of_day_name(hour: int) -> String:
	if hour >= GameConstants.TimeManage.HOUR_MORNING_START and hour < GameConstants.TimeManage.HOUR_DAY_START:
		return GameConstants.Audio.TIME_MORNING
	elif hour >= GameConstants.TimeManage.HOUR_DAY_START and hour < GameConstants.TimeManage.HOUR_EVENING_START:
		return GameConstants.Audio.TIME_DAY
	elif hour >= GameConstants.TimeManage.HOUR_EVENING_START and hour < GameConstants.TimeManage.HOUR_NIGHT_START:
		return GameConstants.Audio.TIME_EVENING
	else:
		return GameConstants.Audio.TIME_NIGHT

func queue_evaluation() -> void:
	if _is_evaluation_queued:
		return
	
	_is_evaluation_queued = true
	call_deferred("_deferred_evaluate")

func _deferred_evaluate() -> void:
	_is_evaluation_queued = false
	evaluate_music()

func evaluate_music() -> void:
	if track_list.is_empty():
		return
	
	var active_scene = get_resolved_path(SceneManager.current_scene_path)
	var active_hour = TimeManager.hour
	var active_time = get_time_of_day_name(active_hour)
	var active_season = TimeManager.get_season_name()
	var active_weekday = TimeManager.get_weekday_name()
	var active_weather = "Sunny" # Mock weather state stub TODO
	
	var best_track: MusicTrack = null
	var best_score: int = -1
	
	for track in track_list:
		# Scene Matching
		var scene_match = false
		if track.allowed_scenes.is_empty():
			scene_match = true
		else:
			for scene_allowed in track.allowed_scenes:
				if scene_allowed.to_lower() in active_scene.to_lower():
					scene_match = true
					break
		
		if not scene_match:
			continue
		
		# Time Tracking
		if track.time_of_day != GameConstants.Audio.TIME_ANY and track.time_of_day != active_time:
			continue
		
		# Season Matching
		if track.season != GameConstants.Audio.TIME_ANY and track.season != active_season:
			continue
		
		# Weekday Matching
		if track.weekday != GameConstants.Audio.TIME_ANY and track.weekday != active_weekday:
			continue
		
		# Weather Matching
		if track.weather != GameConstants.Audio.TIME_ANY and track.weather != active_weather:
			continue
		
		# Calculate Match Score: Specifically (non- "Any" requirements) + Priority weight
		var score = 0
		if not track.allowed_scenes.is_empty(): score += GameConstants.Audio.TR_SC_SCORE
		if track.time_of_day != GameConstants.Audio.TIME_ANY: score += GameConstants.Audio.TR_DY_SCORE
		if track.season != GameConstants.Audio.TIME_ANY: score += GameConstants.Audio.TR_SE_SCORE
		if track.weekday != GameConstants.Audio.TIME_ANY: score += GameConstants.Audio.TR_WD_SCORE
		if track.weather != GameConstants.Audio.TIME_ANY: score += GameConstants.Audio.TR_WE_SCORE
		score += track.priority
		
		if score > best_score:
			best_score = score
			best_track = track
			
	if best_track != current_track:
		crossfade_to(best_track)

func crossfade_to(new_track: MusicTrack) -> void:
	if current_track and current_track.stream:
		var old_player = current_player
		if old_player and old_player.playing:
			playback_positions[current_track.resource_path] = old_player.get_playback_position()
	
	current_track = new_track
	
	if active_tween:
		active_tween.kill()
	var old_player = current_player
	var new_player = player_b if current_player == player_a else player_a
	current_player = new_player
	
	if new_track == null or new_track.stream == null:
		if old_player and old_player.playing:
			active_tween = create_tween()
			active_tween.tween_property(old_player, "volume_db", -GameConstants.Audio.FADE_VOL, GameConstants.Audio.FADE_DUR)
			active_tween.finished.connect(old_player.stop)
		return
	
	new_player.stream = new_track.stream
	new_player.volume_db = -GameConstants.Audio.FADE_VOL
	
	await get_tree().process_frame
	
	if current_track != new_track:
		return
		
	# Retrieve saved playback position (defaults to 0.0 if not visited yet)
	var start_position: float = 0.0
	if playback_positions.has(new_track.resource_path):
		start_position = playback_positions[new_track.resource_path]
		
	new_player.play(start_position)
	
	active_tween = create_tween().set_parallel(true)
	active_tween.tween_property(new_player, "volume_db", new_track.volume_db, GameConstants.Audio.FADE_DUR)
	
	if old_player and old_player.playing:
		active_tween.tween_property(old_player, "volume_db", -GameConstants.Audio.FADE_VOL, GameConstants.Audio.FADE_DUR)
		active_tween.finished.connect(old_player.stop)
