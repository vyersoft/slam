extends MarginContainer


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

func _ready() -> void:
	$VBoxContainer/Health/TextureProgress.fill_mode = 1 # 
	$VBoxContainer/Momentum/TextureProgress.fill_mode = 1
	$Sprite.scale *= $VBoxContainer/ImageContainer.rect_min_size/$Sprite.texture.get_size()
	$VBoxContainer/Health/TextureProgress.value = currentHealth/maxHealth * 100
	$VBoxContainer/Momentum/TextureProgress.value = 0
	





func _on_Shake_tween_completed(object: Object, key: NodePath) -> void:
	pass
