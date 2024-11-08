extends CharacterBody2D

# Constantes para el movimiento y el combate
const SPEED = 150.0  # Velocidad más baja que el jugador para dar chance de escapar
const ATTACK_RANGE = 100.0  # Distancia a la que puede atacar
const FOLLOW_RANGE = 400.0  # Distancia a la que empieza a seguir al jugador
const ATTACK_DAMAGE = 20
const ATTACK_COOLDOWN = 2.0  # Tiempo entre ataques

# Variables de estado
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: Node2D = null
var can_attack = true
var health = 100
var is_attacking = false

# Nodos
@onready var animated_sprite = $AnimatedSprite2D  # Asegúrate de tener este nodo
@onready var attack_timer = $AttackTimer  # Necesitarás añadir este Timer como nodo hijo

func _ready():
	# Buscar al jugador en la escena
	player = get_tree().get_first_node_in_group("Player")
	
	# Configurar el timer para el cooldown de ataque
	attack_timer.wait_time = ATTACK_COOLDOWN
	attack_timer.one_shot = true
	
	# Conectar la señal de animación terminada si tienes animación de ataque
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if player and !is_attacking:
		# Calcular distancia al jugador
		var distance = global_position.distance_to(player.global_position)
		var direction = (player.global_position - global_position).normalized()
		
		# Actualizar la dirección del sprite
		if animated_sprite:
			animated_sprite.flip_h = direction.x < 0
		
		if distance <= ATTACK_RANGE and can_attack:
			# Atacar si está en rango
			start_attack()
		elif distance <= FOLLOW_RANGE:
			# Seguir al jugador si está dentro del rango de seguimiento
			velocity.x = direction.x * SPEED
			if animated_sprite:
				animated_sprite.play("Walk")  # Asegúrate de tener esta animación
		else:
			# Quedarse quieto si el jugador está muy lejos
			velocity.x = 0
			if animated_sprite:
				animated_sprite.play("Idle")  # Asegúrate de tener esta animación
	
	move_and_slide()

func start_attack():
	is_attacking = true
	can_attack = false
	if animated_sprite:
		animated_sprite.play("Attack")  # Asegúrate de tener esta animación
	attack_timer.start()
	
	# Crear un área de daño o raycast para detectar al jugador
	check_attack_hit()

func check_attack_hit():
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance <= ATTACK_RANGE:
			# Si el jugador tiene un método take_damage, llamarlo
			if player.has_method("take_damage"):
				player.take_damage(ATTACK_DAMAGE)

func _on_animation_finished():
	if is_attacking:
		is_attacking = false
		if animated_sprite:
			animated_sprite.play("Idle")

func _on_attack_timer_timeout():
	can_attack = true

# Método para recibir daño
func take_damage(amount):
	health -= amount
	if animated_sprite:
		animated_sprite.play("Hit")  # Asegúrate de tener esta animación
	
	if health <= 0:
		die()

func die():
	if animated_sprite:
		animated_sprite.play("Death")  # Asegúrate de tener esta animación
		await animated_sprite.animation_finished
	queue_free()
