extends Control

@onready var coins_label = $StatsContainer/CoinsLabel
@onready var enemies_label = $StatsContainer/EnemiesLabel
@onready var time_label = $StatsContainer/TimeLabel
@onready var menu_button = $StatsContainer/MenuButton

func _ready():
	Music.play_music("credits")
	menu_button.pressed.connect(_on_menu_button_pressed)
	display_stats()

func display_stats():
	var stats = get_node("/root/GameManager").last_game_stats
	
	# 🔧 Nueva verificación para evitar el error de acceso a `time`
	if not stats.has("time"):
		print("Error: 'last_game_stats' no contiene 'time'", stats)
		return
	
	var total_time = int(stats.time)
	var hours = floor(total_time / 3600)
	var minutes = floor((total_time % 3600) / 60)
	var seconds = total_time % 60
	
	coins_label.text = "Coins: %d" % stats.coins
	enemies_label.text = "Enemies defeated: %d" % stats.enemies
	time_label.text = "Playtime: %02d:%02d:%02d" % [hours, minutes, seconds]

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_menu_button_pressed()

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
