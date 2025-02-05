extends Area2D

@export var speed = 500
@export var damage = 50
@export var vertical_offset = 20  # Ajusta este valor para cambiar qué tan arriba aparece el misil
@onready var animated_sprite = $AnimatedSprite2D
var direction = Vector2.RIGHT
var shooter  # Referencia al objeto que disparó el misil

func _ready():
	print("Misil instanciado")
	# Ajustar la posición inicial del misil
	position += Vector2(0, -vertical_offset)
	if direction == Vector2.LEFT:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	# Desactivar colisiones por un breve momento
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	await get_tree().create_timer(0.01).timeout
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)
	print("Colisiones del misil activadas")

func _physics_process(delta):
	position += direction * speed * delta

# Colisión con cuerpos (como TileMap o personajes)
func _on_body_entered(body):
	print("Colisión detectada con: ", body.name, " - Grupos: ", body.get_groups())
	
	if body == shooter:  # Ignorar colisiones con el que dispara
		print("Colisión ignorada: es el shooter")
		return
	
	# Detectar si el cuerpo es un enemigo
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			print("Aplicando daño al enemigo:", body.name)
			body.take_damage(damage)
		print("Misil impactó a un enemigo")
		explode()
	elif body.is_in_group("Environment") or body.is_in_group("environment"):
		print("Misil impactó en el entorno")
		explode()
	else:
		print("Colisión con objeto no reconocido: ", body.name)
		# Consideramos cualquier colisión no reconocida como parte del entorno
		explode()

# Colisión con áreas (por ejemplo, hurtbox o environment)
func _on_area_entered(area):
	print("Misil entró en área: ", area.name, " - Grupos: ", area.get_groups())
	
	# Chequear si el área pertenece a un enemigo, si es así, aplicamos daño al nodo padre
	if area.is_in_group("hurtbox"):
		var enemy = area.get_parent()  # Obtener el nodo padre del HurtBox
		if enemy.is_in_group("enemies"):
			if enemy.has_method("take_damage"):
				print("Aplicando daño al enemigo (desde HurtBox):", enemy.name)
				enemy.take_damage(damage)
			explode()
	elif area.is_in_group("Environment") or area.is_in_group("environment"):
		print("Misil impactó en el entorno (área)")
		explode()
	else:
		print("Colisión con área no reconocida: ", area.name)
		# Consideramos cualquier colisión no reconocida como parte del entorno
		explode()

func explode():
	print("Misil explotando")
	# Aquí puedes añadir efectos de explosión, sonidos, etc.
	queue_free()

# Función para configurar la dirección y el shooter
func setup(new_direction: Vector2, new_shooter):
	direction = new_direction.normalized()
	shooter = new_shooter
