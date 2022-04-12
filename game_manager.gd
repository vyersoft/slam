extends Node

#onready var game_board = get_node('/root/game_board/')
onready var game_board = get_node('/root/GameBoard/')

# Declare member variables here. Examples:
onready var player_deck = preload("res://Assets/TempDatabase/game_deck.gd")
var player_stance
var player_power 
var Player_hand = []
var Player_discard =[]
var Player_move = 3
var die_roll
var base_durability
var durability
var momentum_max
var turn_order = 2 #starts as 2nd Player by default
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
var alignment #defines alignment

#for updating labels and buttons
onready var die_label = game_board.get_node('Die/DieRoll')
onready var finisher_button = game_board.get_node('FinisherButton')
#onready var durability_bar
#onready var momentum_bar

#for Announcers
var commentary= preload("res://Assets/TempDatabase/comments.gd")

var pop_up = preload('res://pop_up.tscn')

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
#	var select_slammer = randi() % 10
	var select_slammer = "1611" #fixed character for the alpha.
	slammer = slammer_data.slammer[select_slammer]
	game_board.get_node("Player/Slammer").texture = load("res://Assets/Slammers/" + str(select_slammer) + ".png")
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
	game_board.get_node('Player/DurabilityBar').max_value = base_durability
	game_board.get_node('Player/DurabilityBar').value = base_durability
	
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
	game_board.get_node('Player/MomentumBar').max_value = momentum_max
	
	fill_hud("Player")

func draw_cap():
#	print("Player Deck:", player_deck.Powerhouz)
	print("-------------------------------------------------------------------")
	print("Player Draws...")
	if player_deck.Powerhouz.size() == 0:
		print("Discard: ", Player_discard)
		print("shuffling...")
		for n in Player_discard.size():
			player_deck.Powerhouz.append(Player_discard.pop_back())
			print(player_deck.Powerhouz.size())
			
	var selected_cap = randi() % player_deck.Powerhouz.size()
	var new_cap = Cap.new(player_deck.Powerhouz[selected_cap])
	Player_hand.append(new_cap.cap)
	game_board.get_node('HandPanel/HandContainer').add_child(new_cap)
	player_deck.Powerhouz.erase(player_deck.Powerhouz[selected_cap])

func end_turn():
	game_board.get_node('AnnouncerPanel/PanelButton').text = "Roll"
	for child in game_board.get_node('HandPanel/HandContainer').get_children():
		child.disabled = true
		
	print("-------------------------------------------------------------------")
	print("Hand: ", str(Player_hand))
	print("Deck: ", str(player_deck.Powerhouz))
	print("Discard: ",str(Player_discard))
	print("-------------------------------------------------------------------")
	game_board.turn_tracker(player_power, turn_order)
#	game_board.get_node('roll_die').disabled = false

func play_cap(img):
	var played = PlayedCap.new(img)
#	power_label.text = str(player_power)
	game_board.get_node('Player/PlayContainer').add_child(played)

func commit_cap(cap_name):
	Player_discard.append(cap_name)
	Player_hand.erase(cap_name)
	Player_move -= 1
	print("-------------------------------------------------------------------")
	print("Discard:", Player_discard)
	print("Hand:", Player_hand)
	print("-------------------------------------------------------------------")
	if Player_move == 0:
		end_turn()

func update_momentum(user):
	game_board.get_node(str(user)+'/MomentumBar').value += 1

func check_finisher():
	if game_board.get_node('Player/MomentumBar').value == momentum_max:
		if player_stance == "Attack" and success == 3:
			finisher_button.disabled = false
			finisher_button.visible = true
		else:
			finisher_button.disabled = true
			finisher_button.visible = false
	else:
		finisher_button.disabled = true
		finisher_button.visible = false

func update_durability(user, damage):
	game_board.get_node(str(user) + '/DurabilityBar').value -= abs(damage)
	print(user)
	print(game_board.get_node(str(user) + '/DurabilityBar').value)

func update_power(user, power):
	if user == 'Player':
		player_power += power
		success+=1
		print("Player Success:", success)
		check_finisher()
#		game_board.get_node(str(user) + '/power_display/VBoxContainer/power').text = str(player_power)
	else:
		slam_AI.player_power += power
		slam_AI.check_success()
#		game_board.get_node(str(user) + '/power_display/VBoxContainer/power').text = str(slam_AI.player_power)

func calculate_power(result, cap_info, stance, user_strength, user_speed):
	if result >= cap_info[1]:
		if stance == "Attack":
			return cap_info[3] + user_strength
		else:
			return cap_info[4] + user_speed
	else:
		return 0

func check_played_cap(user, die, stance, user_strenght, user_speed):
	if game_board.get_node(str(user) + '/PlayContainer').get_child_count() > move:
		var Player_cap = game_board.get_node(str(user) + '/PlayContainer').get_child(move)
		Player_cap.disabled = false
		var power = calculate_power(die, Player_cap.cap_info, stance, user_strenght, user_speed)
		if power == 0:
			Player_cap.pressed = true
#			game_board.get_node('AnnouncerPanel/Speech1/Text').text = str(commentary.Miss[Player_cap.cap])
			for child in game_board.get_node(str(user) + '/PlayContainer').get_children():
				if child.disabled == true:
					child.queue_free()
		else:
			update_momentum(user)
			update_power(user, power)
			set_dialogue(user, "Hit", Player_cap.cap)

func set_dialogue(user, state, cap_name):
	if user == "Player":
		if state == "Hit":
			var dialogue = commentary.Hit[cap_name]
			game_board.get_node('AnnouncerPanel/Speech1/Text').text = dialogue[0]
			game_board.get_node('AnnouncerPanel/Speech2/Text').text = dialogue[1]
		else:
			var dialogue = commentary.Miss[cap_name]
			game_board.get_node('AnnouncerPanel/Speech1/Text').text = dialogue[0]
			game_board.get_node('AnnouncerPanel/Speech2/Text').text = dialogue[1]


func calculate_damage():
	var damage

	if player_stance == "Attack":
		damage = player_power - slam_AI.player_power
		if damage > 0:
			update_durability("Opponent", damage)
		else:
			update_durability("Player", damage)
	else:
		damage = slam_AI.player_power - player_power
		if damage > 0:
			update_durability("Player", damage)
		else:
			update_durability("Opponent", damage)
		print("Damage: " + str(damage))

func resolve_round():
	print("Move:", move)
	if move <= 2:
		var die = roll_die()
		check_played_cap("Player", die, player_stance, strength, speed)
		check_played_cap("Opponent", die, slam_AI.player_stance, slam_AI.strength, slam_AI.speed)
		check_finisher()
		move += 1
		if move == 3:
			game_board.get_node('AnnouncerPanel/PanelButton').text = "Deal Damage"
			move += 1
	elif move == 4:
		game_board.get_node('AnnouncerPanel/PanelButton').text = "Next Round"
		calculate_damage()
		print("Player Power:", player_power)
		print("AI Power:", slam_AI.player_power)
		print("Player HP:", game_board.get_node('Player/DurabilityBar').value)
		print("AI HP:", game_board.get_node('Opponent/DurabilityBar').value)
		move += 1
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
	success = 0
	player_power = 0
	Player_move = 3
	player_stance = stance
	if player_stance == "Attack":
		game_board.get_node('HandPanel').color = Color(1, 0, 0, 1)
	else:
		game_board.get_node('HandPanel').color = Color(0, 0, 1, 1)
#	stance_label.text = stance
#	stance_label.text = Player_stance
#	power_label.text = str(player_power)
	game_board.get_node('AnnouncerPanel/PanelButton').text = "Pass"

	for n in x_factor + 2 - Player_hand.size(): #draw caps by x_factor
		draw_cap()
	print("Hand:"+str(Player_hand))
	print("-------------------------------------------------------------------")

func fill_hud(user):
#	var hud_res = game_board.get_node('hud/Panel/' + user + '/stat_box/resilience/value')
#	var hud_str = game_board.get_node('hud/Panel/' + user + '/stat_box/strength/value')
#	var hud_spe = game_board.get_node('hud/Panel/' + user + '/stat_box/speed/value')
#	var hud_x = game_board.get_node('hud/Panel/' + user + '/stat_box/x_factor/value')
#	var hud_cha = game_board.get_node('hud/Panel/' + user + '/stat_box/charisma/value')
#	var hud_ali = game_board.get_node('hud/Panel/' + user + '/stat_box/alignment/value')
	var hud_res = game_board.get_node(user + '/Stats/Resilience/Label')
	var hud_str = game_board.get_node(user + '/Stats/Strength/Label')
	var hud_spe = game_board.get_node(user + '/Stats/Speed/Label')
	var hud_x = game_board.get_node(user + '/Stats/X-Factor/Label')
	var hud_cha = game_board.get_node(user + '/Stats/Charisma/Label')
	var hud_ali = game_board.get_node(user + '/Alignment')
	
	hud_res.text = str(resilience)
	hud_str.text = str(strength)
	hud_spe.text = str(speed)
	hud_x.text = str(x_factor)
	hud_cha.text = str(charisma)
	hud_ali.text = alignment

