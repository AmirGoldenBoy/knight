extends RigidBody2D

@export var speed = 300
@export var damage = 10
var direction = Vector2.RIGHT

func _ready():
	# Aplicar una fuerza inicial al misil
	apply_impulse(Vector2.ZERO, direction * speed)

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		explode()

func _on_area_entered(area):
	if area.is_in_group("environment"):
		explode()

func explode():
	# Aquí puedes añadir efectos de explosión, sonidos, etc.
	queue_free()
