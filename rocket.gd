extends Node2D

var target
var velocity
var rotation_speed = 0.75
var target_player_number
var from_planet
#warning-ignore:unused_class_variable
var building
var planet_rocket_damage = 5
var is_destroyed = false
var explosion_radius = 20

func _ready():
	velocity = Vector2(40, 0).rotated(rotation)

func _init(target_player_number_):
	target_player_number = target_player_number_
	var owning_player_number = 1 if target_player_number == 2 else 2
	add_to_group('rocket' + str(owning_player_number))

# calculates point on planet surfaces from rocket angle
func point_on_planet():
	 return target.planetRadius * target.global_position.direction_to(global_position) + target.global_position

func _draw():
	var length = 3 + velocity.length() / 50
	draw_rect(Rect2(Vector2(0, 0), Vector2(length, 1)), Color(1, 0.3, 0.3))
	if is_destroyed: 
		# draw_circle(Vector2(0, 0), 50, Color(1, 1, 1))
		draw_circle(to_local(point_on_planet()), explosion_radius, Color(1, 1, 1))

func _process(delta):
	if is_destroyed:
		queue_free()
		return

	if not is_instance_valid(target):
		target = find_new_target()

	if is_instance_valid(target):
		var target_angle = position.direction_to(target.global_position)
		var angle_diff = velocity.angle_to(target_angle)
		var rotation_direction = sign(angle_diff)
		velocity = velocity.rotated(rotation_direction * rotation_speed * delta)

		var acceleration = clamp(1 - abs(angle_diff), 0.25, 0.6) * delta
		velocity = velocity * (1 + acceleration)

		if target.is_network_master():
			if global_position.distance_to(target.global_position) - target.planetRadius < 1:
				rpc('hit_planet', target.get_path())
				return

	position += velocity * delta
	rotation = velocity.angle()
	update()

remotesync func hit_planet(path):
	is_destroyed = true
	var hit_building = false
	self.update()
	var planet = get_node(path)
	for building in get_tree().get_nodes_in_group("building" + str(target_player_number)):
		if point_on_planet().distance_to(building.global_position) < explosion_radius and not building.is_destroyed:
			if not building.is_destroyed:
				building.destroy()
				hit_building = true
	if not hit_building:
		planet.health -= planet_rocket_damage

	if planet.health <= 0:
		GameManager.game_over(target_player_number)

func is_closer(a, b):
	return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)

func find_new_target():
	if from_planet.playerNumber == 1:
		return get_node("/root/main/planet_2")
	else:
		return get_node("/root/main/planet_1")
