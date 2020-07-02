extends Node2D
var planet
var activate_cost = 0
var building_info 

func init():
	building_info = ''

func on_activate():
	if get_parent().is_built and not get_parent().is_destroyed:
		planet.player.position = planet.player.position.rotated(PI)
