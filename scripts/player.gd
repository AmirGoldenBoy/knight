extends CharacterBody2D

# Constantes para el movimiento y el ataque
const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const ATTACK_DURATION = 1.0  # Duración del ataque en segundos
const ATTACK_SPEED = 150.0   # Velocidad durante el ataque
const MELEE_COOLDOWN = 2.5   # Cooldown de 2.5 segundos para el ataque cuerpo a cuerpo
const MAX_MISSILES = 10      # Máximo de misiles

# Variables para la física y el estado del jugador
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = 100
var damage = 60
var is_attacking = false
var attack_timer = 0.0
var attack_cooldown_timer = 0.0  # Temporizador para el cooldown del ataque
var can_shoot_missiles = false   # Indica si el jugador tiene la habilidad de disparar misiles
var time_since_last_shot = 0.0   # Temporizador para el disparo de misiles
var missile_count = MAX_MISSILES # Cantidad de misiles disponibles

# Nodos
@onready var animated_sprite = $AnimatedSprite2D
@onready var hit_box: Area2D = $AnimatedSprite2D/HitBox
@export var missile_scene: PackedScene # Arrastra la escena del misil aquí
@export var fire_rate = 1.0 # Tiempo entre disparos

func _ready():
	# Conecta señales
	animated_sprite.animation_finished.connect(_on_AnimatedSprite2D_animation_finished)
	hit_box.area_entered.connect(_on_hit_box_area_entered)
	hit_box.monitoring = false

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
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true 

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
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Manejar el cooldown del ataque cuerpo a cuerpo
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta

	# Durante el ataque
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
	 
	# Iniciar ataque cuerpo a cuerpo si no está atacando o en cooldown
	if Input.is_action_just_pressed("Attack") and not is_attacking and attack_cooldown_timer <= 0:
		start_attack()

func shoot_missile():
	if missile_count > 0:
		var missile = missile_scene.instantiate()
		var spawn_offset = Vector2(30 if not animated_sprite.flip_h else -30, 0)
		missile.position = global_position + spawn_offset
		missile.direction = Vector2.RIGHT if not animated_sprite.flip_h else Vector2.LEFT
		missile.shooter = self  # Referencia al jugador que dispara
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
	hit_box.monitoring = true
	attack_cooldown_timer = MELEE_COOLDOWN
	print("Iniciando ataque, cooldown activado")

func _on_AnimatedSprite2D_animation_finished():
	if animated_sprite.animation == "Attack":
		end_attack()

func end_attack():
	is_attacking = false
	hit_box.monitoring = false
	print("Ataque terminado, cambiando a idle")

func _on_hit_box_area_entered(area):
	if area.is_in_group("hurtbox"):
		var enemy = area.get_parent()
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)
			print("Daño infligido al enemigo")

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

func _on_player_gained_missile_ability():
	print("¡Habilidad obtenida!")
	can_shoot_missiles = true
	missile_count = MAX_MISSILES

func _unhandled_input(event):
	if event.is_action_pressed("shoot_missile"):
		print("Tecla de disparo de misil presionada")
		if can_shoot_missiles and missile_count > 0:
			print("Intentando disparar misil")
		else:
			print("No se puede disparar misil aún")
