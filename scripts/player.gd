extends CharacterBody2D

# Constantes para el movimiento y el ataque
const SPEED = 400.0
const JUMP_VELOCITY = -300.0
const ATTACK_DURATION = 1.0
const ATTACK_SPEED = 150.0   
const MELEE_COOLDOWN = 2.5   
const MAX_MISSILES = 10      

# Variables para la física y el estado del jugador
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = 100
var damage = 60
var is_attacking = false
var attack_timer = 0.0
var attack_cooldown_timer = 0.0
var can_shoot_missiles = false
var time_since_last_shot = 0.0
var missile_count = MAX_MISSILES

# Nodos
@onready var animated_sprite = $AnimatedSprite2D
@onready var hit_box: Area2D = $HitBox
@export var missile_scene: PackedScene 
@export var fire_rate = 1.0 

func _ready():
	# Conectar señales
	animated_sprite.animation_finished.connect(_on_AnimatedSprite2D_animation_finished)
	hit_box.monitoring = true  # Habilitar detección de colisiones

func _physics_process(delta):
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# Manejar el salto
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY
	
	# Obtener dirección de movimiento
	var direction = Input.get_axis("move_left", "move_right")
	
	# Voltear el sprite según la dirección
	animated_sprite.flip_h = direction < 0

	# Movimiento y animaciones normales cuando no está atacando
	if not is_attacking: 
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("Run")
		else:
			animated_sprite.play("Jump")
		
		# Movimiento normal
		velocity.x = direction * SPEED

	# Manejar cooldowns y ataques
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta

	if is_attacking:
		attack_timer += delta
		if attack_timer <= ATTACK_DURATION:
			velocity.x = ATTACK_SPEED * (-1 if animated_sprite.flip_h else 1)
		else:
			velocity.x = 0
	
	# Aplicar movimiento
	move_and_slide()

	# Manejar disparo de misiles
	if can_shoot_missiles:
		time_since_last_shot += delta
		if Input.is_action_pressed("shoot_missile") and time_since_last_shot >= fire_rate and missile_count > 0:
			shoot_missile()
			time_since_last_shot = 0.0
	 
	# Iniciar ataque cuerpo a cuerpo
	if Input.is_action_just_pressed("Attack") and not is_attacking and attack_cooldown_timer <= 0:
		start_attack()

	# Detectar colisiones con proyectiles
	for area in hit_box.get_overlapping_areas(): 
		if area.is_in_group("projectiles"):
			_on_projectile_collision(area)

func shoot_missile():
	if missile_count > 0:
		var missile = missile_scene.instantiate()
		var spawn_offset = Vector2(30 if not animated_sprite.flip_h else -30, 0)
		missile.position = global_position + spawn_offset
		missile.direction = Vector2.RIGHT if not animated_sprite.flip_h else Vector2.LEFT
		missile.shooter = self
		get_parent().add_child(missile)
		missile_count -= 1
		print("Misil disparado en dirección: ", missile.direction)
		print("Misiles restantes: ", missile_count)
	else:
		print("No quedan misiles")

func start_attack():
	is_attacking = true
	attack_timer = 0.0
	animated_sprite.play("Attack")
	hit_box.monitoring = true  # Activar la hitbox para ataques
	attack_cooldown_timer = MELEE_COOLDOWN
	print("Iniciando ataque, cooldown activado")

func _on_AnimatedSprite2D_animation_finished():
	if animated_sprite.animation == "Attack":
		end_attack()

func end_attack():
	is_attacking = false
	hit_box.monitoring = false
	print("Ataque terminado, cambiando a idle")

func _on_projectile_collision(projectile: Area2D):
	if projectile.has_method("get_damage"):
		var damage_received = projectile.get_damage()
		print("Jugador colisionó con proyectil. Daño recibido: ", damage_received)
		take_damage(damage_received)
		projectile.queue_free()  # Opcional: eliminar el proyectil tras la colisión.

func take_damage(amount):
	health -= amount
	print("Jugador recibió ", amount, " de daño. Salud restante: ", health)
	if health <= 0:
		die()

func die():
	print("Jugador ha muerto")
	# Aquí podrías detener la lógica del juego o reiniciar la escena

func _on_cube_player_gained_missile_ability() -> void:
	print("¡Habilidad de misiles obtenida desde el cubo!")
	can_shoot_missiles = true
	missile_count = MAX_MISSILES  # Restaurar las cargas de misiles

func _on_area_2d_body_entered(body: Node2D) -> void:
	pass  # Reemplazar con el cuerpo de la función.

func _on_nextlevel_body_entered(body: Node2D) -> void:
	pass  # Reemplazar con el cuerpo de la función.
