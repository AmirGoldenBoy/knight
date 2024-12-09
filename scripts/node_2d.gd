extends StaticBody2D
signal player_gained_missile_ability
func _ready():
	# Asegurarse de que el nodo tiene los hijos necesarios
	assert(has_node("Area2D"), "Este nodo necesita un Area2D como hijo")
	assert($Area2D.has_node("CollisionShape2D"), "El Area2D necesita un CollisionShape2D como hijo")
	assert(has_node("AnimatedSprite2D"), "Este nodo necesita un AnimatedSprite2D como hijo")



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Colisión detectada con el jugador")
		$AnimatedSprite2D.play("activate")
		emit_signal("player_gained_missile_ability")
		queue_free()
