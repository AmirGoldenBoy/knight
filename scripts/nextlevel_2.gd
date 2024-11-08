extends Area2D

func _ready():
	print("Area lista para detectar")
	# Conectar la señal directamente
	body_entered.connect(_on_Area2D_body_entered)

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		print("El jugador ha entrado en el área.")
		get_tree().change_scene_to_file("res://scenes/game3.tscn")
