extends Node

onready var game_board = get_node('/root/game_board/')

# Declare member variables here. Examples:
onready var player_deck = preload("res://Assets/TempDatabase/game_deck.gd")
#var deck_size = player_deck.deck_list.size()
var player_stance
var player_power 
var player_hand = []
var player_discard =[]
var player_move = 3
var die_roll
var base_durability
var durability
var momentum_max
var turn_order = 2 #starts as 2nd player by default
var move = 0 #for resolving played caps
var success = 0

#slammer stats
const slammer_data = preload("res://Assets/TempDatabase/slammer_data.gd")
var slammer
var resilience #defines durability
var strength #adds atk
var speed #adds def
var x_factor #defines hand size
var charisma #defines momentum
var alignment

#for updating labels
onready var die_label = game_board.get_node('die_roll/Panel/VBoxContainer/die_roll')
onready var power_label = game_board.get_node('player/power_display/VBoxContainer/power')
onready var stance_label = game_board.get_node('player/power_display/VBoxContainer/stance')

var pop_up = preload('res://pop_up.tscn')

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
#	var select_slammer = randi() % 10
	var select_slammer = "1611" #fixed character for the alpha.
	slammer = slammer_data.slammer[select_slammer]
	game_board.get_node("hud/Panel/player/img").texture = load("res://Assets/Slammers/" + str(select_slammer) + ".png")
	print("Slammer Stats:", str(slammer))
	var splash = pop_up.instance()
	game_board.add_child(splash)
	setup()
	
func setup():
	resilience = slammer[0]
	strength = slammer[1]
	speed = slammer[2]
	x_factor = slammer[3]
	charisma = slammer[4]
	alignment = slammer[5]
	
	#set base_durability
	if resilience == 5:
		base_durability = 58
	elif resilience == 4:
		base_durability = 56
	elif resilience == 3:
		base_durability = 54
	elif resilience == 2:
		base_durability = 52
	else:
		base_durability = 50
	game_board.get_node('player/durability').max_value = base_durability
	game_board.get_node('player/durability').value = base_durability
	
	#set momentum_max
	if charisma == 5:
		momentum_max = 3
	elif charisma == 4:
		momentum_max = 4
	elif charisma == 3:
		momentum_max = 5
	elif charisma == 2:
		momentum_max = 6
	else:
		momentum_max = 7
	game_board.get_node('player/momentum_bar').max_value = momentum_max
	
	fill_hud("player")

func draw_cap():
#	print("Player Deck:", player_deck.deck_list)
	print("-------------------------------------------------------------------")
	print("Player Draws...")
	if player_deck.deck_list.size() == 0:
		print("Discard: ", player_discard)
		print("shuffling...")
		for n in player_discard.size():
			player_deck.deck_list.append(player_discard.pop_back())
			print(player_deck.deck_list.size())
			
	var selected_cap = randi() % player_deck.deck_list.size()
	var new_cap = Cap.new(player_deck.deck_list[selected_cap])
	player_hand.append(new_cap.cap)
	game_board.get_node('player/grid_hand').add_child(new_cap)
	player_deck.deck_list.erase(player_deck.deck_list[selected_cap])

func end_turn():
	game_board.get_node('end_button').disabled = true
	for child in game_board.get_node('player/grid_hand').get_children():
		child.disabled = true
		
	print("-------------------------------------------------------------------")
	print("Hand: ", str(player_hand))
	print("Deck: ", str(player_deck.deck_list))
	print("Discard: ",str(player_discard))
	print("-------------------------------------------------------------------")
	game_board.turn_tracker(player_power, turn_order)
	game_board.get_node('roll_die').disabled = false

func play_cap(img):
	var played = PlayedCap.new(img)
	power_label.text = str(player_power)
	game_board.get_node('player/grid_played').add_child(played)

func commit_cap(cap_name):
	player_discard.append(cap_name)
	player_hand.erase(cap_name)
	player_move -= 1
	print("-------------------------------------------------------------------")
	print("Discard:", player_discard)
	print("Hand:", player_hand)
	print("-------------------------------------------------------------------")
	if player_move == 0:
		end_turn()

func update_momentum(user):
	game_board.get_node(str(user)+'/momentum_bar').value += 1

func check_finisher():
	if game_board.get_node('player/momentum_bar').value == momentum_max:
		if player_stance == "Attack" or game_board.get_node('opponent/momentum_bar').value == momentum_max:
			game_board.get_node('player/finisher_button').disabled = false
		else:
			game_board.get_node('player/finisher_button').disabled = true
	else:
		game_board.get_node('player/finisher_button').disabled = true

func update_durability(user, damage):
	game_board.get_node(str(user) + '/durability').value -= abs(damage)
	print(user)
	print(game_board.get_node(str(user) + '/durability').value)

func update_power(user, power):
	if user == 'player':
		player_power += power
		game_board.get_node(str(user) + '/power_display/VBoxContainer/power').text = str(player_power)
	else:
		slam_AI.player_power += power
		slam_AI.check_success()
		game_board.get_node(str(user) + '/power_display/VBoxContainer/power').text = str(slam_AI.player_power)

func calculate_power(result, cap_info, stance, user_strength, user_speed):
	if result >= cap_info[1]:
		if stance == "Attack":
			return cap_info[3] + user_strength
		else:
			return cap_info[4] + user_speed
	else:
		return 0

func check_played_cap(user, die, stance, user_strenght, user_speed):
	if game_board.get_node(str(user) + '/grid_played').get_child_count() > move:
		var player_cap = game_board.get_node(str(user) + '/grid_played').get_child(move)
		player_cap.disabled = false
		var power = calculate_power(die, player_cap.cap_info, stance, user_strenght, user_speed)
		if power == 0:
			player_cap.pressed = true
			for child in game_board.get_node(str(user) + '/grid_played').get_children():
				if child.disabled == true:
					child.queue_free()
		else:
			update_momentum(user)
			update_power(user, power)

func calculate_damage():
	var damage

	if player_stance == "Attack":
		damage = player_power - slam_AI.player_power
		if damage > 0:
			update_durability("opponent", damage)
		else:
			update_durability("player", damage)
	else:
		damage = slam_AI.player_power - player_power
		if damage > 0:
			update_durability("player", damage)
		else:
			update_durability("opponent", damage)
		print("Damage: " + str(damage))

func resolve_round():
	if move <= 2:
		var die = roll_die()
		check_played_cap("player", die, player_stance, strength, speed)
		check_played_cap("opponent", die, slam_AI.player_stance, slam_AI.strength, slam_AI.speed)
		check_finisher()
		move += 1
		if move == 3:
			game_board.get_node('roll_die').text = "Next Round"
			calculate_damage()
			print("Player HP:", game_board.get_node('player/durability').value)
			print("AI HP:", game_board.get_node('opponent/durability').value)

	else:
		print("New Round...")
		move = 0
		game_board.round_start()
		return true

func roll_die():
	for n in 3:
		die_roll = randi() % 6 + 1
	die_label.text = str(die_roll)
	return die_roll

func start_turn(stance, turn_num):
	print("-------------------------------------------------------------------")
	print("Player turn starts...")
	print("-------------------------------------------------------------------")
	check_finisher()
	turn_order = turn_num
	player_power = 0
	player_move = 3
	player_stance = stance
	stance_label.text = stance
#	stance_label.text = player_stance
	power_label.text = str(player_power)
	game_board.get_node('end_button').disabled = false

	for n in x_factor + 2 - player_hand.size(): #draw caps by x_factor
		draw_cap()
	print("Hand:"+str(player_hand))
	print("-------------------------------------------------------------------")

func fill_hud(user):
	var hud_res = game_board.get_node('hud/Panel/' + user + '/stat_box/resilience/value')
	var hud_str = game_board.get_node('hud/Panel/' + user + '/stat_box/strength/value')
	var hud_spe = game_board.get_node('hud/Panel/' + user + '/stat_box/speed/value')
	var hud_x = game_board.get_node('hud/Panel/' + user + '/stat_box/x_factor/value')
	var hud_cha = game_board.get_node('hud/Panel/' + user + '/stat_box/charisma/value')
	var hud_ali = game_board.get_node('hud/Panel/' + user + '/stat_box/alignment/value')
	
	hud_res.text = str(resilience)
	hud_str.text = str(strength)
	hud_spe.text = str(speed)
	hud_x.text = str(x_factor)
	hud_cha.text = str(charisma)
	hud_ali.text = alignment
	
	
	
	
