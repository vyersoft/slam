extends Control


# Declare member variables here. Examples:
var play_button


# Called when the node enters the scene tree for the first time.
func _ready():
	play_button = get_node('CenterContainer/Panel/VBoxContainer/Button')
	play_button.connect("pressed", self, "new_game")
	
func new_game():
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
