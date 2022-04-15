extends MarginContainer


func _ready():
	var button = Button.new()
	button.text = "Click me"
	button.connect("pressed", self, "_on_Button_Login_pressed")
	add_child(button)

func _button_pressed():
	print("Hello world!")


func _on_Button_Login_pressed():
	# Get the `window.ProtonWebSDK` JavaScript object.

func _on_permissions(args):
	var obj = args[0]
	var link = obj.link
	var session = obj.session
	print(session.auth.actor)
	getAccountData(link, session)
	sessiondata = session


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
	
