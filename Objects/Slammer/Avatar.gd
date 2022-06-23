extends Node2D
class_name Avatar

#Slammer Stats
export var currentHealth = 10
export var maxHealth = 10

export var currentMomentum = 0
export var maxMomentum = 10

export var style = ""
export var xfactor = 0
export var charisma = 0
export var strength = 0
export var resilience = 0
export var speed = 0
export var alignment  = ""



# Shaking variables
var shake_amount = 10.0
var shake_speed = 0.01
var shake_count = 0
var max_shakes = 100
var current_pos = Vector2()
var final_pos = Vector2()

var rng = RandomNumberGenerator.new()


func _ready():
	rng.randomize()
	shake_count += 1
	shake()


func shake():
	current_pos = position
	final_pos = Vector2(
		rng.randf_range(-1.0, 1.0),
		rng.randf_range(-1.0, 1.0)) * shake_amount
	
	$Sprite/Tween.interpolate_property(
		$Sprite,
		"position",
		current_pos,
		final_pos,
		shake_speed,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	
	$Sprite/Tween.start()
	

func _on_Tween_tween_completed(object, key):	
	if shake_count < max_shakes:
		shake()
		shake_count +=1
