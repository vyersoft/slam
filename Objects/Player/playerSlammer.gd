extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var currentHealth = 10
var maxHealth = 10

var currentMomentum = 0
var maxMomentum = 10

var style = ""
var xfactor = 0
var charisma = 0
var strength = 0
var resilience = 0
var speed = 0
var alignment  = ""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func fly(target) -> void:
	print('fly start')
	print(target)
	var d = $slammerSprite
	var x = d.position.x + 50
	
	var start_x = d.position.x
	var end_x = x
	var start_y = d.position.y
	var end_y = d.position.y - 100

	$Forward.interpolate_property(d, "position:x", start_x, end_x, 0.125, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Forward.interpolate_property(d, "position:x",  end_x,start_x, 0.125, Tween.TRANS_QUAD, Tween.EASE_OUT,0.125)
	$Forward.interpolate_property(d, "position:y", start_y, end_y, 0.25, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Forward.interpolate_property(d, "position:x", start_x, end_x, 0.25, Tween.TRANS_QUAD, Tween.EASE_OUT,0.25)
	$Forward.interpolate_property(d, "position:x",  end_x,start_x, 0.25, Tween.TRANS_QUAD, Tween.EASE_OUT,0.375)
	$Forward.interpolate_property(d, "position:y",  end_y,start_y, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT,0.25)

	#$Forward.interpolate_property($slammerSprite, "position", rect_position, Vector2(-10,0), 0.1, Tween.TRANS_ELASTIC, Tween.EASE_IN)
	$Forward.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_playerSlammer_mouse_entered() -> void:
	print('mouse entered')


func _on_Forward_tween_completed(object: Object, key: NodePath) -> void:
	$Backward.interpolate_property($slammerSprite, "position", Vector2(-10,0), Vector2(0,0), 0.5, Tween.TRANS_QUART, Tween.EASE_OUT)
	
