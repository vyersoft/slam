extends MarginContainer

onready var CapDatabase = preload("res://Assets/Caps/CapsDatabase.gd")
var Capname = "Double_Underhook_Power_Bomb"
var Stance = "Defense"
onready var CapInfo = CapDatabase.move_caps[CapDatabase.get(Capname)]
onready var CapFrameImg = str("res://Assets/Caps/Frames/",Stance,"/",CapInfo[3],".png")
onready var CapArtImg = str("res://Assets/Caps/Moves/",CapInfo[1],"/",Stance,"/",CapInfo[3],".png")
enum{
	InHand
	InPlay
	InMouse
	FocusInHand
	MoveDrawnCardToHand
	ReOrganiseHand
	Graveyard
	Attacking
}

var state = InHand
var startpos = 0
var targetpos = 0
var t = 0
var drawtime = 0.2
var organisetime = 0.2
onready var originalScale = rect_scale
var setup = true
var startscale = Vector2()
var cappos = Vector2()
var zoomInSize = 3
var zoomInTime = 0.2
var _duration_pressed = 0
var pressed = false
var capSelect = true
var oldState = INF
var inMouseTime = 0.1
var MovingtoInPlay = false
var CapDmg
var CapName 
var orgZ
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var CapSize = rect_size
	$Frame.texture = load(CapFrameImg)
	#$Frame.scale *= CapSize/$Frame.texture.get_size()
	
	$Art.texture = load(CapArtImg)
	$Art.scale *= CapSize/$Art.texture.get_size()
	$Focus.rect_scale *= CapSize/$Focus.rect_scale
	CapDmg = str(CapInfo[4])
	CapName = str(CapInfo[0])
	$Frame/Damage.text = CapDmg
	$Frame/Name.text = CapName
	if Stance == "Defense":
		$Text/DmgRow/Stat/.size_flags_horizontal = 3
		$Text/DmgRow/Stat/Label.align = 2
		$Text/DmgRow.rect_size.x = 200


func _process(delta: float) -> void:
	if pressed:
		_duration_pressed += delta
	
	if _duration_pressed > 0.1:
		if state != InMouse:
			oldState = state
			state = InMouse
			capSelect = false


func _physics_process(delta: float) -> void:
	match state:
		InHand:
			pass
		InPlay:
			pass
		InMouse:
			if setup:
				Setup()
			if t <=1:
				rect_position = startpos.linear_interpolate(get_global_mouse_position() - $'../../'.CapSize,t)
				rect_scale = originalScale
				t += delta/float(inMouseTime)
			else:
				rect_position = get_global_mouse_position() - $'../../'.CapSize
				rect_scale = originalScale
		FocusInHand:
			if setup:
				Setup()
			if t <=1:
				rect_position = startpos.linear_interpolate(targetpos,t)
				rect_scale = startscale * (1-t) + originalScale*t*3
				t += delta/float(zoomInTime)
			else:
				rect_position = targetpos
				rect_scale = originalScale*3
		MoveDrawnCardToHand:
			if setup:
				Setup()
			if t <=1:
				rect_position = startpos.linear_interpolate(targetpos,t)
				t += delta/float(drawtime)
			else:
				rect_position = targetpos
				state = InHand 
				t = 0
		ReOrganiseHand:
			if setup:
				Setup()
			if t <=1:
				rect_position = startpos.linear_interpolate(targetpos,t)
				rect_scale = startscale * (1-t) + originalScale*t
				t += delta/float(organisetime)
			else:
				rect_position = targetpos
				state = InHand 
				rect_scale = originalScale
				t = 0
func Setup() -> void:
	# set the starting position to the current position
	startpos = rect_position
	# set the current scale as the starting scale
	startscale = rect_scale
	# set t to 0
	t = 0
	# set setup to false
	setup = false
	
func fly() -> void:
	var target = $'../../PlayingField/OpponentSlammer/Enemy/Sprite'.position - Vector2($'../../PlayingField/OpponentSlammer/Enemy/Sprite'.texture.get_width(),$'../../PlayingField/OpponentSlammer/Enemy/Sprite'.texture.get_height())*$'../../PlayingField/OpponentSlammer/Enemy/Sprite'.scale - rect_position + Vector2(300,-100)
	$Tween.interpolate_property($Art, "position", Vector2(0,0), target, 0.25, Tween.TRANS_QUINT, Tween.EASE_IN)
	$Tween.interpolate_property($Frame, "position", Vector2(0,0), target, 0.25, Tween.TRANS_QUINT, Tween.EASE_IN)

	
	$Tween.start()
	
func _on_Focus_button_up() -> void:
	pressed = false
	match state:
		InHand, ReOrganiseHand:
			if _duration_pressed < 0.1:
				for Cap in get_node('../../Caps').get_children():
					if Cap.state != InPlay:
						Cap.targetpos = Cap.cappos
						Cap.state = ReOrganiseHand
					
				setup = true
				state = FocusInHand
				targetpos = cappos
				targetpos.y = get_viewport().size.y/2
				targetpos.x = get_viewport().size.x/2 - $'../../'.CapSize.x
			
		FocusInHand:
			if _duration_pressed <= 0.1:
				targetpos = cappos
				state = ReOrganiseHand
				
		InMouse:
			
			_duration_pressed = 0
			if capSelect == false:
				if oldState == FocusInHand or oldState == InHand:
					var capSlots = $'../../PlayingField/CapField/CapSlots'
					var capSlotEmpty = $'../../'.capSlotEmpty
					for i in range(capSlots.get_child_count()):
						if capSlotEmpty[i]: 
							var capSlotPos = capSlots.get_child(i).get_global_position()
							var capSlotSize = capSlots.get_child(i).rect_size
							var mousepos = get_global_mouse_position()
							if mousepos.x < capSlotPos.x + capSlotSize.x && mousepos.x > capSlotPos.x \
								&& mousepos.y < capSlotPos.y + capSlotSize.y && mousepos.y > capSlotPos.y:
									setup = true
									MovingtoInPlay = true
									targetpos = capSlotPos - $'../../'.CapSize/2
									rect_position = capSlotPos - $'../../'.CapSize/2
									state = InPlay
									capSelect = true
									capSlotEmpty[i] = false
									break
					if not capSlotEmpty.has(true):
						$'../../AttackButton'.visible = true
						
					if state != InPlay:
						setup = true
						targetpos = cappos
						state = ReOrganiseHand
						capSelect = true
				else: # handle one the card is in play
					pass
					
						
				


func _on_pressed() -> void:
	pass


func _on_button_down() -> void:
	pressed = true
	_duration_pressed = 0
	

func _on_mouse_entered() -> void:
	print("yes")
	



func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	print("done")


func _on_Tween_tween_all_completed() -> void:
	queue_free()
