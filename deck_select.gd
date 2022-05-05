extends Control


# Declare member variables here. Examples:
var Powerhouz_button
var Highfly_button


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	Powerhouz_button = get_node("ColorRect/Panel/HBoxContainer/VBoxContainer/PowerhouzButton")
	Highfly_button = get_node("ColorRect/Panel/HBoxContainer/VBoxContainer2/HighflyButton")
	Powerhouz_button.connect("pressed", self, "Powerhouz")
	Highfly_button.connect("pressed", self, "Highfly")

func Powerhouz():
	$"../".get_node("Sound/ClickSound").play()
	game_manager.reset_hand()
	game_manager.set_player()
	slam_AI.set_player()
	game_manager.reset_deck()
	slam_AI.reset_deck()
	game_manager.select_deck("Powerhouz")
	game_manager.setup()
	slam_AI.setup()
	game_manager.set_turns()
	game_manager.round_start()
	queue_free()
	
func Highfly():
	$"../".get_node("Sound/ClickSound").play()
	game_manager.reset_hand()
	game_manager.set_player()
	slam_AI.set_player()
	game_manager.reset_deck()
	slam_AI.reset_deck()
	game_manager.select_deck("High Fly")
	game_manager.setup()
	slam_AI.setup()
	game_manager.set_turns()
	game_manager.round_start()
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
