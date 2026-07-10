extends Node

const POOL_SIZE = 8
var pool: Array[AudioStreamPlayer] = []

func _ready() -> void:
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		add_child(player)
		pool.append(player)

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	
	for player in pool:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.play()
			return
	
	var busy_player = pool[0]
	busy_player.stream = stream
	busy_player.volume_db = volume_db
	busy_player.play()
