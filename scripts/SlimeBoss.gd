extends Node2D

@export var detection_range = 500  # Distancia a la que el enemigo detecta al jugador
@export var shoot_cooldown = 2.0  # Tiempo de espera entre disparos
@export var projectile_scene : PackedScene  # Escena del proyectil a instanciar
@export var projectile_speed = 300

var player
var can_shoot = true
var health = 100
func _ready():
	$HurtBox.add_to_group("hurtbox")  # Agrega el Area2D "HurtBox" al grupo "hurtbox"
	add_to_group("enemies") 
	# Obtener la referencia al jugador en la escena
	player = get_tree().get_nodes_in_group("Player")[0]  # Reemplaza con la ruta real al jugador
func take_damage(amount):
	print("Recibí daño")
	health -= amount
	$AnimatedSprite2D.play("hurt")
	print("Enemigo recibió ", amount, " de daño. Salud restante: ", health)
	if health <= 0:
		die()

# Función para morir
func die():
	$AnimatedSprite2D.play("death")
	await try_await()
	queue_free()  # Elimina el enemigo de la escena
	
func try_await():
	await get_tree().create_timer(0.5).timeout
	print("After timeout") # Genera un tiempo de cooldown para la animación de muerte
	
func _process(delta):
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player <= detection_range:
			# Apuntar y disparar hacia el jugador
			if can_shoot:
				shoot_projectile()
				can_shoot = false
				await get_tree().create_timer(shoot_cooldown).timeout
				can_shoot = true

func shoot_projectile():
	# Crear una instancia del proyectil
	$AnimatedSprite2D.play("attack")
	var projectile = projectile_scene.instantiate()
	
	# Configurar la posición inicial del proyectil cerca del enemigo
	projectile.global_position = global_position
	
	# Calcular la dirección hacia el jugador
	var direction = (player.global_position - global_position).normalized()
	
	# Configurar la dirección y el shooter en el proyectil
	projectile.setup(direction, self)
	
	# Añadir el proyectil a la escena
	get_parent().add_child(projectile)

# Función para manejar el daño al jugador
