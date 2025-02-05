# player_state.gd
extends Node

# Estado global de los proyectiles
var can_shoot_missiles = false
var missile_count = 0

# Función para reiniciar valores si se necesita
func reset():
	can_shoot_missiles = false
	missile_count = 0
