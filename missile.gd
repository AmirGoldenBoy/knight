extends Area2D

@export var speed = 300
@export var damage = 10
var direction = Vector2.RIGHT
# Called when the node enters	 the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		explode()

func _on_area_entered(area):
	if area.is_in_group("environment"):
		explode()

func explode():
	# Aquí puedes añadir efectos de explosión
	queue_free()
