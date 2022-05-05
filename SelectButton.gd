extends TextureButton

onready var deck_select = preload('res://deck_select.tscn')
onready var game_board = get_node('/root/GameBoard/')

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	$"../../".get_node("Sound/ClickSound").play()
	print("Pressed Select")
	for child in $"../ScrollContainer".get_node("GridContainer").get_children():
		if child.pressed == true:
			print("Highlighted: #", child.slammer_name)
			game_manager.select_slammer = child.slammer_name
	var select = deck_select.instance()
	game_board.add_child(select)
	$"../".queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
