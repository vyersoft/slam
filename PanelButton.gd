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
	elif text == "Deal Damage":
		$"../../".get_node("FinisherButton").visible = false
		$"../../".get_node("CounterButton").visible = false
		$"../../".get_node("FinisherButton").disabled = true
		$"../../".get_node("CounterButton").disabled = true
		game_manager.resolve_round()
	else:
		game_manager.resolve_round()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
