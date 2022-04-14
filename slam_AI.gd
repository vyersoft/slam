extends Node

#onready var game_board = get_node('/root/game_board/')
onready var game_board = get_node('/root/GameBoard/')

# Declare member variables here. Examples:
onready var player_deck = preload("res://Assets/TempDatabase/game_deck.gd")
onready var my_slammers = preload("res://Assets/TempDatabase/my_slammers.gd")
#var deck_size = player_deck.Powerhouz.size()
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

var active_finisher = false

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
#onready var die_label = game_board.get_node('die_roll/Panel/VBoxContainer/die_roll')
#onready var power_label = game_board.get_node('Opponent/power_display/VBoxContainer/power')
#onready var stance_label = game_board.get_node('Opponent/power_display/VBoxContainer/stance')

#AI specific
var cap_database = preload('res://Assets/TempDatabase/move_cap_data.gd')
#var cap_info =[]
#var cap

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

#	set_player()
#	setup()
	
func set_player():
	var select_slammer = my_slammers.slammer[randi() % my_slammers.slammer.size()]
	slammer = slammer_data.slammer[select_slammer]
	game_board.get_node("Opponent/Slammer").texture = load("res://Assets/Slammers/" + str(select_slammer) + ".png")
	print("AI Stats:", slammer)
	
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
	game_board.get_node('Opponent/DurabilityBar').max_value = base_durability
	game_board.get_node('Opponent/DurabilityBar').value = base_durability
	
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
	game_board.get_node('Opponent/MomentumBar').max_value = momentum_max
	game_manager.fill_hud("Opponent")

func draw_cap():
#	print("AI Draws...")
	if player_deck.Powerhouz.size() == 0:
		
		print("shuffling...")
		for n in player_discard.size():
			player_deck.Powerhouz.append(player_discard.pop_back())
		print("Player Deck: ", str(player_deck.Powerhouz.size()))
			
	var selected_cap = randi() % player_deck.Powerhouz.size()
	var new_cap = Cap.new(player_deck.Powerhouz[selected_cap])
	player_hand.append(new_cap.cap)
	new_cap.disabled = true
#	game_board.get_node('Opponent/grid_hand').add_child(new_cap)
	player_deck.Powerhouz.erase(player_deck.Powerhouz[selected_cap])

func discard_hand():
	var hand_size = player_hand.size()
	
	for n in hand_size:
		player_discard.append(player_hand.pop_front())

func reset_deck():
	var hand_size = player_hand.size()
	for caps in hand_size:
		player_discard.append(player_hand.pop_front())
	for caps in player_discard.size():
		player_deck.Powerhouz.append(player_discard.pop_back())

func play_cap(img):
	var played = PlayedCap.new(img)
#	power_label.text = str(player_power)
	game_board.get_node('Opponent/PlayContainer').add_child(played)

#func update_momentum():
#	game_board.get_node('Opponent/MomentumBar').value += 1
	
#func update_durability(damage):
#	game_board.get_node('Opponent/DurabilityBar').value -= damage

func check_finisher():
	if game_board.get_node('Opponent/MomentumBar').value == momentum_max:
#		game_board.get_node('Opponent/finisher_button').disabled = false
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
#	stance_label.text = player_stance
#	power_label.text = str(player_power)
	for child in game_board.get_node('grid_Opponent_played').get_children():
		child.queue_free()
	
	for n in x_factor + 2: #affected by x_factor
		draw_cap()
	print("Hand:"+str(player_hand))

func start_turn(stance, turn_num):
	check_finisher()
	turn_order = turn_num
	player_stance = stance
#	stance_label.text = str(stance)
	player_power = 0
	success = 0
	
	if game_board.get_node('Opponent/MomentumBar').value == momentum_max:
		player_move = 3
	else:
		player_move = randi() % 2 +1
		if player_move == 1:
			player_move = 2
	print("-------------------------------------------------------------------")
	print("AI turn starts...")
	print("-------------------------------------------------------------------")
	
#	power_label.text = str(player_power)

	for n in x_factor + 2: #draw caps by x_factor
		draw_cap()
	print("Hand:"+str(player_hand))
	while player_move != 0:
		auto_play()
#		print("succes:", success)
#	if success == 3 and finish_him == true and player_stance == "Attack":
#		use_finisher()
		
	game_manager.turn_tracker(player_power, turn_order)

func check_success():
	success += 1
	print("Success:", success)
	if success == 3:
		use_finisher()

func use_finisher():
	if game_board.get_node('Opponent/MomentumBar').value == momentum_max and player_stance == "Attack":
		print("FINISH HIM!!!")
		game_board.get_node('Opponent/MomentumBar').value = 0
#		game_board.get_node('Opponent/finisher_button').disabled = true
		game_manager.update_power("Opponent", 25)
	
func full_counter():
	if check_finisher() == true:
		print("FULL COUNTER!!!")
		game_manager.dub.text = "AAAND HE WENT FOR IT!"
		game_manager.matt.text = "[P2] COUNTERS!!!"
		game_manager.update_power("Opponent", 25)
		game_board.get_node('Opponent/MomentumBar').value = 0
	else:
		print("It's a hit!")
		game_manager.dub.text = "AAAAND [P2] WILL BE ON MEDICAL LEAVE!"
		game_manager.matt.text = "IT'S A DIRECT HIT!!!"

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
	var child = game_board.get_node('Opponent/grid_hand').get_child(0)
	child.queue_free()
