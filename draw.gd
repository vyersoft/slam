extends Button


# Declare member variables here. Examples:
var hand_size


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	game_manager.new_round()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
