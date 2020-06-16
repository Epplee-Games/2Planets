extends Node2D
var planet
var upgrade_1_type = 'laser'
var upgrade_1_script = 'res://building/types/' + upgrade_1_type + '.gd'
var enemy_player_number
var target_planet
var buildings
var stop_laser_timer
var shooting = false
var laser_position = 0

func init():
	stop_laser_timer = Timer.new()
	stop_laser_timer.connect('timeout', self, 'stop_laser')
	add_child(stop_laser_timer)
	enemy_player_number = 1 if planet.playerNumber == 2 else 2
	target_planet = get_node('/root/main/planet_%s' % enemy_player_number)

func _process(delta):
	buildings = get_tree().get_nodes_in_group('building' + str(enemy_player_number))
	if shooting:
		laser_position += 30
		for building in buildings:
			if Vector2(0, Vector2(0, 0).distance_to(to_local(building.global_position))).rotated(PI).distance_to(to_local(building.global_position)) < 10:
				if not building.is_destroyed:
					building.destroy()
	update()

func _draw():
	if shooting:
		draw_line(Vector2(0, 0), Vector2(0, laser_position).rotated(PI), Color(1, 1, 1), 4)

func stop_laser():
	laser_position = 0
	shooting = false
	stop_laser_timer.stop()

func on_activate():
	if not get_parent().is_destroyed and planet.money >= 20 and not shooting:
		stop_laser_timer.start(0.1)
		shooting = true
		planet.money -= 20
