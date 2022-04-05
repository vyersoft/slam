extends Control
var player_1
var player_2
var round_n = 0
var p1_pow = 0
var p2_pow = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	randomize()
	
	if randi() % 10 + 1 <= 5:
		player_1 = get_node('/root/game_manager/')
		player_2 = get_node('/root/slam_AI/')
		print("Attacker:Player")
	else:
		player_1 = get_node('/root/slam_AI/')
		player_2 = get_node('/root/game_manager/')
		print("Attacker: AI")
	round_start()
	
func round_start():
	if $opponent.get_node("durability").value == 0:
		print("Player Wins!")
		var win_screen = game_manager.pop_up.instance()
		win_screen.get_node('CenterContainer/Panel/VBoxContainer/Label').text = "YOU WIN!!!"
		add_child(win_screen)
		
	elif $player.get_node("durability").value == 0:
		print("Player Lose!")
		var win_screen = game_manager.pop_up.instance()
		win_screen.get_node('CenterContainer/Panel/VBoxContainer/Label').text = "YOU LOSE!!!"
		add_child(win_screen)
	else:
		print("-------------------------------------------------------------------")
		print("ROUND "+ str(round_n))
		print("-------------------------------------------------------------------")
		round_n +=1
		for child in $player/grid_played.get_children():
			child.queue_free()
		for child in $opponent/grid_played.get_children():
			child.queue_free()
		for child in $player/grid_hand.get_children():
			child.disabled = false
			
		if round_n % 2 != 0:
			player_1.start_turn("Attack", 1)
			player_2.start_turn("Defence", 2)
		else:
			player_2.start_turn("Attack", 1)
			player_1.start_turn("Defence", 2)

func turn_tracker(power, turn_num):
	if turn_num == 1:
		p1_pow = power
	else:
		p2_pow = power

#	$roll_die.disabled = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
