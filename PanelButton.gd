extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	if text == "Pass":
		game_manager.end_turn()
	else:
		game_manager.resolve_round()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
