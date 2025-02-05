extends AudioStreamPlayer2D
var tracks = {
	"main_menu": preload("res://assets/Music_Loop_5_Full.wav"),
	"game": preload("res://assets/brackeys_platformer_assets/music/time_for_adventure.mp3"),
	"game2": preload("res://assets/brackeys_platformer_assets/music/field_theme_1.wav"),
	"game3": preload("res://assets/brackeys_platformer_assets/music/dungeon_theme_1.wav"),
	"credits": preload("res://assets/Music_Loop_5_Melody.wav")
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func play_music(track_name: String):
	if !tracks.has(track_name):
		return
		
	stop()
	stream = tracks[track_name]
	play()
