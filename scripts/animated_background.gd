extends Node2D

@export var backgrounds: Array[Texture2D] = []
@export var transition_duration: float = 2.0
@export var switch_interval: float = 4.0

@onready var background1: Sprite2D = $Background1
@onready var background2: Sprite2D = $Background2
@onready var background3: Sprite2D = $Background3
@onready var viewport_size = get_viewport_rect().size

var current_index: int = 0
var switch_timer: Timer

func _ready():
	if backgrounds.size() != 3:
		push_error("Debes asignar exactamente 3 imágenes de fondo.")
		return
	
	# Configurar sprites
	for sprite in [background1, background2, background3]:
		setup_sprite(sprite)
	
	# Asignar texturas
	background1.texture = backgrounds[0]
	background2.texture = backgrounds[1]
	background3.texture = backgrounds[2]
	
	# Configurar visibilidad inicial
	background1.modulate.a = 1.0
	background2.modulate.a = 0.0
	background3.modulate.a = 0.0
	
	# Configurar timer
	switch_timer = Timer.new()
	add_child(switch_timer)
	switch_timer.wait_time = switch_interval
	switch_timer.timeout.connect(start_transition)
	switch_timer.start()
	
	# Conectar señal de cambio de ventana
	get_viewport().size_changed.connect(on_viewport_resized)

func setup_sprite(sprite: Sprite2D):
	sprite.centered = true
	sprite.scale = calculate_scale(sprite)
	sprite.position = viewport_size / 2

func calculate_scale(sprite: Sprite2D) -> Vector2:
	if not sprite.texture:
		return Vector2.ONE
		
	var texture_size = sprite.texture.get_size()
	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	var scale = max(scale_x, scale_y)
	return Vector2(scale, scale)

func on_viewport_resized():
	viewport_size = get_viewport_rect().size
	for sprite in [background1, background2, background3]:
		sprite.scale = calculate_scale(sprite)
		sprite.position = viewport_size / 2

func start_transition():
	var next_index = (current_index + 1) % backgrounds.size()
	var tween = create_tween()
	var current_background = get_background(current_index)
	var next_background = get_background(next_index)
	next_background.modulate.a = 0.0
	tween.tween_property(current_background, "modulate:a", 0.0, transition_duration)
	tween.parallel().tween_property(next_background, "modulate:a", 1.0, transition_duration)
	current_index = next_index

func get_background(index: int) -> Sprite2D:
	match index:
		0: return background1
		1: return background2
		2: return background3
		_: return background1
