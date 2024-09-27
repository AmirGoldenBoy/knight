extends Area2D

@export var speed = 300
@export var damage = 10
var direction = Vector2.RIGHT
var shooter  # Referencia al objeto que disparó el misil

func _ready():
	print("Misil instanciado")
	# Desactivar colisiones por un breve momento
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	await get_tree().create_timer(0.1).timeout
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body == shooter:  # Ignorar colisiones con el que dispara
		return
	print("Misil colisionó con: ", body.name)
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		print("Misil impactó a un enemigo")
	elif body.is_in_group("environment"):
		print("Misil impactó en el entorno")
	explode()

func _on_area_entered(area):
	print("Misil entró en área: ", area.name)
	if area.is_in_group("environment") or area.is_in_group("enemies"):
		print("Misil impactó en un área")
		explode()

func explode():
	print("Misil explotando")
	# Aquí puedes añadir efectos de explosión, sonidos, etc.
	queue_free()
