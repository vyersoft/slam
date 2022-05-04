extends TextureButton

#slammer stats
const slammer_data = preload("res://Assets/TempDatabase/slammer_data.gd")
var slammer
var resilience #defines durability
var strength #adds atk
var speed #adds def
var x_factor #defines hand size
var charisma #defines momentum
var alignment #defines alignment
var slammer_name = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	slammer = slammer_data.slammer[slammer_name]
	resilience = slammer[0]
	strength = slammer[1]
	speed = slammer[2]
	x_factor = slammer[3]
	charisma = slammer[4]
	alignment = slammer[5]
	
	get_node("Username").text = "#" + slammer_name
	get_node("SlammerImg").texture = load("res://Assets/Slammers/" + str(slammer_name) + ".png")
	get_node("Alignment").text = alignment
	
	#set stats
	get_node("Stats/Resilience/Label").text = str(resilience)
	get_node("Stats/Strength/Label").text = str(strength)
	get_node("Stats/Speed/Label").text = str(speed)
	get_node("Stats/X-Factor/Label").text = str(x_factor)
	get_node("Stats/Charisma/Label").text = str(charisma)
	
	#set durability
	if resilience == 5:
		get_node("DurabilityLabel").text = "Durability: 58"
	elif resilience == 4:
		get_node("DurabilityLabel").text = "Durability: 56"
	elif resilience == 3:
		get_node("DurabilityLabel").text = "Durability: 54"
	elif resilience == 2:
		get_node("DurabilityLabel").text = "Durability: 52"
	else:
		get_node("DurabilityLabel").text = "Durability: 50"
		
	#set momentum
	if charisma == 5:
		get_node("MomentumLabel").text = "Momentum: 3"
	elif charisma == 4:
		get_node("MomentumLabel").text = "Momentum: 4"
	elif charisma == 3:
		get_node("MomentumLabel").text = "Momentum: 5"
	elif charisma == 2:
		get_node("MomentumLabel").text = "Momentum: 6"
	else:
		get_node("MomentumLabel").text = "Momentum: 7"

func _pressed():
	$"../../../".get_node("SelectButton").disabled = false
	for child in $"../".get_children():
		if child.slammer_name != slammer_name:
			child.pressed = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
