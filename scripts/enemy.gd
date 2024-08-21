extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$HurtBox.add_to_group("hurtbox")  # Agrega el Area2D "HurtBox" al grupo "hurtbox"

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
const SPEED = 60
var health = 20
var direction = 1

# Función para recibir daño
func take_damage(amount):
	health -= amount
	print("Enemigo recibió ", amount, " de daño. Salud restante: ", health)
	if health <= 0:
		die()

# Función para morir
func die():
	$AnimatedSprite2D.play("death")
	await try_await()
	$AnimatedSprite2D.animation_finished
	queue_free()  # Elimina el enemigo de la escena
	
func try_await():
	await get_tree().create_timer(0.5).timeout
	print("After timout")
	
