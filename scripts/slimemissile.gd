extends Area2D
@export var speed = 200
@export var damage = 10
@export var vertical_offset = 10
var direction = Vector2.RIGHT
var shooter
var target_group = ""

func _ready():
	print("Proyectil del monstruo instanciado")
	position += Vector2(0, -vertical_offset)
	add_to_group("missile")
	
	# Desactivar colisiones brevemente al inicio
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	await get_tree().create_timer(0.1).timeout
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)
	
	# Autodestrucción después de 5 segundos
	var timer = get_tree().create_timer(3.0)
	await timer.timeout
	if is_instance_valid(self):
		explode()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body: Node2D):
	print("Proyectil colisionó con: ", body.name)
	
	# Evitar colisiones con el shooter
	if !is_instance_valid(body) || !is_instance_valid(shooter) || body == shooter:
		print("Colisión ignorada: cuerpo pertenece al shooter o no es válido")
		return
		
	# Verificar si es el jugador usando el CollisionShape2D
	if body is CharacterBody2D:
		if body.has_method("take_damage"):
			print("Aplicando daño al jugador:", body.name)
			body.take_damage(damage)
			explode()
			
func explode():
	queue_free()

func setup(new_direction: Vector2, new_shooter, group: String = ""):
	direction = new_direction.normalized()
	shooter = new_shooter
	target_group = group
	rotation = direction.angle()
