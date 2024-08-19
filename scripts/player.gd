extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = 100
var damage = 20
@onready var animated_sprite = $AnimatedSprite2D
var is_attacking = false

func _ready():
	# Conectar la señal animation_finished
	animated_sprite.animation_finished.connect(_on_AnimatedSprite2D_animation_finished)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY
	
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:    
		animated_sprite.flip_h = true 

	if not is_attacking:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("Run")
		else:
			animated_sprite.play("Jump")
		
	if direction and not is_attacking:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	 
	if Input.is_action_just_pressed("Attack") and not is_attacking:
		is_attacking = true
		animated_sprite.play("Attack")

func _on_AnimatedSprite2D_animation_finished():
	if animated_sprite.animation == "Attack":
		is_attacking = false
