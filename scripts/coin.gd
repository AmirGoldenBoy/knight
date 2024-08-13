extends Area2D

@onready var game_manager = %GameManager
@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d = $CollisionShape2D

func _on_body_entered(body):
	game_manager.add_point()
	animation_player.play("Pickup")	
	$CollisionShape2D.queue_free()
