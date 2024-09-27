extends CharacterBody2D

# Constantes para el movimiento y el ataque
const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const ATTACK_DURATION = 1.0  # Duración del ataque en segundos
const ATTACK_SPEED = 150.0   # Velocidad durante el ataque

# Variables para la física y el estado del jugador
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = 100
var damage = 60
var is_attacking = false
var attack_timer = 0.0
var can_shoot_missiles = false # Indica si el jugador tiene la habilidad de disparar misiles
var time_since_last_shot = 0.0 # Temporizador para el disparo de misiles

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

	# Manejar animaciones y movimiento
	if not is_attacking:
		# Animaciones normales
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("Run")
		else:
			animated_sprite.play("Jump")
		
		# Movimiento normal
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		# Durante el ataque
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
		if Input.is_action_pressed("shoot_missile") and time_since_last_shot >= fire_rate:
			shoot_missile()
			time_since_last_shot = 0.0
	 
	# Iniciar ataque
	if Input.is_action_just_pressed("Attack") and not is_attacking:
		start_attack()


func shoot_missile():
	var missile = missile_scene.instantiate()
	var spawn_offset = Vector2(30 if not animated_sprite.flip_h else -30, 0)
	missile.position = global_position + spawn_offset
	missile.direction = Vector2.RIGHT if not animated_sprite.flip_h else Vector2.LEFT
	missile.shooter = self  # Referencia al jugador que dispara
	get_parent().add_child(missile)
	print("Misil disparado en dirección: ", missile.direction)

func start_attack():
	is_attacking = true
	attack_timer = 0.0
	animated_sprite.play("Attack")
	hit_box.monitoring = true
	print("Iniciando ataque")

func _on_AnimatedSprite2D_animation_finished():
	if animated_sprite.animation == "Attack":
		end_attack()

func end_attack():
	is_attacking = false
	hit_box.monitoring = false
	animated_sprite.play("idle")
	print("Ataque terminado, cambiando a idle")

func _on_hit_box_area_entered(area):
	if area.is_in_group("hurtbox"):
		var enemy = area.get_parent()
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)
			print("Daño infligido al enemigo")

# Función opcional para depuración
func _process(_delta):
	if is_attacking:
		print("Frame actual de Attack: ", animated_sprite.frame)
		print("Tiempo transcurrido en el ataque: ", attack_timer)


func _on_cube_player_gained_missile_ability() -> void:
	print("¡Habilidad de misiles obtenida desde el cubo!")
	can_shoot_missiles = true
func _on_player_gained_missile_ability():
	print("¡Habilidad obtenida!")
	can_shoot_missiles = true
func _unhandled_input(event):
	if event.is_action_pressed("shoot_missile"):
		print("Tecla de disparo de misil presionada")
		if can_shoot_missiles:
			print("Intentando disparar misil")
		else:
			print("No se puede disparar misil aún")
