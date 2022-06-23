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
var round_records = []
var round_record = {}
# round_record element:
# round#: {
# 	player_health: number,
# 	ai_health: number,
#	player_damage: number,
#	ai_damage: number
# }
var on_offense
var on_defense 
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
var match_end_status = ""
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
var matchId = ""
var select_slammer = ""
var slammer_stats = {}
var slammer_names = [] 

#setting the player deck
onready var deck_list = preload("res://Assets/TempDatabase/game_deck.gd")
var player_deck = []
var player_hand = []
var player_discard =[]

onready var http: HTTPRequest = HTTPRequest.new()

#for updating labels and buttons
onready var die_label = game_board.get_node('Die/DieRoll')
onready var finisher_button = game_board.get_node('FinisherButton')
onready var counter_button = game_board.get_node('CounterButton')
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
	game_board.get_node('Sound/bgm').play()
	http.connect("request_completed", self, "_on_http_request_completed")
	randomize()
	
	add_child(http)


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
	print('reset_hand')
	print(slammer_name)
	for child in game_board.get_node("HandPanel/HandContainer").get_children():
		child.queue_free()
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
	


func _on_http_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var data = json.result
	if data.call == "addMatchRecord":
		matchId = data.status
		print(data.status)
	elif data.call == "updateMatchRecord":
		pass
	elif data.call == "updateSlamRecord":
		print('Sending match record update.')
		if match_end_status == "win":
			var end_record_body = {
			"match_id":matchId,
			"winner":username,
			"rounds":round_records,
			"moves":format_move_list()
			}
			http.request("https://us-central1-scd-vote.cloudfunctions.net/app/updateMatchRecord", PoolStringArray(["Content-Type: application/json"]), true, HTTPClient.METHOD_POST,to_json(end_record_body) )
		else:
			var end_record_body = {
				"match_id":matchId,
				"winner":"AI",
				"rounds":round_records,
				"moves":format_move_list()
			}
			http.request("https://us-central1-scd-vote.cloudfunctions.net/app/updateMatchRecord", PoolStringArray(["Content-Type: application/json"]), true, HTTPClient.METHOD_POST,to_json(end_record_body) )
	else:
		print(data)
		push_error("Error occured.")


func format_move_list():
	var array_move_list = []
	# Iterate through move_list
	for key in move_list:
		array_move_list.append(move_list[key])
	return array_move_list


func round_start():
	if round_n ==0:
		# Adding this match to our records
		var start_record_body = {"participant_1":username, "participant_2":"AI", "slammer_1":slammer_name, "slammer_2":slam_AI.slammer_name}
		http.request("https://us-central1-scd-vote.cloudfunctions.net/app/addMatchRecord", PoolStringArray(["Content-Type: application/json"]), true, HTTPClient.METHOD_POST,to_json(start_record_body) )
	
	if opponent_durability.value == 0:
		match_end_status = "win"
		format_move_list()
		print("Player Wins!")
		var win_screen = pop_up.instance()
		game_board.get_node('Sound/bgm').stop()
		game_board.get_node('Sound/applause').play()
		win_screen.get_node('CenterContainer/Panel/VBoxContainer/Label').text = "YOU WIN!!! Please refresh to play again."
		win_screen.get_node("CenterContainer/Panel/HBoxContainer/StartButton").visible = false
		game_board.add_child(win_screen)
		var slam_earned_body = {"username":username, "slamEarned": 100, "won": true}
		http.request("https://us-central1-scd-vote.cloudfunctions.net/app/updateSlamRecord", PoolStringArray(["Content-Type: application/json"]), true, HTTPClient.METHOD_POST,to_json(slam_earned_body) )
		round_n = 0
		game_board.get_node('Player/MomentumBar').value = 0
		game_board.get_node('Opponent/MomentumBar').value = 0
	elif player_durability.value == 0:
		match_end_status = "lose"
		print("Player Lose!")
		print(round_records)
		print(format_move_list())
		game_board.get_node('Sound/bgm').stop()
		game_board.get_node('Sound/Lose').play()
		var win_screen = pop_up.instance()
		win_screen.get_node('CenterContainer/Panel/VBoxContainer/Label').text = "YOU LOSE!!! Please refresh to play again."
		win_screen.get_node("CenterContainer/Panel/HBoxContainer/StartButton").visible = false
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
	matt.text = "#"+slammer_name + " is on the " + player_stance + "!"
	game_board.get_node('Player/Slammer/Stance').texture = load("res://Assets/Images/" + player_stance + ".png")
	game_board.get_node('Opponent/Slammer/Stance').texture = load("res://Assets/Images/" + slam_AI.player_stance + ".png")

	
func turn_tracker(power, turn_num):
	if turn_num == 1:
		p1_pow = power
	else:
		p2_pow = power

func set_player():
	print("Set_player slammer name")
	print(slammer_name)
	slammer = slammer_stats[slammer_name]
	game_board.get_node("Player/Slammer").texture = load("res://Assets/Slammers/" + str(slammer_name) + ".png")
	game_board.get_node('Player/Username').text  = "#"+slammer_name
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
#	print("Player Deck:", player_deck)
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
			dub.text = "#"+slammer_name + " is up for a finisher!"
			finisher_button.disabled = false
			finisher_button.visible = true
#			game_board.get_node("AnnouncerPanel/PanelButton").text = "Cancel"
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

func record_move(user, cap, state, stance):
	#records the action to the move list
	if user == "Player":
		move_counter += 1
		move_list[move_counter] = {cap:state, "doer":"player", "stance":stance, "round_number":round_n}
		print(move_list)
	else:
		game_manager.move_counter += 1
		game_manager.move_list[game_manager.move_counter] = {cap:state,"doer":"AI", "stance":stance, "round_number":round_n}
		

func check_played_cap(user, die, stance, user_strenght, user_speed):
	if game_board.get_node(str(user) + '/PlayContainer').get_child_count() > move:
		var Player_cap = game_board.get_node(str(user) + '/PlayContainer').get_child(move)
		Player_cap.disabled = false
		var power = calculate_power(die, Player_cap.cap_info, stance, user_strenght, user_speed)

		
		
		if power == 0:
			record_move(user, Player_cap.cap, "Miss",stance)

			if stance =="Attack":
				if user == "Player":
					fill_dialogue("#"+slammer_name, slam_AI.slammer_name)
				else:
					fill_dialogue(slam_AI.slammer_name, "#"+slammer_name)
				set_dialogue(user, "Miss", Player_cap.cap)
				
			game_board.get_node('Sound/miss').play()
			Player_cap.pressed = true
#			game_board.get_node('AnnouncerPanel/Speech1/Text').text = str(commentary.Miss[Player_cap.cap])
			for child in game_board.get_node(str(user) + '/PlayContainer').get_children():
				if child.disabled == true:
					child.queue_free()
					record_move(user, child.cap, "Miss",stance)
			return false
		else:
			record_move(user, Player_cap.cap, "Hit",stance)
			update_momentum(user)
			update_power(user, power)
			if stance =="Attack":
				if user == "Player":
					fill_dialogue("#"+slammer_name, slam_AI.slammer_name)
				else:
					fill_dialogue(slam_AI.slammer_name, "#"+slammer_name)
		
				set_dialogue(user, "Hit", Player_cap.cap)
			game_board.get_node('Sound/hit').play()
	else:
#		set_dialogue_color(1,1,1)
#		dub.text = slammer_name + " is down."
#		matt.text = slam_AI.slammer_name + " is getting a free hit!"
		return false


func fill_dialogue(attacker, defender):
	Hit = {
	#Powerhouz
		"Vertical Suplex Powerbomb": 
			[
				attacker + " Just went nuclear on "+ defender + " with a Vertical Suplex Powerbomb!", 
				"I don't think "+ defender + " is getting up after that..."
			],
		"Gorilla Press Drop":
			[
				attacker + " Has "+ defender + " lifted up above him for a Gorilla Press Drop!",
				defender + " Was not expecting a drop like that!"
			],
		"Double Underhook Power Bomb":
			[
				attacker + " has "+ defender + " locked! And lands a Double Underhook Power Bomb!",
				"No way "+ defender + " gets up after that crushing blow!"
			],
		"Powerbomb": 
			[
				attacker + " Launches and slams "+ defender + " with a Powerbomb!",
				defender + " Is seeing stars!"
			],
		"Superplex": 
			[
				"Superplex! " + attacker + " Absolutely stuns "+ defender+"!",
				"Oh "+ defender + " is not looking good after that!"
			],
		"Full Nelson": 
			[
				attacker + " Snuck behind "+ defender + " and put him into a Full Nelson!",
				defender + " Is not looking comfortable!"
			],
		"Hammerlock": 
			[
				attacker + " Has the arm of "+ defender + " behind his back in a Hammerlock!",
				defender + "'s arm is looking like a lost cause!"
			],
		"Ground and Pound": 
			[
				"Whoa! " + attacker + " is cookin' with that Ground & Pound on "+ defender+"", 
				defender + " Is gonna be chop liver after that!"
			],
		"Neck Breaker": 
			[
				"Oh no it's a Neck Breaker on "+ defender+"!",
				attacker + " Is ruthless in the streets!"
			],
		"Body Lock": 
			[
				"And just like that " + attacker + "has strong armed "+ defender + " into a Body Lock",
				defender + " Is going nowhere fast!"
			],
		"Choke Hold": 
			[
				"Oh no! " + attacker + " has the neck of "+ defender + " in a vicious Choke Hold",
				"I think "+ defender + " is starting to turn purple!"
			],
		"Shoulder Block": 
			[
				"Grabbing "+ defender+"'s arm, " + attacker + " goes for an Armbar Leg Sweep attempt!",
				defender + " Was just flattened like a pancake!"
			],
		"Bear Hug": 
			[
				attacker + " Has "+ defender + " in a vicious bear hug!",
				"He's literally squeezing the life out of him!"
			],
		"Arm Bar Takedown": 
			[
				"Ouch! " + attacker + " secured the Arm Bar Takedown on "+ defender+"!",
				"How fast is  " + attacker + "?!?"
			],
		"Waist Lock": 
			[
				"Whoa! That's a tight waist lock " + attacker + " has on "+ defender,
				"Those ribs gotta be hurting for "+ defender
			],
			
	#High Fly
		"Pheonix Splash":
				[
				attacker + " just landed a majestic Phoenix Splash on " + defender + "!",
				attacker + "'s skill set is so rare and so pro!"
			],
		"540 Spanish Fly":
			[
				"From high up! " + attacker + " grabs " + defender + " and pulls him into a Spanish Fly",
				defender + " Just got swatted!"
			],
		"Flipping Mule Kick":
			[
				attacker + " knocks back " + defender + " with a Flipping Mule Kick!",
				defender + " charged into that one face first!"
			],
		"Blockbuster":
			[
				attacker + " flies over [P2 ] connecting a Blockbuster!",
				"That's going to be hard to recover from for " + defender + "!"
			],
		"Enziguris":
			[
				"Out of nowhere " + attacker + " catches " + defender + " with a surprise Enziguris! ",
				attacker + "'s foot connected directly to " + defender + "'s face!"
			],
		"Flying Dropkick":
			[
				"How did " + attacker + " just pull off a Flying Dropkick on " + defender + "!?!?",
				"A crazy mix of skill and luck is all I can think of!"
			],
		"Laser Moonsault":
			[
				"With stunning precision " + attacker + " lands a Laser Moonsault on " + defender,
				defender + " had no clue that was coming!"
			],
		"Backflip Kick":
			[
				"Backflip Kick! " + attacker + " stuns " + defender + " with that kick!",
				"What stunning agility " + attacker + " posesses!"
			],
		"Jaw Jammer":
			[
				attacker + " has " + defender + " around the neck in a Jaw Jammer",
				defender + " is gonna be eating from a straw!"
			],
		"Splash":
			[
				attacker + " soars into the sky for a Splash on " + defender + "!",
				"Watch out in the Splash zone! " + defender + " got crushed!"
			],
		"Spinning Heel Kick":
			[
				"Turning around " + attacker + " catches " + defender + " with a Spinning Heel Kick",
				"Oh my! " + defender + " dropped like a rock after that connected!"
			],
		"Catapult":
			[
				attacker + " Just sent " + defender + " to the moon with that Catapult!",
				"Whoa! " + defender + " is in orbit!"
			],
		"Armbar Leg Sweep":
			[
				attacker + " puts " + defender + " right to the ground with an Armbar Leg Sweep",
				defender + " has got to be hurting all over now!"
			],
		"Spinning Kick":
			[
				defender + " just got walloped by a Spinning Kick from " + attacker,
				"It's looking like the lights are out for " + defender
			],
		"Hip Toss":
			[
				attacker + " easily throws " + defender + " to the ground with a Hip Toss!",
				defender + " should just stay down!"
			],

	}
	Miss = {
	#Powerhouz
		"Vertical Suplex Powerbomb": 
			[
				attacker + " Muscles "+ defender + " into position for a Vertical Suplex Powerbomb", 
				"But "+ defender + " breaks free! "
			],
		"Gorilla Press Drop":
			[
				attacker + " Is lifting "+ defender + " above his head for a Gorilla Press Drop! ",
				attacker + " Doesn't have enough juice and "+ defender + " escapes!"
			],
		"Double Underhook Power Bomb":
			[
				attacker + " Locks up "+ defender + " for a Double Underhook Power Bomb!",
				"But "+ defender + " slips out of  " + attacker + "'s hooks!"
			],
		"Powerbomb": 
			[
				attacker + " Is trying to Powerbomb "+ defender+"!",
				"But "+ defender + " is glued to the floor and going nowhere!"
			],
		"Superplex": 
			[
				"Looks like " + attacker + " is going for a Superplex on "+ defender+"!",
				"But "+ defender + " reverses and takes the advantage!"
			],
		"Full Nelson": 
			[
				attacker + " Is behind "+ defender + " trying to get him into a Full Nelson",
				defender + " Is too strong for " + attacker + ", and won't allow it!"
			],
		"Hammerlock": 
			[
				attacker + " Grabs "+ defender+"'s arm and goes for a Hammerlock!",
				defender + " Twists and turns his way out of it!"
			],
		"Ground and Pound": 
			[
				attacker + " Get's on top of "+ defender + " for a Ground & Pound!", 
				"But "+ defender + " throws " + attacker + " right off of him!"
			],
		"Neck Breaker": 
			[
				attacker + " Is trying get serious with a Neck Break on "+ defender+"!",
				"But "+ defender + " is making  " + attacker + "'s attempt look silly!"
			],
		"Body Lock": 
			[
				attacker + " Grabs  " + defender + " for an apparent Body Lock",
				defender + " Is having none of it and breaks that weak Body Lock!"
			],
		"Choke Hold": 
			[
				attacker + " Grabs "+ defender + " by the neck in a Choke Hold",
				defender + " Breaks the hold by " + attacker + "with ease!"
			],
		"Shoulder Block": 
			[
				attacker + " Running straight for "+ defender + " it looks like a Shoulder Block!",
				attacker + " Just hit a brick wall and did more damage to himself!"
			],
		"Bear Hug": 
			[
				"Oh, " + attacker + "Goes for a Bear Hug",
				"But "+ defender + " is too fast for him this time!"
			],
		"Arm Bar Takedown": 
			[
				"Why would " + attacker + "go for an Arm Bar Takedown on "+ defender + " right now?",
				"They say play the odds around here "+ defender + " has to keep taking his shots!"
			],
		"Waist Lock": 
			[
				attacker + " 's connects around "+ defender + " for a waist lock ",
				"Oh no! " + attacker + " doesn't have enough to hold " + defender
			],
			
	#High Fly
		"Pheonix Splash":
				[
				attacker + " jumps, spins and flips for a Pheonix Splash " + defender,
				"But " + defender + " rolls away just in time to miss it!"
			],
		"540 Spanish Fly":
			[
				"Looks like " + attacker + " is grabbing " + defender + " for Spanish Fly",
				defender + " Just won't budge! Humiliating for " + attacker + "."
			],
		"Flipping Mule Kick":
			[
				attacker + " takes a shot at a Flipping Mule Kick.",
				"But " + attacker + " trips over himself and misses!"
			],
		"Blockbuster":
			[
				attacker + " leaps for a Blockbuster on " + defender + "!",
				defender + " ducks the move just in time! Will " + attacker + " land that attempt? "
			],
		"Enziguris":
			[
				"And " + attacker + " goes for a wild Enziguris!",
				"But " + defender + " is too fast and evades " + attacker + "'s foot!"
			],
		"Flying Dropkick":
			[
				"Is " + attacker + " going for the Flying Dropkick!?!?",
				defender + " was too quick and took the advantage! "
			],
		"Laser Moonsault":
			[
				"Is that " + attacker + " flying into the air for a Laser Moonsault!?!?",
				"But " + defender + " rolls out of the way just in time!"
			],
		"Backflip Kick":
			[
				attacker + " goes flying for a Backflip Kick on " + defender + ".",
				"But lands right on his face! What a whiff!"
			],
		"Jaw Jammer":
			[
				attacker + " is grabbing " + defender + " in a Jaw Jammer hold!?!?",
				"But " + defender + " slips right of it!"
			],
		"Splash":
			[
				"Flying into the air. " + attacker + " is looking to do a Splash on " + defender + ".",
				defender + " catches him mid-air and stops the attempt!"
			],
		"Spinning Heel Kick":
			[
				"Looks like " + attacker + " is going for a Spinning Heel Kick on " + defender + ".",
				"But " + defender + " steps back and dodges the foot of " + attacker + "!"
			],
		"Catapult":
			[
				"Is " + attacker + " trying to launch " + defender + " with a Catapult!?!?",
				defender + " is standing firm and won't budge!"
			],
		"Armbar Leg Sweep":
			[
				attacker + " grabs " + defender + "'s arm for an Armbar Leg Sweep attempt!",
				"But " + defender + " didn't even miss a step!"
			],
		"Spinning Kick":
			[
				attacker + " launches in the air for a Spinning Kick on " + defender + "!",
				attacker + " missed by a mile!"
			],
		"Hip Toss":
			[
				attacker + " awkwardly grabs " + defender + " in maybe a Hip Toss attempt?",
				attacker + " needs to work on his fundamentals..."
			],

	}	
		
func set_dialogue_color(a,b,c):
	dub.set("custom_colors/font_color", Color(a,b,c))
	matt.set("custom_colors/font_color", Color(a,b,c))


func set_dialogue(user, state, cap_name):
	
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
	print("Slammer name")
	print(slammer_name)
	print("AI name")
	print(slam_AI.slammer_name)
	matt.set("custom_colors/font_color", Color(1,0,0))
	
	if player_stance == "Attack":
		damage = player_power - slam_AI.player_power
		if damage > 0:
			matt.text = "#"+slammer_name + " is dealing " + str(damage) + " damage to " + slam_AI.slammer_name + "!"
			update_durability("Opponent", damage)
			game_board.get_node('Sound/cheer').play()
		elif damage < 0:
			matt.text = "#"+ slammer_name + " is getting hit for " + str(abs(damage)) + "!"
			update_durability("Player", damage)
			game_board.get_node('Sound/cheer').play()
		else:
			matt.text = "They completely blocked each other!!!"
	else:
		
		damage = slam_AI.player_power - player_power
		if damage > 0:
			matt.text = "#"+slammer_name + " is in pain for " + str(damage) + "!"
			update_durability("Player", damage)
			game_board.get_node('Sound/cheer').play()
		elif damage < 0:
			matt.text = "#"+slammer_name + " is hitting for " + str(abs(damage)) + "!"
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
	dub.text = "#"+slammer_name + " went for a finisher!"
	
func counter_finisher():
	if game_board.get_node('Player/MomentumBar').value == momentum_max:
		counter_button.visible = true
		counter_button.disabled = false
	else:
		return false

func full_counter():
	game_board.get_node('Player/MomentumBar').value = 0
	update_power("Player",25)

func resolve_round():
	print("Move:", move)
	if move <= 2:
		var die = roll_die()
		var playcheck1 = check_played_cap("Player", die, player_stance, strength, speed)
		var playcheck2 =check_played_cap("Opponent", die, slam_AI.player_stance, slam_AI.strength, slam_AI.speed)
#		check_finisher()
#		game_board.get_node('Sound/roll').play()
		move += 1
		if playcheck1 == false and playcheck2 == false:
			move = 3
		if move == 3:
			game_board.get_node('AnnouncerPanel/PanelButton').text = "Deal Damage"
			check_finisher()
			move += 1
	elif move == 4:
		game_board.get_node('AnnouncerPanel/PanelButton').text = "Next Round"
		calculate_damage()
		dub.set("custom_colors/font_color", Color(1,1,1))
		if player_power == 0 and slam_AI.player_power == 0:
			dub.text = "No one is landing anything."
		else:
			dub.text = "#"+slammer_name + " Hits for ".format({"username" :username})+ str(player_power) + ", while "+ slam_AI.slammer_name+" did " + str(slam_AI.player_power) + "."
		print("Player Power:", player_power)
		print("AI Power:", slam_AI.player_power)
		print("Player HP:", game_board.get_node('Player/DurabilityBar').value)
		print("AI HP:", game_board.get_node('Opponent/DurabilityBar').value)
		round_record.round = round_n
		round_record.player1_power = player_power
		round_record.player2_power = slam_AI.player_power
		round_record.player1_hp = game_board.get_node('Player/DurabilityBar').value
		round_record.player2_hp = game_board.get_node('Opponent/DurabilityBar').value
		round_records.append(round_record)
		round_record = {}
		
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
#	check_finisher()
	turn_order = turn_num
	success = 0
	player_power = 0
	player_move = 3
	player_stance = stance
	
	if player_stance == "Attack":
		game_board.get_node('HandPanel').color = Color(1, 0, 0, 1)
		round_record.player1_position = "Attacker"
		round_record.player2_position = "Defender"
	else:
		game_board.get_node('HandPanel').color = Color(0, 0, 1, 1)
		round_record.player2_position = "Attacker"
		round_record.player1_position = "Defender"
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


