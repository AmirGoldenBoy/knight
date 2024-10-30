extends Area2D

@export var speed = 300
@export var damage = 10
@export var vertical_offset = 10  # Ajusta este valor para cambiar qué tan arriba aparece el proyectil

var direction = Vector2.RIGHT
var shooter  # Referencia al objeto que disparó el proyectil, en este caso el monstruo

func _ready():
	print("Proyectil del monstruo instanciado")
	# Ajustar la posición inicial del proyectil
	position += Vector2(0, -vertical_offset)
	
	# Desactivar colisiones por un breve momento
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	await get_tree().create_timer(0.01).timeout
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)
	print("Colisiones del proyectil activadas")

func _physics_process(delta):
	position += direction * speed * delta

# Colisión con cuerpos (por ejemplo, TileMap o el jugador)
func _on_body_entered(body):
	print("Colisión detectada con: ", body.name, " - Grupos: ", body.get_groups())
	
	if body == shooter:  # Ignorar colisiones con el monstruo que dispara
		print("Colisión ignorada: es el shooter")
		return
	
	# Detectar si el cuerpo es el jugador
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			print("Aplicando daño al jugador:", body.name)
			body.take_damage(damage)
		print("Proyectil impactó al jugador")
		explode()
	else:
		print("Colisión con objeto no reconocido: ", body.name)
		explode()

# Colisión con áreas (por ejemplo, hurtbox o environment)
func _on_area_entered(area):
	print("Proyectil entró en área: ", area.name, " - Grupos: ", area.get_groups())
	
	# Chequear si el área pertenece al jugador o al entorno
	if area.is_in_group("player_hurtbox"):
		var player = area.get_parent()  # Obtener el nodo padre del HurtBox (en este caso, el jugador)
		if player.is_in_group("player"):
			if player.has_method("take_damage"):
				print("Aplicando daño al jugador (desde HurtBox):", player.name)
				player.take_damage(damage)
			explode()
	else:
		print("Colisión con área no reconocida: ", area.name)
		explode()

func explode():
	print("Proyectil del monstruo explotando")
	# Aquí puedes añadir efectos de explosión, sonidos, etc.
	queue_free()

# Función para configurar la dirección y el shooter
func setup(new_direction: Vector2, new_shooter):
	direction = new_direction.normalized()
	shooter = new_shooter	
