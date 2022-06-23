extends Node2D


const CapSize = Vector2(125,125)
const CapBase = preload("res://Objects/Caps/CapBase.tscn")
const PlayerHand = preload("res://Objects/Player/PlayerHand.gd")
const CapField = preload("res://Objects/Field/CapField.tscn")


var CapSelected = []
onready var DeckSize = PlayerHand.CapList.size()
var CapOffset = Vector2()
onready var CentreCapOval = get_viewport().size * Vector2(0.5, 1.1)
onready var Hor_rad = get_viewport().size.x*0.5
onready var Ver_rad = get_viewport().size.y*0.25
var angle = 0
var CapsSpread = 0.25
var OvalAngleVector = Vector2()
var CapsOnHand = 0
var CapNumb = 0
enum{
	InHand
	InPlay
	InMouse
	FocusInHand
	MoveDrawnCardToHand
	ReOrganiseHand
	Graveyard
}


var capSlotEmpty = []
func _ready():
	randomize()
	
	# Adding the cap slots to the records
	for slot in $PlayingField/CapField/CapSlots.get_children():
		capSlotEmpty.append(true)
	
	
	

func _input(event):
	if Input.is_action_just_released("leftclick"):
		while DeckSize > 0:
			drawcard("Attack")
			yield(get_tree().create_timer(0.2), "timeout")
		
func drawcard(stance):
	angle = PI/2 + CapsSpread*(float(CapsOnHand)/2 - CapsOnHand)
	var new_cap = CapBase.instance() 
	CapSelected = randi() % DeckSize
	new_cap.Capname = PlayerHand.CapList[CapSelected]
	new_cap.Stance = stance
	
	# Handles cap position (Which side is visible from the hand)
	if new_cap.Stance == "Defense":
		OvalAngleVector = Vector2(-Hor_rad * cos(angle), - Ver_rad* sin(angle))
	else:
		OvalAngleVector = Vector2(Hor_rad * cos(angle), - Ver_rad* sin(angle))
	
	# Caps start from the bottom of the screen and fly to the player's hand
	new_cap.rect_position = Vector2(get_viewport().size.x*0.5, get_viewport().size.y + 1)
	new_cap.targetpos = CentreCapOval + OvalAngleVector - (new_cap.rect_size*0.5)
	new_cap.cappos = new_cap.targetpos
	# Scale the caps down to one half its size
	new_cap.rect_scale *= 0.5#(CapSize/new_cap.rect_size)
	
	# Update the state
	new_cap.state = MoveDrawnCardToHand
	
	# Handles the repositioning of caps when a new one comes in
	CapNumb = 0
	for Cap in $Caps.get_children():
		angle = PI/2 + CapsSpread*(float(CapsOnHand)/2 - CapNumb)
		if new_cap.Stance == "Defense":
			OvalAngleVector = Vector2(-Hor_rad * cos(angle), - Ver_rad* sin(angle))
		else:
			OvalAngleVector = Vector2(Hor_rad * cos(angle), - Ver_rad* sin(angle))

		Cap.targetpos = CentreCapOval + OvalAngleVector - Cap.rect_size/2
		Cap.cappos = Cap.targetpos
		
		CapNumb += 1
		if Cap.state == InHand:
			Cap.setup = true
			Cap.state = ReOrganiseHand
		elif Cap.state == MoveDrawnCardToHand:
			Cap.startpos = Cap.targetpos - ((Cap.targetpos - Cap.rect_position)/(1-Cap.t))
	$Caps.add_child(new_cap)
	PlayerHand.CapList.erase(PlayerHand.CapList[CapSelected])
	if new_cap.Stance == "Defense":
		angle -= 0.25
	else:
		angle += 0.25
	DeckSize -= 1
	CapsOnHand += 1
	return DeckSize 

func fixHand(caps):
	CapsOnHand = caps
	CapNumb = 0
	for Cap in $Caps.get_children():
		if Cap.state != Graveyard:
			angle = PI/2 + CapsSpread*(float(CapsOnHand)/2 - CapNumb)
			if Cap.Stance == "Defense":
				OvalAngleVector = Vector2(-Hor_rad * cos(angle), - Ver_rad* sin(angle))
			else:
				OvalAngleVector = Vector2(Hor_rad * cos(angle), - Ver_rad* sin(angle))
			Cap.targetpos = CentreCapOval + OvalAngleVector - Cap.rect_size/2
			Cap.cappos = Cap.targetpos
			
			CapNumb += 1
			

			Cap.setup = true

			Cap.startpos = Cap.rect_position
			Cap.state = ReOrganiseHand
			angle -= 0.25
	

func _on_AttackButton_pressed() -> void:
	var caps = 0
	for Cap in $Caps.get_children():
		if Cap.state == InPlay:
			$PlayingField/OpponentSlammer/Enemy/VBoxContainer/Health/TextureProgress.value -= int(Cap.CapDmg)
			Cap.state = Graveyard
			Cap.fly()
		
		else:
			caps += 1
	$AttackButton.visible = false
	capSlotEmpty = [true,true,true]

	
	fixHand(caps)

