extends Node2D

@onready var damage_box: Area2D = $DamageBox
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
const SPEED = 30
var health = 20
var direction = 1
var damage = 10

# Llamado al inicio
func _ready():
	$HurtBox.add_to_group("hurtbox")  # Agrega el Area2D "HurtBox" al grupo "hurtbox"
	add_to_group("enemies")  # Asegurarse de que el enemigo está en el grupo "enemies"

# Función para recibir daño
func take_damage(amount):
	print("Recibí daño")
	health -= amount
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
	print("After timout") # Genera un tiempo de cooldown para la animación de muerte

# Función para el movimiento
func _process(delta):
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	position.x += direction * SPEED * delta
