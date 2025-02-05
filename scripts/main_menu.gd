extends Control

# Referencias a los botones
@onready var start_button = $VBoxContainer/StartButton
@onready var exit_button = $VBoxContainer/ExitButton

# Referencias a los sonidos
@onready var press_sound = $PressSound  # Ajusta la ruta según tu escena
@onready var hover_sound = $HoverSound  # Ajusta la ruta según tu escena

func _ready():
	Music.play_music("main_menu")
	# Conectar señales de los botones a las funciones correspondientes
	start_button.pressed.connect(_on_StartButton_pressed)
	exit_button.pressed.connect(_on_ExitButton_pressed)

	# Conectar señales de hover
	start_button.mouse_entered.connect(_on_StartButton_hover)
	exit_button.mouse_entered.connect(_on_ExitButton_hover)

	# Ajustar el tamaño de los botones
	var screen_width = get_viewport().get_visible_rect().size.x

func _on_StartButton_pressed():
	# Reproducir sonido de press
	press_sound.play()
	
	# Esperar un breve delay (por ejemplo, 0.5 segundos)
	await get_tree().create_timer(0.5).timeout
	
	# Cambiar a la escena del juego (ajusta la ruta a tu escena de juego)
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_ExitButton_pressed():
	# Reproducir sonido de press
	press_sound.play()
	
	# Esperar un breve delay (por ejemplo, 0.5 segundos)
	await get_tree().create_timer(0.5).timeout
	
	# Salir del juego
	get_tree().quit()

func _on_StartButton_hover():
	# Reproducir sonido de hover
	hover_sound.play()

func _on_ExitButton_hover():
	# Reproducir sonido de hover
	hover_sound.play()
