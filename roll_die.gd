extends Button

# Declare member variables here. Examples:
#var move = 0
#var player_failed = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _pressed():
	var status = game_manager.resolve_round()
	if status == true:
		disabled = true
		text = "Roll Die!"
#	var result = game_manager.roll_die()
#
#	if move <= 2:
#		if get_node('../player/grid_played').get_child_count() > move:
#			var player_cap = get_node('../player/grid_played').get_child(move)
#			player_cap.disabled = false
#			var power = calculate_power(result, player_cap.cap_info, game_manager.player_stance)
#			if power == 0:
#				player_cap.pressed = true
#				for child in get_node('../player/grid_played').get_children():
#					if child.disabled == true:
#						child.queue_free()
#			game_manager.update_power(power)
#
#		if get_node('../opponent/grid_played').get_child_count() != 0:
#			var opponent_cap = get_node('../opponent/grid_played').get_child(move)
#			opponent_cap.disabled = false
#			calculate_power(result, opponent_cap.cap_info, slam_AI.player_stance)
#
#		move += 1
#		if move == 3:
#			move = 0
#			text = "Next Round"
#	else:
#		print("New Round...")
#
#func calculate_power(result, cap_info, stance):
#	if result >= cap_info[1]:
#		if stance == "Attack":
#			return cap_info[3]
#		else:
#			return cap_info[4]
#	else:
#		return 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
