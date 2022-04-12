extends TextureButton

class_name PlayedCap

var cap
onready var cap_database = preload("res://Assets/TempDatabase/CapData.gd")
onready var cap_info = cap_database.move_caps[cap]

# Called when the node enters the scene tree for the first time.
func _ready():
	set_h_size_flags(3)
	set_v_size_flags(3)
	set_expand(true)
	set_stretch_mode(TextureButton.STRETCH_KEEP_ASPECT_CENTERED)

func _init(called_cap):
	cap = called_cap
	texture_normal = load(str("res://Assets/Caps/Powerhouz/Success/",called_cap,".png"))
	texture_disabled = preload("res://Assets/Caps/Pogs Back.png")
	texture_pressed = load(str("res://Assets/Caps/Powerhouz/Fail/",called_cap,".png"))
	toggle_mode = true
	disabled = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
