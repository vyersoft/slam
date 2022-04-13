extends Control


# Declare member variables here. Examples:
var play_button


# Called when the node enters the scene tree for the first time.
func _ready():
	play_button = get_node("CenterContainer/Panel/VBoxContainer/HBoxContainer/StartButton")
	play_button.connect("pressed", self, "new_game")

	
func new_game():
	randomize()
	game_manager.reset_hand()
	game_manager.set_player()
	slam_AI.set_player()
	game_manager.reset_deck()
	slam_AI.reset_deck()
	game_manager.setup()
	slam_AI.setup()
	game_manager.set_turns()
	game_manager.round_start()
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
