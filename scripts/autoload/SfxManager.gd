extends Node

var pool: Array[AudioStreamPlayer] = []

func _ready() -> void:
	for i in range(GameConstants.Audio.POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		pool.append(player)

func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if stream == null:
		return
	
	for player in pool:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.pitch_scale = pitch
			player.play()
			return
	
	var busy_player = pool[0]
	busy_player.stream = stream
	busy_player.volume_db = volume_db
	busy_player.pitch_scale = pitch
	busy_player.play()
