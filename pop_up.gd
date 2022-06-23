extends Control


# Declare member variables here. Examples:
var play_button
var cycle_button
#var deck_select = preload('res://deck_select.tscn')
var select_slammer = preload('res://SelectSlammer.tscn')
onready var game_board = get_node('/root/GameBoard/')
onready var game_manager = get_node("/root/game_manager")
var leaderboards = []
var current_LB_index = 1
var LB_max_index = 1

# Volume Control
var master_bus = AudioServer.get_bus_index("Master")
var effect_bus = AudioServer.get_bus_index("effect")
var effect2_bus = AudioServer.get_bus_index("effect2")

# Called when the node enters the scene tree for the first time.
func _ready():
	play_button = get_node("CenterContainer/Panel/HBoxContainer/StartButton")
	play_button.connect("pressed", self, "login")
	play_button = get_node("CenterContainer/Panel/VBoxContainer/CycleButton")
	play_button.connect("pressed", self, "cycle")
	

func cycle():
	print('cycle')
	if current_LB_index == LB_max_index:
		current_LB_index = 0
	else:
		current_LB_index += 1
	get_parent().get_node("pop_up/CenterContainer/Panel/VBoxContainer/Label").text = leaderboards[current_LB_index]
	
func login ():
	$"../".get_node("Sound/ClickSound").play()
	if game_manager.username == "":
		_on_ConnectWallet_pressed()
		get_node("CenterContainer/Panel/HBoxContainer/StartButton").disabled = true
	else:
		new_game()
		

	
func new_game():
	
#	var select = deck_select.instance()
#	game_board.add_child(select)
	var select = select_slammer.instance()
	game_board.add_child(select)
	queue_free()
	

func _Get_Api_Data():
	$HTTPRequest.request("https://proton.api.atomicassets.io/atomicassets/v1/assets?collection_name=422342113445&page=1&limit=100&order=desc&sort=asset_id")
	pass # Replace with function body.

func format_Slammers(slammers):

	for slammer in slammers:
		var nme = slammer.name.replace("Slammer#","")
		game_manager.slammer_names.push_back(nme)
		game_manager.slammer_stats[nme] = [
			slammer.data.resilience,
			slammer.data.strength,
			slammer.data.speed,
			slammer.data.xfactor,
			slammer.data.charisma,
			slammer.data.alignment,
		]

		
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var game_manager = get_node("/root/game_manager")
	var json = JSON.parse(body.get_string_from_utf8())
	var data = json.result
	setInterfaceData(data)
	
	
	if data.call == "getSlammers":
		format_Slammers(data.status)
		if game_manager.slammer_names.size() == 0:
			$AcceptDialog.window_title="Error"
			$AcceptDialog.dialog_text = "You have no SLAMMERs to use. You may purchase one at https://www.protonslammers.com/"
			$AcceptDialog.show()
		else:
			get_node("CenterContainer/Panel/HBoxContainer/StartButton").disabled = false
	elif data.call == "getSlamRecord":
		if data.status.hash() == {}.hash():
			addNewUser()
			game_manager.userSLAM = 0
			game_manager.wins = 0
		else:
			game_manager.userSLAM = data.status.current_SLAM
			game_manager.wins = data.status.wins
		get_parent().get_node("pop_up/CenterContainer/Panel/HBoxContainer/RedeemButton").visible = true
		$HTTPRequest.request("https://us-central1-scd-vote.cloudfunctions.net/app/getTop5")
	elif data.call == "getTopSlammers":
		# Get top slammers
		var topSlammers = data.status
		
		leaderboards.push_front("Top 5 Slammers\n1. {Top1} - {Top1Wins} wins\n2. {Top2} - {Top2Wins} wins\n3. {Top3} - {Top3Wins} wins\n4. {Top4} - {Top4Wins} wins\n5. {Top5} - {Top5Wins} wins\n\nPlayer Name: {username}\nSLAM: {slam}\nWins: {wins}".format({
			"Top1":topSlammers[0][0],
			"Top1Wins":topSlammers[0][1],
			"Top2":topSlammers[1][0],
			"Top2Wins":topSlammers[1][1],
			"Top3":topSlammers[2][0],
			"Top3Wins":topSlammers[2][1],   
			"Top4":topSlammers[3][0],
			"Top4Wins":topSlammers[3][1],   
			"Top5":topSlammers[4][0],
			"Top5Wins":topSlammers[4][1],   
			"username" : game_manager.username, 
			"slam" : game_manager.userSLAM, 
			"wins": game_manager.wins
			}) )
		
		# Show the "Cycle through LBs" button
		get_parent().get_node("pop_up/CenterContainer/Panel/VBoxContainer/CycleButton").visible = true
		
		# Start the call for getting slammers
		var get_slammers_body = {"username":game_manager.username}
		$HTTPRequest.request("https://us-central1-scd-vote.cloudfunctions.net/app/getSlammers", PoolStringArray(["Content-Type: application/json"]), true, HTTPClient.METHOD_POST,to_json(get_slammers_body) )
	
	elif data.call == "getTop5":
		game_manager.top5Data = data.status
		get_parent().get_node("pop_up/CenterContainer/Panel/VBoxContainer/Label").text = "Top 5 Players\n1. {Top1} - {Top1Wins} wins - {Top1Losses} losses\n2. {Top2} - {Top2Wins} wins - {Top2Losses} losses\n3. {Top3} - {Top3Wins} wins - {Top3Losses} losses\n4. {Top4} - {Top4Wins} wins - {Top4Losses} losses\n5. {Top5} - {Top5Wins} wins - {Top5Losses} losses\n\nPlayer Name: {username}\nSLAM: {slam}\nWins: {wins}".format({
			"Top1":game_manager.top5Data[0].keys()[0],
			"Top1Wins":game_manager.top5Data[0][game_manager.top5Data[0].keys()[0]].wins,
			"Top1Losses":game_manager.top5Data[0][game_manager.top5Data[0].keys()[0]].times_played - game_manager.top5Data[0][game_manager.top5Data[0].keys()[0]].wins,
			"Top2":game_manager.top5Data[1].keys()[0],
			"Top2Wins":game_manager.top5Data[1][game_manager.top5Data[1].keys()[0]].wins,
			"Top2Losses":game_manager.top5Data[1][game_manager.top5Data[1].keys()[0]].times_played - game_manager.top5Data[1][game_manager.top5Data[1].keys()[0]].wins,
			"Top3":game_manager.top5Data[2].keys()[0],
			"Top3Wins":game_manager.top5Data[2][game_manager.top5Data[2].keys()[0]].wins,   
			"Top3Losses":game_manager.top5Data[2][game_manager.top5Data[2].keys()[0]].times_played - game_manager.top5Data[2][game_manager.top5Data[2].keys()[0]].wins,
			"Top4":game_manager.top5Data[3].keys()[0],
			"Top4Wins":game_manager.top5Data[3][game_manager.top5Data[3].keys()[0]].wins,   
			"Top4Losses":game_manager.top5Data[3][game_manager.top5Data[3].keys()[0]].times_played - game_manager.top5Data[3][game_manager.top5Data[3].keys()[0]].wins,
			"Top5":game_manager.top5Data[4].keys()[0],
			"Top5Wins":game_manager.top5Data[4][game_manager.top5Data[4].keys()[0]].wins,   
			"Top5Losses":game_manager.top5Data[4][game_manager.top5Data[4].keys()[0]].times_played - game_manager.top5Data[4][game_manager.top5Data[4].keys()[0]].wins,
			"username" : game_manager.username, 
			"slam" : game_manager.userSLAM, 
			"wins": game_manager.wins
			}) 
		
		# Add the top 5 Wins LB to the list of LBs
		leaderboards.push_front("Top 5 Players\n1. {Top1} - {Top1Wins} wins - {Top1Losses} losses\n2. {Top2} - {Top2Wins} wins - {Top2Losses} losses\n3. {Top3} - {Top3Wins} wins - {Top3Losses} losses\n4. {Top4} - {Top4Wins} wins - {Top4Losses} losses\n5. {Top5} - {Top5Wins} wins - {Top5Losses} losses\n\nPlayer Name: {username}\nSLAM: {slam}\nWins: {wins}".format({
			"Top1":game_manager.top5Data[0].keys()[0],
			"Top1Wins":game_manager.top5Data[0][game_manager.top5Data[0].keys()[0]].wins,
			"Top1Losses":game_manager.top5Data[0][game_manager.top5Data[0].keys()[0]].times_played - game_manager.top5Data[0][game_manager.top5Data[0].keys()[0]].wins,
			"Top2":game_manager.top5Data[1].keys()[0],
			"Top2Wins":game_manager.top5Data[1][game_manager.top5Data[1].keys()[0]].wins,
			"Top2Losses":game_manager.top5Data[1][game_manager.top5Data[1].keys()[0]].times_played - game_manager.top5Data[1][game_manager.top5Data[1].keys()[0]].wins,
			"Top3":game_manager.top5Data[2].keys()[0],
			"Top3Wins":game_manager.top5Data[2][game_manager.top5Data[2].keys()[0]].wins,   
			"Top3Losses":game_manager.top5Data[2][game_manager.top5Data[2].keys()[0]].times_played - game_manager.top5Data[2][game_manager.top5Data[2].keys()[0]].wins,
			"Top4":game_manager.top5Data[3].keys()[0],
			"Top4Wins":game_manager.top5Data[3][game_manager.top5Data[3].keys()[0]].wins,   
			"Top4Losses":game_manager.top5Data[3][game_manager.top5Data[3].keys()[0]].times_played - game_manager.top5Data[3][game_manager.top5Data[3].keys()[0]].wins,
			"Top5":game_manager.top5Data[4].keys()[0],
			"Top5Wins":game_manager.top5Data[4][game_manager.top5Data[4].keys()[0]].wins,   
			"Top5Losses":game_manager.top5Data[4][game_manager.top5Data[4].keys()[0]].times_played - game_manager.top5Data[4][game_manager.top5Data[4].keys()[0]].wins,
			"username" : game_manager.username, 
			"slam" : game_manager.userSLAM, 
			"wins": game_manager.wins
			}))
		
		# GET request for top Slammers
		$HTTPRequest.request("https://us-central1-scd-vote.cloudfunctions.net/app/getTopSlammers")
		
		
		
	elif data.call == "addSlamRecord":
		pass
	elif data.call == "updateSlamRecord":
		pass
	elif data.call == "addMatchRecord":
		pass
	elif data.call == "updateMatchRecord":
		pass
	elif data.call == "redeemSlam":
		if typeof(data.status) == TYPE_STRING:
			$AcceptDialog.window_title="Error"
			$AcceptDialog.dialog_text = "You have no SLAM to redeem."
			$AcceptDialog.show()
		else:
			$AcceptDialog.window_title="Success!"
			$AcceptDialog.dialog_text = "SLAM redeemed."
			$AcceptDialog.show()
			game_manager.userSLAM = 0
			get_parent().get_node("pop_up/CenterContainer/Panel/VBoxContainer/Label").text = "Top 5 Players\n1. {Top1} - {Top1Wins} wins\n2. {Top2} - {Top2Wins} wins\n3. {Top3} - {Top3Wins} wins\n\nPlayer Name: {username}\nSLAM: {slam}\nWins: {wins}".format({
			"Top1":game_manager.top5Data[0].keys()[0],
			"Top1Wins":game_manager.top5Data[0][game_manager.top5Data[0].keys()[0]].wins,
			"Top2":game_manager.top5Data[1].keys()[0],
			"Top2Wins":game_manager.top5Data[1][game_manager.top5Data[1].keys()[0]].wins,
			"Top3":game_manager.top5Data[2].keys()[0],
			"Top3Wins":game_manager.top5Data[2][game_manager.top5Data[2].keys()[0]].wins,   
			"username" : game_manager.username, 
			"slam" : game_manager.userSLAM, 
			"wins": game_manager.wins
			}) 
	else:
		push_error("Error occured")
		
	
	
	
func setInterfaceData(data):
	print(data.call)
	#$TestData.text = str(data)

func addNewUser():
	var game_manager = get_node("/root/game_manager")
	var body = {"username":game_manager.username}
	$HTTPRequest.request("https://us-central1-scd-vote.cloudfunctions.net/app/addSlamRecord", PoolStringArray(["Content-Type: application/json"]), true, HTTPClient.METHOD_POST,to_json(body) )

func _on_ConnectWallet_pressed():
	# Get the `window.ProtonWebSDK` JavaScript object.
	
	# Create a javscript array of size 1
	var endpoints = JavaScript.create_object("Array", 1)
	endpoints[0] = "https://proton.greymass.com"
	
	var transportOptions = JavaScript.create_object("Object")
	transportOptions.requestAccount = "glbdex"
		
	var linkOptions = JavaScript.create_object("Object")
	linkOptions.endpoints = endpoints
	
	var options = JavaScript.create_object("Object")
	options.linkOptions = linkOptions
	options.transportOptions = transportOptions
	
	print(JavaScript.create_object("ProtonWebSDK", options).then(_permission_callback))
	
	
# Here create a reference to the functions (below).
# This reference will be kept until the node is freed.
var _permission_callback = JavaScript.create_callback(self, "_on_permissions")
var _accountdata_callback = JavaScript.create_callback(self, "_on_accountdata")
var _txsuccess_callback = JavaScript.create_callback(self, "_on_txsuccess")
var sessiondata

func _on_permissions(args):
	var game_manager = get_node("/root/game_manager")
	var obj = args[0]
	var link = obj.link
	var session = obj.session
	game_manager.username = session.auth.actor
	print('in on permissions')
	print(session.auth.actor)
	
	get_parent().get_node("pop_up/CenterContainer/Panel/HBoxContainer/StartButton").text = "Start"
	var body = {"username":session.auth.actor}
	get_parent().get_node("pop_up/CenterContainer/Panel/VBoxContainer/TextureRect").visible = false
	get_parent().get_node("pop_up/CenterContainer/Panel/VBoxContainer/Label").text = "Loading data..." 
	$HTTPRequest.request("https://us-central1-scd-vote.cloudfunctions.net/app/getSlamRecord", PoolStringArray(["Content-Type: application/json"]), true, HTTPClient.METHOD_POST,to_json(body) )
	
#	transfer(session)
	
func getAccountData(link, session):
	var params = JavaScript.create_object("Object")
	params.code = "eosio.proton"
	params.scope = "eosio.proton"
	params.table = "usersinfo"
	params.key_type = "i64"
	params.lower_bound = session.auth.actor
	params.upper_bound = session.auth.actor
	params.index_position = 1
	params.limit = 1
	
	link.client.get_table_rows(params).then(_accountdata_callback)
	
func _on_accountdata(args):
	var rows = args[0].rows
	var row = rows[0]
	print("Acc: ", row.acc)
	print("Name: ", row.name)
	print("Avatar: ", row.avatar)
	$Account.text = row.acc
	$Name.text = row.name
	$Avatar.text = row.avatar


func _on_RedeemButton_pressed():
	$"../".get_node("Sound/Redeem").play()
	print("Redeeming SLAM")
	var body = {"username":game_manager.username}
	$HTTPRequest.request("https://us-central1-scd-vote.cloudfunctions.net/app/redeemSlam", PoolStringArray(["Content-Type: application/json"]), true, HTTPClient.METHOD_POST,to_json(body) )
	pass # Replace with function body.


func _on_AcceptDialog_ready():
	pass # Replace with function body.


func _on_HSlider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, value)
	AudioServer.set_bus_volume_db(effect_bus, value)
	AudioServer.set_bus_volume_db(effect2_bus, value)
	if value == -30:
		AudioServer.set_bus_mute(master_bus, true)
		AudioServer.set_bus_mute(effect_bus, true)
		AudioServer.set_bus_mute(effect2_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)
		AudioServer.set_bus_mute(effect_bus, false)
		AudioServer.set_bus_mute(effect2_bus, false)
