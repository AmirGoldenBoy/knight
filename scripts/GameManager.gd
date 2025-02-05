extends Node

var score = 0
var enemies_defeated = 0
var start_time = 0
var last_game_stats = {}

func _ready():
	start_time = Time.get_unix_time_from_system()

func add_point():
	score += 1

func add_enemy_defeated():
	enemies_defeated += 1

func save_game_stats():
	var elapsed_time = Time.get_unix_time_from_system() - start_time
	last_game_stats = {
		"coins": score,
		"enemies": enemies_defeated,
		"time": elapsed_time
	}

func reset_stats():
	score = 0
	enemies_defeated = 0
	start_time = Time.get_unix_time_from_system()

# 🔧 Nueva función para evitar el error de función inexistente
func set_game_stats(stats: Dictionary):
	last_game_stats = stats
