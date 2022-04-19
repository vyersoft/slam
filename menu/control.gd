extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


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
	
	JavaScript.create_object("ProtonWebSDK", options).then(_permission_callback)
	
	
# Here create a reference to the functions (below).
# This reference will be kept until the node is freed.
var _permission_callback = JavaScript.create_callback(self, "_on_permissions")
var _accountdata_callback = JavaScript.create_callback(self, "_on_accountdata")
var _txsuccess_callback = JavaScript.create_callback(self, "_on_txsuccess")
var sessiondata

func _on_permissions(args):
	var obj = args[0]
	var link = obj.link
	var session = obj.session
	print(session.auth.actor)
	getAccountData(link, session)
	sessiondata = session
	get_tree().change_scene("res://menu/Menu.tscn")
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


