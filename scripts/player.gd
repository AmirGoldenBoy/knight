extends CharacterBody2D

# Constantes para el movimiento y el ataque
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ATTACK_DURATION = 0.5 # Duración del ataque reducida
const ATTACK_SPEED = 150.0   
const MELEE_COOLDOWN = 1.0 # Cooldown de ataque reducido  
const MAX_MISSILES = 10      
const ROLL_FORCE = 100.0

# Señales
signal hit(damage)

# Variables de estado
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = 100
var damage = 60
var is_attacking = false
var attack_timer = 0.0 # Temporizador para la animación de ataque
var attack_cooldown_timer = 0.0
var can_shoot_missiles = false
var time_since_last_shot = 0.0
var missile_count = MAX_MISSILES
var direction = 0
var roll_direction = Vector2.ZERO

# Nodos
@onready var animated_sprite = $AnimatedSprite2D
@onready var hit_box: Area2D = $HitBox
@export var missile_scene: PackedScene 
@export var fire_rate = 1.0 

func _ready():
	# Conectar señales
	animated_sprite.animation_finished.connect(_on_AnimatedSprite2D_animation_finished)
	hit_box.add_to_group("player_hitbox")
	add_to_group("Player")

func _physics_process(delta):
	# Aplicar gravedad y movimiento horizontal
	apply_gravity_and_movement(delta)

	if is_attacking:
		handle_attack(delta)
	else:
		handle_normal_movement(delta)

	move_and_slide()

	# Cooldown y manejo de ataques
	update_attack_cooldown(delta)

	if Input.is_action_just_pressed("Attack") and not is_attacking and attack_cooldown_timer <= 0:
		start_attack()

	# Disparo de misiles
	shoot_missiles(delta)

func apply_gravity_and_movement(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY

	direction = Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:    
		animated_sprite.flip_h = true 
	if not is_attacking:
		update_animation(direction)

	if direction and not is_attacking:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 1, SPEED)

func handle_attack(delta):
	attack_timer += delta
	if attack_timer >= ATTACK_DURATION:
		end_attack()
	else:
		velocity.x = roll_direction.x * ATTACK_SPEED

func handle_normal_movement(delta):
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func update_attack_cooldown(delta):
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta

func shoot_missiles(delta):
	if can_shoot_missiles and Input.is_action_pressed("shoot_missile") and time_since_last_shot >= fire_rate and missile_count > 0:
		shoot_missile()
		time_since_last_shot = 0.0
	else:
		time_since_last_shot += delta

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

func start_attack():
	is_attacking = true
	roll_direction = Vector2.RIGHT if not animated_sprite.flip_h else Vector2.LEFT
	attack_timer = 0.0 # Reiniciar el temporizador de ataque
	animated_sprite.play("Attack")
	hit_box.monitoring = true  # Activar la hitbox para el ataque
	attack_cooldown_timer = MELEE_COOLDOWN
	print("Iniciando ataque")

func end_attack():
	is_attacking = false
	hit_box.monitoring = false
	hit_box.monitorable = false
	print("Ataque terminado, volviendo a idle")

func _on_AnimatedSprite2D_animation_finished():
	if animated_sprite.animation == "Attack":
		end_attack()

func _on_projectile_collision(projectile: Area2D):
	if projectile.has_method("get_damage"):
		take_damage(projectile.get_damage())
		projectile.queue_free()

func take_damage(amount):
	health -= amount
	print("Jugador recibió ", amount, " de daño. Salud restante: ", health)
	if health <= 0:
		die()

func die():
	print("Jugador ha muerto")
	# Desactivar toda la física y movimiento
	set_physics_process(false)
	# Desactivar el proceso de input
	set_process_input(false)
	# Desactivar las colisiones
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	# Interrumpir cualquier otra animación que se esté reproduciendo
	is_attacking = false
	velocity = Vector2.ZERO

	# Reproducir la animación de muerte
	animated_sprite.play("Death")

	# Esperar a que termine la animación
	await animated_sprite.animation_finished

	# Pequeña pausa antes de reiniciar
	await get_tree().create_timer(0.5).timeout

	# Reiniciar la escena
	get_tree().reload_current_scene()
func _on_cube_player_gained_missile_ability():
	can_shoot_missiles = true
	missile_count = MAX_MISSILES
	print("Habilidad de misiles obtenida")

func _on_hit_box_area_entered(area: Area2D) -> void:
	print("Melee: ", area.name, " - Grupos: ", area.get_groups())
	if not is_attacking:
		return
	if area.is_in_group("hurtbox"):
		var enemy = area.get_parent()
		if enemy.is_in_group("enemies"):
			if enemy.has_method("take_damage"):
				print("Aplicando daño al enemigo (desde HurtBox):", enemy.name)
				enemy.take_damage(damage)

func update_animation(direction):
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("Run")
	else:
		animated_sprite.play("Jump")
