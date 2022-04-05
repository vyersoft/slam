extends TextureButton

class_name Cap

# Declare member variables here. Examples:
onready var cap
#var cap_owner
onready var cap_database = preload("res://Assets/TempDatabase/move_cap_data.gd")
onready var cap_info = cap_database.move_caps[cap]


# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_h_size_flags(3)
	set_v_size_flags(3)
	set_expand(true)
	set_stretch_mode(TextureButton.STRETCH_KEEP_ASPECT_CENTERED)
	print("Draw Cap: "+ str(cap)+ str(cap_info))


func _init(name):
	cap = name
	texture_normal = load(str("res://Assets/Caps/",cap,".png"))

func _pressed():
	pass
#	var die_roll = game_manager.roll_die()
	
#	print(str("Roll: ",die_roll))
#	if die_roll < cap_info[1]:
#		print("Fail")
#		game_manager.play_cap("Pogs Back")
#		game_manager.discard_hand()
#	else:
#		disabled = true
#		game_manager.player_move -= 1
#		print("Pass")
#		if game_manager.player_stance == "Attack":
#			game_manager.player_power += cap_info[3] + game_manager.strength
#		else:
#			game_manager.player_power += cap_info[4] + game_manager.speed
#		print("Played: ", str(cap))
#		game_manager.play_cap(cap)
#		game_manager.update_momentum()
#		queue_free()
#	print("Power Value: " + str(game_manager.player_power))
#	game_manager.check_finisher()
#	if game_manager.player_move == 0:
#		game_manager.discard_hand()

	game_manager.play_cap(cap)
#	game_manager.discard_cap(cap)
	game_manager.commit_cap(cap)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
