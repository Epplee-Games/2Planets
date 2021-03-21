extends Node2D

var planet

var additional_income := 1.0
var upgrade_1_type = 'repair_drone_factory'
var upgrade_2_type = 'teleporter'
var building_info 
var bonus_per_building := 0.1
var connection_bonus := 0.0

func init():
	get_parent().planet.income += additional_income
	update_income()
	
func update_income():
	get_parent().planet.income -= connection_bonus + additional_income
	if not get_parent().is_destroyed:
		additional_income = 1.0
		connection_bonus = get_parent().get_connected_buildings().size() * bonus_per_building
		get_parent().planet.income += connection_bonus + additional_income
	else:
		connection_bonus = 0
		additional_income = 0
	building_info = '+ %.1f $/s' % [additional_income + connection_bonus]
