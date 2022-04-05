extends Node

onready var game_board = get_node('/root/game_board/')

# Declare member variables here. Examples:
onready var player_deck = preload("res://Assets/TempDatabase/game_deck.gd")
onready var my_slammers = preload("res://Assets/TempDatabase/my_slammers.gd")
#var deck_size = player_deck.deck_list.size()
var player_stance
var player_power 
var player_hand = []
var player_discard = []
var player_move = 3
var die_roll
var base_durability
var momentum_max
var turn_order = 2 #starts 2nd by default
var success = 0

#slammer stats
const slammer_data = preload("res://Assets/TempDatabase/slammer_data.gd")
var slammer
var resilience
var strength
var speed
var x_factor
var charisma
var alignment

#for updating labels
onready var die_label = game_board.get_node('die_roll/Panel/VBoxContainer/die_roll')
onready var power_label = game_board.get_node('opponent/power_display/VBoxContainer/power')
onready var stance_label = game_board.get_node('opponent/power_display/VBoxContainer/stance')

#AI specific
var cap_database = preload('res://Assets/TempDatabase/move_cap_data.gd')
#var cap_info =[]
#var cap

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
#	var select_slammer = randi() % my_slammers.slammer.size()
	var select_slammer = my_slammers.slammer[randi() % my_slammers.slammer.size()]
	slammer = slammer_data.slammer[select_slammer]
	game_board.get_node("hud/Panel/opponent/img").texture = load("res://Assets/Slammers/" + str(select_slammer) + ".png")
	print("AI Stats:", slammer)
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
	game_board.get_node('opponent/durability').max_value = base_durability
	game_board.get_node('opponent/durability').value = base_durability
	
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
	game_board.get_node('opponent/momentum_bar').max_value = momentum_max
	fill_hud("opponent")

func draw_cap():
#	print("AI Draws...")
	if player_deck.deck_list.size() == 0:
		
		print("shuffling...")
		for n in player_discard.size():
			player_deck.deck_list.append(player_discard.pop_back())
		print("Player Deck: ", str(player_deck.deck_list.size()))
			
	var selected_cap = randi() % player_deck.deck_list.size()
	var new_cap = Cap.new(player_deck.deck_list[selected_cap])
	player_hand.append(new_cap.cap)
	new_cap.disabled = true
#	game_board.get_node('opponent/grid_hand').add_child(new_cap)
	player_deck.deck_list.erase(player_deck.deck_list[selected_cap])

func discard_hand():
	var hand_size = player_hand.size()
	
	for n in hand_size:
		player_discard.append(player_hand.pop_front())


func play_cap(img):
	var played = PlayedCap.new(img)
	power_label.text = str(player_power)
	game_board.get_node('opponent/grid_played').add_child(played)

func update_momentum():
	game_board.get_node('opponent/momentum_bar').value += 1
	
func update_durability(damage):
	game_board.get_node('opponent/durability').value -= damage

func check_finisher():
	if game_board.get_node('opponent/momentum_bar').value == momentum_max:
		game_board.get_node('opponent/finisher_button').disabled = false
		return true
	else:
		return false

func new_round():
	if player_stance == "Attack":
		player_stance = "Defence"
	else:
		player_stance = "Attack"
	
	player_power = 0
	player_move = 3
	stance_label.text = player_stance
	power_label.text = str(player_power)
	for child in game_board.get_node('grid_opponent_played').get_children():
		child.queue_free()
	
	for n in x_factor + 2: #affected by x_factor
		draw_cap()
	print("Hand:"+str(player_hand))

func roll_die():
	for n in 3:
		die_roll = randi() % 6 + 1
#		die_label = game_board.get_node('die_roll/Panel/VBoxContainer/die_roll')
		die_label.text = str(die_roll)
	return die_roll

func start_turn(stance, turn_num):
	check_finisher()
	turn_order = turn_num
	player_stance = stance
	stance_label.text = str(stance)
	player_power = 0
	success = 0
	
	if game_board.get_node('opponent/finisher_button').disabled == false:
		player_move = 3
	else:
		player_move = randi() % 2 +1
	print("-------------------------------------------------------------------")
	print("AI turn starts...")
	print("-------------------------------------------------------------------")
	
	power_label.text = str(player_power)

	for n in x_factor + 2: #draw caps by x_factor
		draw_cap()
	print("Hand:"+str(player_hand))
	while player_move != 0:
		auto_play()
#		print("succes:", success)
#	if success == 3 and finish_him == true and player_stance == "Attack":
#		use_finisher()
		
	game_board.turn_tracker(player_power, turn_order)

func check_success():
	success += 1
	print("Success:", success)
	if success == 3:
		use_finisher()

func use_finisher():
	if game_board.get_node('opponent/momentum_bar').value == momentum_max and player_stance == "Attack":
		print("FINISH HIM!!!")
		game_board.get_node('opponent/momentum_bar').value = 0
		game_board.get_node('opponent/finisher_button').disabled = true
		game_manager.update_power("opponent", 25)
	
func full_counter():
	if check_finisher() == true:
		print("FULL COUNTER!!!")
		game_manager.update_power("opponent", 25)
		game_board.get_node('opponent/momentum_bar').value = 0
	else:
		print("It's a hit!")

func discard_cap(cap_name):
	player_discard.append(cap_name)
	print("-------------------------------------------------------------------")
	print("Discard: ",str(player_discard))

func auto_play():
	
	var cap = player_hand.pop_front()
	print("Played: ", cap)
	play_cap(cap)
	discard_cap(cap)
	player_move -= 1
#
	print("Power Value: " + str(player_power))
	if player_move == 0:
		discard_hand()

func discad_cap():
	var child = game_board.get_node('opponent/grid_hand').get_child(0)
	child.queue_free()

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
