extends MarginContainer

@onready var progress_bar = $ProgressBar
@onready var tween: Tween

var max_health: int = 100
var current_health: int = 100

func _ready():
	progress_bar.max_value = max_health
	progress_bar.value = current_health
	update_bar_color()

func set_health(new_health: int):
	var prev_health = current_health
	current_health = clamp(new_health, 0, max_health)
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(progress_bar, "value", current_health, 0.2)
	
	update_bar_color()

func update_bar_color():
	var style_box = progress_bar.get_theme_stylebox("fill").duplicate()
	if current_health > max_health * 0.7:
		style_box.bg_color = Color(0.0, 1.0, 0.0)  # Verde
	elif current_health > max_health * 0.3:
		style_box.bg_color = Color(1.0, 1.0, 0.0)  # Amarillo
	else:
		style_box.bg_color = Color(1.0, 0.0, 0.0)  # Rojo
	
	progress_bar.add_theme_stylebox_override("fill", style_box)


func on_player_health_changed(new_health: float) -> void:
	set_health(int(new_health))
