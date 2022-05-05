extends TextureButton

class_name Cap

# Declare member variables here. Examples:
onready var cap
#var cap_owner
onready var cap_database = preload("res://Assets/TempDatabase/CapData.gd")
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
	texture_normal = load(str("res://Assets/Caps/Powerhouz/Success/",cap,".png"))

func _pressed():
	$"../../../".get_node("Sound/PlayCap").play()
	game_manager.play_cap(cap)
#	game_manager.discard_cap(cap)
	game_manager.commit_cap(cap)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
