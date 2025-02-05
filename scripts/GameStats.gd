extends Node

signal game_completed(stats: Dictionary)

@onready var game_manager = get_node("/root/GameManager")
var start_time: int = 0
var end_time: int = 0

func _ready():
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
   
   # 🔧 Solución: Ahora usa `save_game_stats()` en vez de la función inexistente
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
