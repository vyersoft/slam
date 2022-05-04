extends Control


const my_slammers = preload("res://Assets/TempDatabase/my_slammers.gd")
const slammer_container = preload("res://SlammerContainerButton.tscn")
#onready var game_board = get_node("res://GameBoard.tscn")



# Called when the node enters the scene tree for the first time.
func _ready():
	print("Slammers:", my_slammers.slammer.size())
	for slammer in my_slammers.slammer.size():
		print("Slammer Name: #",my_slammers.slammer[slammer])
		var slammer_name = my_slammers.slammer[slammer]
		var new_slammer = slammer_container.instance()
		new_slammer.slammer_name = slammer_name
		get_node("ScrollContainer/GridContainer").add_child(new_slammer)
		print("Load Slammer")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
