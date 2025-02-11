extends Node

signal game_completed(stats: Dictionary)

@onready var game_manager = get_node("/root/GameManager")
var start_time: int = 0
var end_time: int = 0

func _ready():
	start_time = Time.get_unix_time_from_system()
	await get_tree().create_timer(0.1).timeout
	if get_tree().get_nodes_in_group("Player").size() > 0:
		var player = get_tree().get_nodes_in_group("Player")[0]
		player.player_died.connect(on_player_death)

func reset_time():
	start_time = Time.get_unix_time_from_system()

func add_coin():
	game_manager.add_point()

func get_coins() -> int:
	return game_manager.score

func get_enemy_count() -> int:
	return get_tree().get_nodes_in_group("enemies").size()

func get_current_enemies() -> int:
	return get_tree().get_nodes_in_group("enemies").size()

func complete_game():
	end_time = Time.get_unix_time_from_system()
	var play_time = end_time - start_time
	
	var final_stats = {
		"coins": get_coins(),
		"enemies": game_manager.enemies_defeated,
		"time": play_time
	}
	
	game_manager.last_game_stats = final_stats
	emit_signal("game_completed", final_stats)
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func get_stats() -> Dictionary:
	var current_time = Time.get_unix_time_from_system() - start_time
	return {
		"coins": get_coins(),
		"enemies": get_enemy_count() - get_current_enemies(),
		"time": current_time
	}

func on_player_death():
	reset_time()
	game_manager.reset_game()
