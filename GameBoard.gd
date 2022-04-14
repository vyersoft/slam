extends Control
#var player_1
#var player_2
#var round_n = 0
#var p1_pow = 0
#var p2_pow = 0
#
#onready var hand_container = get_node("HandPanel/HandContainer")
#onready var player_played = get_node("Player/PlayContainer")
#onready var player_durability = get_node("Player/DurabilityBar")
#onready var opponent_played = get_node("Opponent/PlayContainer")
#onready var opponent_durability = get_node("Opponent/DurabilityBar")

var pop_up = preload('res://pop_up.tscn')

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var splash = pop_up.instance()
	add_child(splash)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
