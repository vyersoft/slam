extends Button


# Declare member variables here. Examples:



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	game_manager.end_turn()
#	var child = get_node('../player/grid_played').get_child(0)
#	child.disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
