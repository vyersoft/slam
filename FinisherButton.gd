extends TextureButton



func _pressed():
	disabled = true
	visible = false
	$"../Player/MomentumBar".value = 0
	game_manager.update_power("Player",25)
	slam_AI.full_counter()
