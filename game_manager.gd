extends Node

#set the gameboard
onready var game_board = get_node('/root/GameBoard/')

var username = ""
var userSLAM = 0
var top5Data = []
var currAction = ""
var wins = 0
var move_list = {} #keeps records of player moves
var move_counter = 0 #for tracking move order


var player_stance
var player_power 
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
var slammer_name

#setting the player deck
onready var deck_list = preload("res://Assets/TempDatabase/game_deck.gd")
var player_deck = []
var player_hand = []
var player_discard =[]

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

func _on_HTTP_request_completed(result, _response_code, _headers, body ):
	print("got response")
	if result == 0:
		var json = JSON.parse(body.get_string_from_utf8())
		print(json)
		
func select_deck(decklist):
	print("Powerhouz:", deck_list.Powerhouz)
	print("High Fly:", deck_list.High_Fly)
	print("Selected:", decklist)
	if decklist == "Powerhouz":
		player_deck = deck_list.Powerhouz
	elif decklist == "High Fly":
		player_deck = deck_list.High_Fly
	print("Player Deck:", player_deck)
	

func reset_hand():
	for child in game_board.get_node("HandPanel/HandContainer").get_children():
		child.queue_free()
#	var hand_size = player_hand.size()
#	for caps in hand_size:
#		player_discard.append(player_hand.pop_front())
#	for caps in player_discard.size():
#		player_deck.append(player_discard.pop_back())
	player_hand.clear()
	player_discard.clear()

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
		game_board.get_node('Sound/applause').play()
		win_screen.get_node('CenterContainer/Panel/VBoxContainer/Label').text = "YOU WIN!!!"
		win_screen.get_node("CenterContainer/Panel/HBoxContainer/StartButton").text = "Play again"
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
		win_screen.get_node("CenterContainer/Panel/HBoxContainer/StartButton").text = "Play again"
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
			
	set_dialogue_color(1,1,1)
	dub.text = "It's Round " + str(round_n)
	matt.text = slammer_name + " is on the " + player_stance + "!"
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
	slammer_name = "#" + select_slammer 
	game_board.get_node("Player/Slammer").texture = load("res://Assets/Slammers/" + str(select_slammer) + ".png")
	game_board.get_node('Player/Username').text  = slammer_name
	print("Slammer Stats:", str(slammer))

func setup():
	fill_dialogue()
	
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
	game_board.get_node('Player/DurabilityBar/DurabilityLabel').text = str(base_durability) + "/" + str(base_durability)
	
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
	print("-------------------------------------------------------------------")
	print("Player Draws...")
	if player_deck.size() == 0:
		print("Discard: ", player_discard)
		print("shuffling...")
		for n in player_discard.size():
			player_deck.append(player_discard.pop_back())
			print(player_deck.size())
	var selected_cap = randi() % player_deck.size()
	var new_cap = Cap.new(player_deck[selected_cap])
	player_hand.append(new_cap.cap)
	game_board.get_node('HandPanel/HandContainer').add_child(new_cap)
	player_deck.erase(player_deck[selected_cap])
	print("Powerhouz:", deck_list.Powerhouz)
	print("High Fly:", deck_list.High_Fly)

func reset_deck():
	for caps in player_discard.size():
		player_discard.pop_back()
	for n in player_deck.size():
		player_deck.pop_back()
	#erase contents of the move list
	move_list.clear()
	move_counter = 0


func end_turn():
	set_dialogue_color(1,1,1)
	dub.text = "It's time to settle this."
	matt.text = "Let's SLAM!"
	game_board.get_node('AnnouncerPanel/PanelButton').text = "Roll"
	for child in game_board.get_node('HandPanel/HandContainer').get_children():
		child.disabled = true
		
	print("-------------------------------------------------------------------")
	print("Hand: ", str(player_hand))
	print("Deck: ", str(player_deck))
	print("Discard: ",str(player_discard))
	print("-------------------------------------------------------------------")
	turn_tracker(player_power, turn_order)
#	game_board.get_node('roll_die').disabled = false

func play_cap(img):
	var played = PlayedCap.new(img)
#	move_list.append(img)
	game_board.get_node('Player/PlayContainer').add_child(played)
	print("Moves Done:" , move_list)

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
			set_dialogue_color(1,0,0)
			dub.text = slammer_name + " is up for a finisher!"
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
	var durability_update = game_board.get_node(str(user) + '/DurabilityBar').value
	game_board.get_node(user + '/DurabilityBar/DurabilityLabel').text = str(durability_update) + "/" + str(base_durability)
	print(user)
	print(game_board.get_node(user + '/DurabilityBar').value)

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

func record_move(user, cap, state):
	#records the action to the move list
	if user == "Player":
		move_counter += 1
		move_list[move_counter] = {cap:state}
		print(move_list)

func check_played_cap(user, die, stance, user_strenght, user_speed):
	if game_board.get_node(str(user) + '/PlayContainer').get_child_count() > move:
		var Player_cap = game_board.get_node(str(user) + '/PlayContainer').get_child(move)
		Player_cap.disabled = false
		var power = calculate_power(die, Player_cap.cap_info, stance, user_strenght, user_speed)
		if power == 0:
			record_move(user, Player_cap.cap, "Miss")
			set_dialogue(user, "Miss", Player_cap.cap)
			game_board.get_node('Sound/miss').play()
			Player_cap.pressed = true
#			game_board.get_node('AnnouncerPanel/Speech1/Text').text = str(commentary.Miss[Player_cap.cap])
			for child in game_board.get_node(str(user) + '/PlayContainer').get_children():
				if child.disabled == true:
					child.queue_free()
					record_move(user, child.cap, "Miss")
			return false
		else:
			record_move(user, Player_cap.cap, "Hit")
			update_momentum(user)
			update_power(user, power)
			set_dialogue(user, "Hit", Player_cap.cap)
			game_board.get_node('Sound/hit').play()
	else:
#		set_dialogue_color(1,1,1)
#		dub.text = slammer_name + " is down."
#		matt.text = slam_AI.slammer_name + " is getting a free hit!"
		return false


func fill_dialogue():
	Hit = {
	#Powerhouz
		"Vertical Suplex Powerbomb": 
			[
				slammer_name + " Just went nuclear on "+ slam_AI.slammer_name + " with a Vertical Suplex Powerbomb!", 
				"I don't think "+ slam_AI.slammer_name + " is getting up after that..."
			],
		"Gorilla Press Drop":
			[
				slammer_name + " Has "+ slam_AI.slammer_name + " lifted up above him for a Gorilla Press Drop!",
				slam_AI.slammer_name + " Was not expecting a drop like that!"
			],
		"Double Underhook Power Bomb":
			[
				slammer_name + " has "+ slam_AI.slammer_name + " locked! And lands a Double Underhook Power Bomb!",
				"No way "+ slam_AI.slammer_name + " gets up after that crushing blow!"
			],
		"Powerbomb": 
			[
				slammer_name + " Launches and slams "+ slam_AI.slammer_name + " with a Powerbomb!",
				slam_AI.slammer_name + " Is seeing stars!"
			],
		"Superplex": 
			[
				"Superplex! " + slammer_name + " Absolutely stuns "+ slam_AI.slammer_name+"!",
				"Oh "+ slam_AI.slammer_name + " is not looking good after that!"
			],
		"Full Nelson": 
			[
				slammer_name + " Snuck behind "+ slam_AI.slammer_name + " and put him into a Full Nelson!",
				slam_AI.slammer_name + " Is not looking comfortable!"
			],
		"Hammerlock": 
			[
				slammer_name + " Has the arm of "+ slam_AI.slammer_name + " behind his back in a Hammerlock!",
				slam_AI.slammer_name + "'s arm is looking like a lost cause!"
			],
		"Ground and Pound": 
			[
				"Whoa! " + slammer_name + " is cookin' with that Ground & Pound on "+ slam_AI.slammer_name+"", 
				slam_AI.slammer_name + " Is gonna be chop liver after that!"
			],
		"Neck Breaker": 
			[
				"Oh no it's a Neck Breaker on "+ slam_AI.slammer_name+"!",
				slammer_name + " Is ruthless in the streets!"
			],
		"Body Lock": 
			[
				"And just like that " + slammer_name + "has strong armed "+ slam_AI.slammer_name + " into a Body Lock",
				slam_AI.slammer_name + " Is going nowhere fast!"
			],
		"Choke Hold": 
			[
				"Oh no! " + slammer_name + " has the neck of "+ slam_AI.slammer_name + " in a vicious Choke Hold",
				"I think "+ slam_AI.slammer_name + " is starting to turn purple!"
			],
		"Shoulder Block": 
			[
				"Grabbing "+ slam_AI.slammer_name+"'s arm, " + slammer_name + " goes for an Armbar Leg Sweep attempt!",
				slam_AI.slammer_name + " Was just flattened like a pancake!"
			],
		"Bear Hug": 
			[
				slammer_name + " Has "+ slam_AI.slammer_name + " in a vicious bear hug!",
				"He's literally squeezing the life out of him!"
			],
		"Arm Bar Takedown": 
			[
				"Ouch! " + slammer_name + "secured the Arm Bar Takedown on "+ slam_AI.slammer_name+"!",
				"How fast is  " + slammer_name + "?!?"
			],
		"Waist Lock": 
			[
				"Whoa! That's a tight waist lock " + slammer_name + "has on "+ slam_AI.slammer_name,
				"Those ribs gotta be hurting for "+ slam_AI.slammer_name
			],
			
	#High Fly
		"Pheonix Splash":
				[
				slammer_name + " just landed a majestic Phoenix Splash on " + slam_AI.slammer_name + "!",
				slammer_name + "'s skill set is so rare and so pro!"
			],
		"540 Spanish Fly":
			[
				"From high up! " + slammer_name + " grabs " + slam_AI.slammer_name + " and pulls him into a Spanish Fly",
				slam_AI.slammer_name + " Just got swatted!"
			],
		"Flipping Mule Kick":
			[
				slammer_name + " knocks back " + slam_AI.slammer_name + " with a Flipping Mule Kick!",
				slam_AI.slammer_name + " charged into that one face first!"
			],
		"Blockbuster":
			[
				slammer_name + " flies over [P2 ] connecting a Blockbuster!",
				"That's going to be hard to recover from for " + slam_AI.slammer_name + "!"
			],
		"Enziguris":
			[
				"Out of nowhere " + slammer_name + " catches " + slam_AI.slammer_name + " with a surprise Enziguris! ",
				slammer_name + "'s foot connected directly to " + slam_AI.slammer_name + "'s face!"
			],
		"Flying Dropkick":
			[
				"How did " + slammer_name + " just pull off a Flying Dropkick on " + slam_AI.slammer_name + "!?!?",
				"A crazy mix of skill and luck is all I can think of!"
			],
		"Laser Moonsault":
			[
				"With stunning precision " + slammer_name + " lands a Laser Moonsault on " + slam_AI.slammer_name,
				slam_AI.slammer_name + " had no clue that was coming!"
			],
		"Backflip Kick":
			[
				"Backflip Kick! " + slammer_name + " stuns " + slam_AI.slammer_name + " with that kick!",
				"What stunning agility " + slammer_name + " posesses!"
			],
		"Jaw Jammer":
			[
				slammer_name + " has " + slam_AI.slammer_name + " around the neck in a Jaw Jammer",
				slam_AI.slammer_name + " is gonna be eating from a straw!"
			],
		"Splash":
			[
				slammer_name + " soars into the sky for a Splash on " + slam_AI.slammer_name + "!",
				"Watch out in the Splash zone! " + slam_AI.slammer_name + " got crushed!"
			],
		"Spinning Heel Kick":
			[
				"Turning around " + slammer_name + " catches " + slam_AI.slammer_name + " with a Spinning Heel Kick",
				"Oh my! " + slam_AI.slammer_name + " dropped like a rock after that connected!"
			],
		"Catapult":
			[
				slammer_name + " Just sent " + slam_AI.slammer_name + " to the moon with that Catapult!",
				"Whoa! " + slam_AI.slammer_name + " is in orbit!"
			],
		"Armbar Leg Sweep":
			[
				slammer_name + " puts " + slam_AI.slammer_name + " right to the ground with an Armbar Leg Sweep",
				slam_AI.slammer_name + " has got to be hurting all over now!"
			],
		"Spinning Kick":
			[
				slam_AI.slammer_name + " just got walloped by a Spinning Kick from " + slammer_name,
				"It's looking like the lights are out for " + slam_AI.slammer_name
			],
		"Hip Toss":
			[
				slammer_name + " easily throws " + slam_AI.slammer_name + " to the ground with a Hip Toss!",
				slam_AI.slammer_name + " should just stay down!"
			],

	}
	Miss = {
	#Powerhouz
		"Vertical Suplex Powerbomb": 
			[
				slammer_name + " Muscles "+ slam_AI.slammer_name + " into position for a Vertical Suplex Powerbomb", 
				"But "+ slam_AI.slammer_name + " breaks free! "
			],
		"Gorilla Press Drop":
			[
				slammer_name + " Is lifting "+ slam_AI.slammer_name + " above his head for a Gorilla Press Drop! ",
				slammer_name + " Doesn't have enough juice and "+ slam_AI.slammer_name + " escapes!"
			],
		"Double Underhook Power Bomb":
			[
				slammer_name + " Locks up "+ slam_AI.slammer_name + " for a Double Underhook Power Bomb!",
				"But "+ slam_AI.slammer_name + " slips out of  " + slammer_name + "'s hooks!"
			],
		"Powerbomb": 
			[
				slammer_name + " Is trying to Powerbomb "+ slam_AI.slammer_name+"!",
				"But "+ slam_AI.slammer_name + " is glued to the floor and going nowhere!"
			],
		"Superplex": 
			[
				"Looks like " + slammer_name + " is going for a Superplex on "+ slam_AI.slammer_name+"!",
				"But "+ slam_AI.slammer_name + " reverses and takes the advantage!"
			],
		"Full Nelson": 
			[
				slammer_name + " Is behind "+ slam_AI.slammer_name + " trying to get him into a Full Nelson",
				slam_AI.slammer_name + " Is too strong for " + slammer_name + ", and won't allow it!"
			],
		"Hammerlock": 
			[
				slammer_name + " Grabs "+ slam_AI.slammer_name+"'s arm and goes for a Hammerlock!",
				slam_AI.slammer_name + " Twists and turns his way out of it!"
			],
		"Ground and Pound": 
			[
				slammer_name + " Get's on top of "+ slam_AI.slammer_name + " for a Ground & Pound!", 
				"But "+ slam_AI.slammer_name + " throws " + slammer_name + " right off of him!"
			],
		"Neck Breaker": 
			[
				slammer_name + " Is trying get serious with a Neck Break on "+ slam_AI.slammer_name+"!",
				"But "+ slam_AI.slammer_name + " is making  " + slammer_name + "'s attempt look silly!"
			],
		"Body Lock": 
			[
				slammer_name + " Grabs  " + slam_AI.slammer_name + " for an apparent Body Lock",
				slam_AI.slammer_name + " Is having none of it and breaks that weak Body Lock!"
			],
		"Choke Hold": 
			[
				slammer_name + " Grabs "+ slam_AI.slammer_name + " by the neck in a Choke Hold",
				slam_AI.slammer_name + " Breaks the hold by " + slammer_name + "with ease!"
			],
		"Shoulder Block": 
			[
				slammer_name + " Running straight for "+ slam_AI.slammer_name + " it looks like a Shoulder Block!",
				slammer_name + " Just hit a brick wall and did more damage to himself!"
			],
		"Bear Hug": 
			[
				"Oh, " + slammer_name + "Goes for a Bear Hug",
				"But "+ slam_AI.slammer_name + " is too fast for him this time!"
			],
		"Arm Bar Takedown": 
			[
				"Why would " + slammer_name + "go for an Arm Bar Takedown on "+ slam_AI.slammer_name + " right now?",
				"They say play the odds around here "+ slam_AI.slammer_name + " has to keep taking his shots!"
			],
		"Waist Lock": 
			[
				slammer_name + " 's connects around "+ slam_AI.slammer_name + " for a waist lock ",
				"Oh no! " + slammer_name + " doesn't have enough to hold " + slam_AI.slammer_name
			],
			
	#High Fly
		"Pheonix Splash":
				[
				slammer_name + " jumps, spins and flips for a Pheonix Splash " + slam_AI.slammer_name,
				"But " + slam_AI.slammer_name + " rolls away just in time to miss it!"
			],
		"540 Spanish Fly":
			[
				"Looks like " + slammer_name + " is grabbing " + slam_AI.slammer_name + " for Spanish Fly",
				slam_AI.slammer_name + " Just won't budge! Humiliating for " + slammer_name + "."
			],
		"Flipping Mule Kick":
			[
				slammer_name + " takes a shot at a Flipping Mule Kick.",
				"But " + slammer_name + " trips over himself and misses!"
			],
		"Blockbuster":
			[
				slammer_name + " leaps for a Blockbuster on " + slam_AI.slammer_name + "!",
				slam_AI.slammer_name + " ducks the move just in time! Will " + slammer_name + " land that attempt? "
			],
		"Enziguris":
			[
				"And " + slammer_name + " goes for a wild Enziguris!",
				"But " + slam_AI.slammer_name + " is too fast and evades " + slammer_name + "'s foot!"
			],
		"Flying Dropkick":
			[
				"Is " + slammer_name + " going for the Flying Dropkick!?!?",
				slam_AI.slammer_name + " was too quick and took the advantage! "
			],
		"Laser Moonsault":
			[
				"Is that " + slammer_name + " flying into the air for a Laser Moonsault!?!?",
				"But " + slam_AI.slammer_name + " rolls out of the way just in time!"
			],
		"Backflip Kick":
			[
				slammer_name + " goes flying for a Backflip Kick on " + slam_AI.slammer_name + ".",
				"But lands right on his face! What a whiff!"
			],
		"Jaw Jammer":
			[
				slammer_name + " is grabbing " + slam_AI.slammer_name + " in a Jaw Jammer hold!?!?",
				"But " + slam_AI.slammer_name + " slips right of it!"
			],
		"Splash":
			[
				"Flying into the air. " + slammer_name + " is looking to do a Splash on " + slam_AI.slammer_name + ".",
				slam_AI.slammer_name + " catches him mid-air and stops the attempt!"
			],
		"Spinning Heel Kick":
			[
				"Looks like " + slammer_name + " is going for a Spinning Heel Kick on " + slam_AI.slammer_name + ".",
				"But " + slam_AI.slammer_name + " steps back and dodges the foot of " + slammer_name + "!"
			],
		"Catapult":
			[
				"Is " + slammer_name + " trying to launch " + slam_AI.slammer_name + " with a Catapult!?!?",
				slam_AI.slammer_name + " is standing firm and won't budge!"
			],
		"Armbar Leg Sweep":
			[
				slammer_name + " grabs " + slam_AI.slammer_name + "'s arm for an Armbar Leg Sweep attempt!",
				"But " + slam_AI.slammer_name + " didn't even miss a step!"
			],
		"Spinning Kick":
			[
				slammer_name + " launches in the air for a Spinning Kick on " + slam_AI.slammer_name + "!",
				slammer_name + " missed by a mile!"
			],
		"Hip Toss":
			[
				slammer_name + " awkwardly grabs " + slam_AI.slammer_name + " in maybe a Hip Toss attempt?",
				slammer_name + " needs to work on his fundamentals..."
			],

	}	
	
func set_dialogue_color(a,b,c):
	dub.set("custom_colors/font_color", Color(a,b,c))
	matt.set("custom_colors/font_color", Color(a,b,c))


func set_dialogue(user, state, cap_name):
	if user == "Player":
		if state == "Hit":
			set_dialogue_color(1,1,1)
			var dialogue = Hit[cap_name]
			dub.text = dialogue[0]
			matt.text = dialogue[1]
		else:
			set_dialogue_color(1,0,0)
			var dialogue = Miss[cap_name]
			dub.text = dialogue[0]
			matt.text = dialogue[1]

func calculate_damage():
	var damage
	matt.set("custom_colors/font_color", Color(1,0,0))
	if player_stance == "Attack":
		damage = player_power - slam_AI.player_power
		if damage > 0:
			matt.text = slammer_name + " is dealing " + str(damage) + " damage to " + slam_AI.slammer_name + "!"
			update_durability("Opponent", damage)
			game_board.get_node('Sound/cheer').play()
		elif damage < 0:
			matt.text = slammer_name + " is getting hit for " + str(abs(damage)) + "!"
			update_durability("Player", damage)
			game_board.get_node('Sound/cheer').play()
		else:
			matt.text = "They completely blocked each other!!!"
	else:
		damage = slam_AI.player_power - player_power
		if damage > 0:
			matt.text = slammer_name + " is in pain for " + str(damage) + "!"
			update_durability("Player", damage)
			game_board.get_node('Sound/cheer').play()
		elif damage < 0:
			matt.text = slammer_name + " is hitting for " + str(abs(damage)) + "!"
			update_durability("Opponent", damage)
			game_board.get_node('Sound/cheer').play()
		else:
			matt.text = "They both MISSED!"
		print("Damage: " + str(damage))

func finisher():
	update_power("Player",25)
	slam_AI.full_counter()
	game_board.get_node('Player/MomentumBar').value = 0
	set_dialogue_color(1,0,0)
	dub.text = slammer_name + " went for a finisher!"

func resolve_round():
	print("Move:", move)
	if move <= 2:
		var die = roll_die()
		var playcheck1 = check_played_cap("Player", die, player_stance, strength, speed)
		var playcheck2 =check_played_cap("Opponent", die, slam_AI.player_stance, slam_AI.strength, slam_AI.speed)
		check_finisher()
#		game_board.get_node('Sound/roll').play()
		move += 1
		if playcheck1 == false and playcheck2 == false:
			move = 3
		if move == 3:
			game_board.get_node('AnnouncerPanel/PanelButton').text = "Deal Damage"
			move += 1
	elif move == 4:
		game_board.get_node('AnnouncerPanel/PanelButton').text = "Next Round"
		calculate_damage()
		dub.set("custom_colors/font_color", Color(1,1,1))
		if player_power == 0 and slam_AI.player_power == 0:
			dub.text = "No one is landing anything."
		else:
			dub.text = slammer_name + " Hits for ".format({"username" :username})+ str(player_power) + ", while "+ slam_AI.slammer_name+" did " + str(slam_AI.player_power) + "."
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


