extends Area2D

# Función que se llama cuando algo entra en el Area2D
func _on_Area2D_body_entered(body):
	if body.name == "Player":  # Verifica si es el jugador
		get_tree().change_scene("res://game2.tscn")  # Cambia al nivel 2


func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
