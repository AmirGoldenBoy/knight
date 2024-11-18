extends CharacterBody2D

# Constantes para el movimiento y el combate
const SPEED = 200.0  
const ATTACK_RANGE = 60.0  
const FOLLOW_RANGE = 200.0  
const ATTACK_DAMAGE = 20
const ATTACK_COOLDOWN = 2.0  

# Variables de estado
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: Node2D = null
var can_attack = true
var health = 100
var is_attacking = false

# Nodos
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var hurtbox: Area2D = $HurtBox
@onready var hitbox: Area2D = $HitBox

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	hurtbox.add_to_group("hurtbox")
	
	attack_timer.wait_time = ATTACK_COOLDOWN
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	
	hitbox.monitoring = false
	hitbox.monitorable = false
	
	add_to_group("enemies")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if player and not is_attacking:
		var distance = global_position.distance_to(player.global_position)
		var direction = (player.global_position - global_position).normalized()
		
		if animated_sprite:
			animated_sprite.flip_h = direction.x > 0
			
			if hitbox:
				var hitbox_position = hitbox.position
				hitbox_position.x = abs(hitbox_position.x) * (1 if animated_sprite.flip_h else -1)
				hitbox.position = hitbox_position
		
		if distance <= ATTACK_RANGE and can_attack:
			start_attack()
		elif distance <= FOLLOW_RANGE:
			velocity.x = direction.x * SPEED
			if animated_sprite:
				animated_sprite.play("Walk")
		else:
			velocity.x = 0
			if animated_sprite:
				animated_sprite.play("Idle")
	
	move_and_slide()

func start_attack():
	is_attacking = true
	can_attack = false
	if animated_sprite:
		animated_sprite.play("Attack")
	attack_timer.start()

	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)
	print("HitBox activado durante ataque")

	if animated_sprite:
		await animated_sprite.animation_finished

	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	print("HitBox desactivado después del ataque")

	is_attacking = false
	if animated_sprite:
		animated_sprite.play("Idle")

func _on_attack_timer_timeout():
	can_attack = true
	
	if player and health > 0 and global_position.distance_to(player.global_position) <= ATTACK_RANGE:
		start_attack()

func take_damage(amount):
	if health <= 0:  # Si ya está muerto, no procesar más daño
		return
		
	health -= amount
	print("Boss recibió ", amount, " de daño. Salud restante: ", health)

	if animated_sprite:
		animated_sprite.stop()
		animated_sprite.play("Hit")
		await animated_sprite.animation_finished

		if health <= 0:
			call_deferred("die")  # Usar call_deferred para evitar llamadas múltiples
		elif not is_attacking:
			animated_sprite.play("Idle")

func die():
	if not is_physics_processing():  # Evitar múltiples llamadas a die()
		return
		
	print("Boss está muriendo...")
	set_physics_process(false)
	is_attacking = false

	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	if hitbox:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
	if hurtbox:
		hurtbox.set_deferred("monitoring", false)
		hurtbox.set_deferred("monitorable", false)

	if animated_sprite:
		animated_sprite.play("Death")
		await animated_sprite.animation_finished
		print("Animación de muerte completada")
		
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_hurt_box_area_entered(area: Area2D):
	if area.is_in_group("player_hitbox"):
		var player_node = area.get_parent()
		if player_node.has_method("get_damage"):
			var player_damage = player_node.damage
			take_damage(player_damage)
			print("Boss recibió daño del jugador: ", player_damage)

func _on_hit_box_body_entered(body: Node2D) -> void:
	print("Colisión detectada con: ", body.name, " - Tipo: ", body.get_class())
	print("Estado de ataque: ", is_attacking)
	print("Grupos del cuerpo: ", body.get_groups())
	if not is_attacking:
		return
		print("Boss HitBox colisionó con: ", body.name)
		if body is CharacterBody2D and body.has_method("take_damage"):	
			print("Cuerpo es jugador")
			print("Jugador tiene método take_damage")
			print("Llamando a take_damage del jugador")
			print("Boss golpeó al jugador por: ", ATTACK_DAMAGE)
			body.take_damage(ATTACK_DAMAGE)
			print("Salud restante del jugador: ", body.health)
		else:
			print ("Nodo no valido")
