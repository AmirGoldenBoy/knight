extends Area2D

@onready var game_manager = get_node("/root/GameManager")  # Accede al GameManager global
@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d = $CollisionShape2D

func _on_body_entered(_body):
	game_manager.add_point()  # Incrementa el score
	animation_player.play("Pickup")  # Reproduce la animación de recoger
	collision_shape_2d.queue_free()  # Desactiva la colisión
