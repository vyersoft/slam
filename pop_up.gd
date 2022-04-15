extends Control


# Declare member variables here. Examples:
var play_button


# Called when the node enters the scene tree for the first time.
func _ready():
	play_button = get_node("CenterContainer/Panel/VBoxContainer/HBoxContainer/StartButton")
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
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
	var data = json.result
	setInterfaceData(data)
	pass # Replace with function body.
	
func setInterfaceData(data):
	$TestData.text = str(data)



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
	get_parent().get_node("pop_up/CenterContainer/Panel/VBoxContainer/HBoxContainer/StartButton").text = "Start"
	
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
