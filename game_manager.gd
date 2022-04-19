extends Node

#set the gameboard
onready var game_board = get_node('/root/GameBoard/')

var username = ""
var userSLAM = 0
var top5Data = []
var currAction = ""
var wins = 0



var player_stance
var player_power 
var player_hand = []
var player_discard =[]
var player_move = 3
var die_roll
var base_durability
var durability
var momentum_max
var turn_order = 2 #starts as 2nd Player by default
var move = 0 #for resolving played caps
var success = 0

#var roll_timer = Timer.new()

#slammer stats
const slammer_data = preload("res://Assets/TempDatabase/slammer_data.gd")
var slammer
var resilience #defines durability
var strength #adds atk
var speed #adds def
var x_factor #defines hand size
var charisma #defines momentum
var alignment #defines alignment

#setting the player deck
onready var player_deck = preload("res://Assets/TempDatabase/game_deck.gd")
onready var http: HTTPRequest = HTTPRequest.new()
#for updating labels and buttons
onready var die_label = game_board.get_node('Die/DieRoll')
onready var finisher_button = game_board.get_node('FinisherButton')
onready var die_face = game_board.get_node('DieFace')
#onready var durability_bar
#onready var momentum_bar

#GameBoard Variables
var player_1
var player_2
var round_n = 0
var p1_pow = 0
var p2_pow = 0
onready var hand_container = game_board.get_node("HandPanel/HandContainer")
onready var player_played = game_board.get_node("Player/PlayContainer")
onready var player_durability = game_board.get_node("Player/DurabilityBar")
onready var opponent_played = game_board.get_node("Opponent/PlayContainer")
onready var opponent_durability = game_board.get_node("Opponent/DurabilityBar")

#set announcers and dialouges
#var commentary= preload("res://Assets/TempDatabase/comments.gd")
onready var dub = game_board.get_node("AnnouncerPanel/Speech1/Text")
onready var matt = game_board.get_node("AnnouncerPanel/Speech2/Text")

var pop_up = preload('res://pop_up.tscn')
var Hit = {}
var Miss = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	add_child(http)
#	var splash = pop_up.instance()
#	game_board.add_child(splash)
#	setup_timer()
#	set_player()
#	setup()

#func setup_timer():
#	roll_timer.connect("timeout", self, "roll_die")
#	roll_timer.set_one_shot(true)
#	add_child(roll_timer)
func _on_HTTP_request_completed(result, _response_code, _headers, body ):
	print("got response")
	if result == 0:
		var json = JSON.parse(body.get_string_from_utf8())
		print(json)
		
func reset_hand():
	for child in game_board.get_node("HandPanel/HandContainer").get_children():
		child.queue_free()

func set_turns():
	if randi() % 10 + 1 <= 5:
		player_1 = game_board.get_node('/root/game_manager/')
		player_2 = game_board.get_node('/root/slam_AI/')
		print("Attacker:Player")
	else:
		player_1 = game_board.get_node('/root/slam_AI/')
		player_2 = game_board.get_node('/root/game_manager/')
		print("Attacker: AI")
		
func round_start():
	if opponent_durability.value == 0:
		print("Player Wins!")
		var win_screen = pop_up.instance()
		win_screen.get_node('CenterContainer/Panel/VBoxContainer/Label').text = "YOU WIN!!!"
		win_screen.get_node("CenterContainer/Panel/StartButton").text = "Play again"
		game_board.add_child(win_screen)
		var body = {"username":username, "slamEarned": 100, "won": true}
		http.request("https://us-central1-scd-vote.cloudfunctions.net/app/updateSlamRecord", PoolStringArray(["Content-Type: application/json"]), true, HTTPClient.METHOD_POST,to_json(body) )
		round_n = 0
		game_board.get_node('Player/MomentumBar').value = 0
		game_board.get_node('Opponent/MomentumBar').value = 0
		
	elif player_durability.value == 0:
		print("Player Lose!")
		var win_screen = pop_up.instance()
		win_screen.get_node('CenterContainer/Panel/VBoxContainer/Label').text = "YOU LOSE!!!"
		win_screen.get_node("CenterContainer/Panel/StartButton").text = "Play again"
		game_board.add_child(win_screen)
		var body = {"username":username, "slamEarned": 50, "won": false}
		http.request("https://us-central1-scd-vote.cloudfunctions.net/app/updateSlamRecord", PoolStringArray(["Content-Type: application/json"]), true, HTTPClient.METHOD_POST,to_json(body) )
		round_n = 0
		game_board.get_node('Player/MomentumBar').value = 0
		game_board.get_node('Opponent/MomentumBar').value = 0
	else:
		print("-------------------------------------------------------------------")
		print("ROUND "+ str(round_n))
		print("-------------------------------------------------------------------")
		round_n +=1
		for child in player_played.get_children():
			child.queue_free()
		for child in opponent_played.get_children():
			child.queue_free()
		for child in hand_container.get_children():
			child.disabled = false
			
		if round_n % 2 != 0:
			player_1.start_turn("Attack", 1)
			player_2.start_turn("Defence", 2)
		else:
			player_2.start_turn("Attack", 1)
			player_1.start_turn("Defence", 2)
			
	dub.text = "It's Round " + str(round_n)
	matt.text = str(username).left(5) + " is on the " + player_stance + "!"
	game_board.get_node('Player/Slammer/Stance').texture = load("res://Assets/Images/" + player_stance + ".png")
	game_board.get_node('Opponent/Slammer/Stance').texture = load("res://Assets/Images/" + slam_AI.player_stance + ".png")

	
func turn_tracker(power, turn_num):
	if turn_num == 1:
		p1_pow = power
	else:
		p2_pow = power

func set_player():
	var select_slammer = "1611" #fixed character for the alpha.
	slammer = slammer_data.slammer[select_slammer]
	game_board.get_node("Player/Slammer").texture = load("res://Assets/Slammers/" + str(select_slammer) + ".png")
	game_board.get_node('Player/Username').text  = username 
	print("Slammer Stats:", str(slammer))

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
		print("Discard: ", player_discard)
		print("shuffling...")
		for n in player_discard.size():
			player_deck.Powerhouz.append(player_discard.pop_back())
			print(player_deck.Powerhouz.size())
	var selected_cap = randi() % player_deck.Powerhouz.size()
	var new_cap = Cap.new(player_deck.Powerhouz[selected_cap])
	player_hand.append(new_cap.cap)
	game_board.get_node('HandPanel/HandContainer').add_child(new_cap)
	player_deck.Powerhouz.erase(player_deck.Powerhouz[selected_cap])

func reset_deck():
	var hand_size = player_hand.size()
	for caps in hand_size:
		player_discard.append(player_hand.pop_front())
	for caps in player_discard.size():
		player_deck.Powerhouz.append(player_discard.pop_back())


func end_turn():
	dub.text = "It's time settle this."
	matt.text = "Let's SLAM!"
	game_board.get_node('AnnouncerPanel/PanelButton').text = "Roll"
	for child in game_board.get_node('HandPanel/HandContainer').get_children():
		child.disabled = true
		
	print("-------------------------------------------------------------------")
	print("Hand: ", str(player_hand))
	print("Deck: ", str(player_deck.Powerhouz))
	print("Discard: ",str(player_discard))
	print("-------------------------------------------------------------------")
	turn_tracker(player_power, turn_order)
#	game_board.get_node('roll_die').disabled = false

func play_cap(img):
	var played = PlayedCap.new(img)
	game_board.get_node('Player/PlayContainer').add_child(played)

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
	game_board.get_node(str(user)+'/MomentumBar').value += 1

func check_finisher():
	if game_board.get_node('Player/MomentumBar').value == momentum_max:
		if player_stance == "Attack" and success == 3:
			dub.text = str(username).left(5) + " is up for a finisher!"
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
			set_dialogue(user, "Miss", Player_cap.cap)
			Player_cap.pressed = true
#			game_board.get_node('AnnouncerPanel/Speech1/Text').text = str(commentary.Miss[Player_cap.cap])
			for child in game_board.get_node(str(user) + '/PlayContainer').get_children():
				if child.disabled == true:
					child.queue_free()
			return false
		else:
			update_momentum(user)
			update_power(user, power)
			set_dialogue(user, "Hit", Player_cap.cap)
	else:
		return false

func set_dialogue(user, state, cap_name):
	Hit = {
		"Vertical Suplex Powerbomb": 
			[
				str(game_manager.username.left(5)) + " Just went nuclear on "+"#"+str(slam_AI.select_slammer) + " with a Vertical Suplex Powerbomb!", 
				"I don't think "+"#"+str(slam_AI.select_slammer) + " is getting up after that..."
			],
		"Gorilla Press Drop":
			[
				str(game_manager.username.left(5)) + " Has "+"#"+str(slam_AI.select_slammer) + " lifted up above him for a Gorilla Press Drop!",
				"#"+str(slam_AI.select_slammer) + " Was not expecting a drop like that!"
			],
		"Double Underhook Power Bomb":
			[
				str(game_manager.username.left(5)) + " has "+"#"+str(slam_AI.select_slammer) + " locked! And lands a Double Underhook Power Bomb!",
				"No way "+"#"+str(slam_AI.select_slammer) + " gets up after that crushing blow!"
			],
		"Powerbomb": 
			[
				str(game_manager.username.left(5)) + " Launches and slams "+"#"+str(slam_AI.select_slammer) + " with a Powerbomb!",
				"#"+str(slam_AI.select_slammer) + " Is seeing stars!"
			],
		"Superplex": 
			[
				"Superplex! " + str(game_manager.username.left(5)) + "Absolutely stuns "+"#"+str(slam_AI.select_slammer)+"!",
				"Oh "+"#"+str(slam_AI.select_slammer) + " is not looking good after that!"
			],
		"Full Nelson": 
			[
				str(game_manager.username.left(5)) + " Snuck behind "+"#"+str(slam_AI.select_slammer) + " and put him into a Full Nelson!",
				"#"+str(slam_AI.select_slammer) + " Is not looking comfortable!"
			],
		"Hammerlock": 
			[
				str(game_manager.username.left(5)) + " Has the arm of "+"#"+str(slam_AI.select_slammer) + " behind his back in a Hammerlock!",
				"#"+str(slam_AI.select_slammer) + "'s arm is looking like a lost cause!"
			],
		"Ground and Pound": 
			[
				"Whoa! " + str(game_manager.username.left(5)) + " is cookin' with that Ground & Pound on "+"#"+str(slam_AI.select_slammer)+"", 
				"#"+str(slam_AI.select_slammer) + " Is gonna be chop liver after that!"
			],
		"Neck Breaker": 
			[
				"Oh no it's a Neck Breaker on "+"#"+str(slam_AI.select_slammer)+"!",
				str(game_manager.username.left(5)) + " Is ruthless in the streets!"
			],
		"Body Lock": 
			[
				"And just like that " + str(game_manager.username.left(5)) + "has strong armed "+"#"+str(slam_AI.select_slammer) + " into a Body Lock",
				"#"+str(slam_AI.select_slammer) + " Is going nowhere fast!"
			],
		"Choke Hold": 
			[
				"Oh no! " + str(game_manager.username.left(5)) + "has the neck of "+"#"+str(slam_AI.select_slammer) + " in a vicious Choke Hold",
				"I think "+"#"+str(slam_AI.select_slammer) + " is starting to turn purple!"
			],
		"Shoulder Block": 
			[
				"Grabbing "+"#"+str(slam_AI.select_slammer)+"'s arm, " + str(game_manager.username.left(5)) + "goes for an Armbar Leg Sweep attempt!",
				"#"+str(slam_AI.select_slammer) + " Was just flattened like a pancake!"
			],
		"Bear Hug": 
			[
				str(game_manager.username.left(5)) + " Has "+"#"+str(slam_AI.select_slammer) + " in a vicious bear hug!",
				"He's literally squeezing the life out of him!"
			],
		"Arm Bar Takedown": 
			[
				"Ouch! " + str(game_manager.username.left(5)) + "secured the Arm Bar Takedown on "+"#"+str(slam_AI.select_slammer)+"!",
				"How fast is  " + str(game_manager.username.left(5)) + "?!?"
			],
		"Waist Lock": 
			[
				"Whoa! That's a tight waist lock " + str(game_manager.username.left(5)) + "has on "+"#"+str(slam_AI.select_slammer),
				"Those ribs gotta be hurting for "+"#"+str(slam_AI.select_slammer)
			],

	}
	Miss = {
		"Vertical Suplex Powerbomb": 
			[
				str(game_manager.username.left(5)) + " Muscles "+"#"+str(slam_AI.select_slammer) + " into position for a Vertical Suplex Powerbomb", 
				"But "+"#"+str(slam_AI.select_slammer) + " breaks free! "
			],
		"Gorilla Press Drop":
			[
				str(game_manager.username.left(5)) + " Is lifting "+"#"+str(slam_AI.select_slammer) + " above his head for a Gorilla Press Drop! ",
				str(game_manager.username.left(5)) + " Doesn't have enough juice and "+"#"+str(slam_AI.select_slammer) + " escapes!"
			],
		"Double Underhook Power Bomb":
			[
				str(game_manager.username.left(5)) + " Locks up "+"#"+str(slam_AI.select_slammer) + " for a Double Underhook Power Bomb!",
				"But "+"#"+str(slam_AI.select_slammer) + " slips out of  " + str(game_manager.username.left(5)) + "'s hooks!"
			],
		"Powerbomb": 
			[
				str(game_manager.username.left(5)) + " Is trying to Powerbomb "+"#"+str(slam_AI.select_slammer)+"!",
				"But "+"#"+str(slam_AI.select_slammer) + " is glued to the floor and going nowhere!"
			],
		"Superplex": 
			[
				"Looks like " + str(game_manager.username.left(5)) + "is going for a Superplex on "+"#"+str(slam_AI.select_slammer)+"!",
				"But "+"#"+str(slam_AI.select_slammer) + " reverses and takes the advantage!"
			],
		"Full Nelson": 
			[
				str(game_manager.username.left(5)) + " Is behind "+"#"+str(slam_AI.select_slammer) + " trying to get him into a Full Nelson",
				"#"+str(slam_AI.select_slammer) + " Is too strong for " + str(game_manager.username.left(5)) + "and won't allow it!"
			],
		"Hammerlock": 
			[
				str(game_manager.username.left(5)) + " Grabs "+"#"+str(slam_AI.select_slammer)+"'s arm and goes for a Hammerlock!",
				"#"+str(slam_AI.select_slammer) + " Twists and turns his way out of it!"
			],
		"Ground and Pound": 
			[
				str(game_manager.username.left(5)) + " Get's on top of "+"#"+str(slam_AI.select_slammer) + " for a Ground & Pound!", 
				"But "+"#"+str(slam_AI.select_slammer) + " throws " + str(game_manager.username.left(5)) + "right off of him!"
			],
		"Neck Breaker": 
			[
				str(game_manager.username.left(5)) + " Is trying get serious with a Neck Break on "+"#"+str(slam_AI.select_slammer)+"!",
				"But "+"#"+str(slam_AI.select_slammer) + " is making  " + str(game_manager.username.left(5)) + "'s attempt look silly!"
			],
		"Body Lock": 
			[
				str(game_manager.username.left(5)) + " Grabs  " + str(game_manager.username.left(5)) + " for an apparent Body Lock",
				"#"+str(slam_AI.select_slammer) + " Is having none of it and breaks that weak Body Lock!"
			],
		"Choke Hold": 
			[
				str(game_manager.username.left(5)) + " Grabs "+"#"+str(slam_AI.select_slammer) + " by the neck in a Choke Hold",
				"#"+str(slam_AI.select_slammer) + " Breaks the hold by " + str(game_manager.username.left(5)) + "with ease!"
			],
		"Shoulder Block": 
			[
				str(game_manager.username.left(5)) + " Running straight for "+"#"+str(slam_AI.select_slammer) + " it looks like a Shoulder Block!",
				str(game_manager.username.left(5)) + " Just hit a brick wall and did more damage to himself!"
			],
		"Bear Hug": 
			[
				"Oh, " + str(game_manager.username.left(5)) + "Goes for a Bear Hug",
				"But "+"#"+str(slam_AI.select_slammer) + " is too fast for him this time!"
			],
		"Arm Bar Takedown": 
			[
				"Why would " + str(game_manager.username.left(5)) + "go for an Arm Bar Takedown on "+"#"+str(slam_AI.select_slammer) + " right now?",
				"They say play the odds around here "+"#"+str(slam_AI.select_slammer) + " has to keep taking his shots!"
			],
		"Waist Lock": 
			[
				str(game_manager.username.left(5)) + " 's connects around "+"#"+str(slam_AI.select_slammer) + " for a waist lock ",
				"Oh no! " + str(game_manager.username.left(5)) + " doesn't have enough to hold "+"#"+str(slam_AI.select_slammer)
			],

	}	
	if user == "Player":
		if state == "Hit":
			var dialogue = Hit[cap_name]
			dub.text = dialogue[0]
			matt.text = dialogue[1]
		else:
			var dialogue = Miss[cap_name]
			dub.text = dialogue[0]
			matt.text = dialogue[1]

func calculate_damage():
	var damage

	if player_stance == "Attack":
		damage = player_power - slam_AI.player_power
		if damage > 0:
			matt.text = str(username).left(5) + " is dealing " + str(damage) + " damage to "+slam_AI.select_slammer+"!"
			update_durability("Opponent", damage)
		elif damage < 0:
			matt.text = str(username).left(5) + " is getting hit for " + str(abs(damage)) + "!"
			update_durability("Player", damage)
		else:
			matt.text = "They completely blocked each other!!!"
	else:
		damage = slam_AI.player_power - player_power
		if damage > 0:
			matt.text = str(username).left(5) + " is in pain for " + str(damage) + "!"
			update_durability("Player", damage)
		elif damage < 0:
			matt.text = str(username).left(5) + " is hitting for " + str(abs(damage)) + "!"
			update_durability("Opponent", damage)
		else:
			matt.text = "They both MISSED!"
		print("Damage: " + str(damage))

func finisher():
	update_power("Player",25)
	slam_AI.full_counter()
	game_board.get_node('Player/MomentumBar').value = 0
	dub.text = str(username).left(5) + " went for a finisher!"

func resolve_round():
	print("Move:", move)
	if move <= 2:
		var die = roll_die()
		var playcheck1 = check_played_cap("Player", die, player_stance, strength, speed)
		var playcheck2 =check_played_cap("Opponent", die, slam_AI.player_stance, slam_AI.strength, slam_AI.speed)
		check_finisher()
		move += 1
		if playcheck1 == false and playcheck2 == false:
			move = 3
		if move == 3:
			game_board.get_node('AnnouncerPanel/PanelButton').text = "Deal Damage"
			move += 1
	elif move == 4:
		game_board.get_node('AnnouncerPanel/PanelButton').text = "Next Round"
		calculate_damage()
		dub.text = "{username}  Hits for ".format({"username" :username})+ str(player_power) + ", while "+"#"+str(slam_AI.select_slammer)+" did " + str(slam_AI.player_power) + "."
		print("Player Power:", player_power)
		print("AI Power:", slam_AI.player_power)
		print("Player HP:", game_board.get_node('Player/DurabilityBar').value)
		print("AI HP:", game_board.get_node('Opponent/DurabilityBar').value)
		move += 1
	else:
		print("New Round...")
		move = 0
		game_manager.round_start()
		return true

func roll_die():
	for n in 3:
		die_roll = randi() % 6 + 1
#	die_label.text = str(die_roll)
	die_face.texture = load('res://Assets/Images/DieFace/' + str(die_roll) + '.png')
	return die_roll

func shake_die():
	die_roll = randi() % 6 + 1
	die_face.texture = load('res://Assets/Images/DieFace/' + str(die_roll) + '.png')

func start_turn(stance, turn_num):
	print("-------------------------------------------------------------------")
	print("Player turn starts...")
	print("-------------------------------------------------------------------")
	check_finisher()
	turn_order = turn_num
	success = 0
	player_power = 0
	player_move = 3
	player_stance = stance
	if player_stance == "Attack":
		game_board.get_node('HandPanel').color = Color(1, 0, 0, 1)
	else:
		game_board.get_node('HandPanel').color = Color(0, 0, 1, 1)
#	stance_label.text = stance
#	stance_label.text = Player_stance
#	power_label.text = str(player_power)
	game_board.get_node('AnnouncerPanel/PanelButton').text = "Pass"

	for n in x_factor + 2 - player_hand.size(): #draw caps by x_factor
		draw_cap()
	print("Hand:"+str(player_hand))
	print("-------------------------------------------------------------------")

func fill_hud(user):

	var hud_res = game_board.get_node(user + '/Stats/Resilience/Label')
	var hud_str = game_board.get_node(user + '/Stats/Strength/Label')
	var hud_spe = game_board.get_node(user + '/Stats/Speed/Label')
	var hud_x = game_board.get_node(user + '/Stats/X-Factor/Label')
	var hud_cha = game_board.get_node(user + '/Stats/Charisma/Label')
	var hud_ali = game_board.get_node(user + '/Alignment')
	
	if user == "Player":
		hud_res.text = str(resilience)
		hud_str.text = str(strength)
		hud_spe.text = str(speed)
		hud_x.text = str(x_factor)
		hud_cha.text = str(charisma)
		hud_ali.text = alignment
	else:
		hud_res.text = str(slam_AI.resilience)
		hud_str.text = str(slam_AI.strength)
		hud_spe.text = str(slam_AI.speed)
		hud_x.text = str(slam_AI.x_factor)
		hud_cha.text = str(slam_AI.charisma)
		hud_ali.text = slam_AI.alignment


