extends Control


# Declare member variables here. Examples:
var play_button


# Called when the node enters the scene tree for the first time.
func _ready():
	play_button = get_node("CenterContainer/Panel/StartButton")
	play_button.connect("pressed", self, "login")

func login ():
	var game_manager = get_node("/root/game_manager")
	if game_manager.username == "":
		_on_ConnectWallet_pressed()
	else:
		new_game()
	
	
func new_game():
	randomize()
	game_manager.reset_hand()
	game_manager.set_player()
	slam_AI.set_player()
	game_manager.reset_deck()
	slam_AI.reset_deck()
	game_manager.setup()
	slam_AI.setup()
	game_manager.set_turns()
	game_manager.round_start()
	queue_free()
	

func _Get_Api_Data():
	$HTTPRequest.request("https://proton.api.atomicassets.io/atomicassets/v1/assets?collection_name=422342113445&page=1&limit=100&order=desc&sort=asset_id")
	pass # Replace with function body.


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var game_manager = get_node("/root/game_manager")
	var json = JSON.parse(body.get_string_from_utf8())
	var data = json.result
	setInterfaceData(data)
	if data.call == "getSlamRecord":
		if data.status.hash() == {}.hash():
			addNewUser()
			game_manager.userSLAM = 0
			game_manager.wins = 0
		else:
			game_manager.userSLAM = data.status.current_SLAM
			game_manager.wins = data.status.wins
		$HTTPRequest.request("https://us-central1-scd-vote.cloudfunctions.net/app/getTop5")
	elif data.call == "getTop5":
		game_manager.top5Data = data.status
		
		print('PRINT')
		print(game_manager.top5Data[0])
		get_parent().get_node("pop_up/CenterContainer/Panel/VBoxContainer/Label").text = "Top 3 Players\n1. {Top1} - {Top1Wins} wins\n2. {Top2} - {Top2Wins} wins\n3. {Top3} - {Top3Wins} wins\n\nPlayer Name: {username}\nSLAM: {slam}\nWins: {wins}".format({
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
	elif data.call == "addSlamRecord":
		pass
	elif data.call == "updateSlamRecord":
		pass
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
	
	get_parent().get_node("pop_up/CenterContainer/Panel/StartButton").text = "Start"
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
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


