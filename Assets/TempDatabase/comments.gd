# hit/miss = {move:[announcer1, announcer2]}
extends Node
onready var game_manager = get_node("/root/game_manager")
onready var slam_AI = get_node("/root/slam_AI")

var Hit = {}
var Miss = {}

func _ready():
	Hit = {
		"Vertical Suplex Powerbomb": 
			[
				str(game_manager.username[4]) + " Just went nuclear on "+str(slam_AI.select_slammer) + " with a Vertical Suplex Powerbomb!", 
				"I don't think "+str(slam_AI.select_slammer) + " is getting up after that..."
			],
		"Gorilla Press Drop":
			[
				str(game_manager.username[4]) + " Has "+str(slam_AI.select_slammer) + " lifted up above him for a Gorilla Press Drop!",
				str(slam_AI.select_slammer) + " Was not expecting a drop like that!"
			],
		"Double Underhook Power Bomb":
			[
				str(game_manager.username[4]) + " has "+str(slam_AI.select_slammer) + " locked! And lands a Double Underhook Power Bomb!",
				"No way "+str(slam_AI.select_slammer) + " gets up after that crushing blow!"
			],
		"Powerbomb": 
			[
				str(game_manager.username[4]) + " Launches and slams "+str(slam_AI.select_slammer) + " with a Powerbomb!",
				str(slam_AI.select_slammer) + " Is seeing stars!"
			],
		"Superplex": 
			[
				"Superplex! " + str(game_manager.username[4]) + "Absolutely stuns "+str(slam_AI.select_slammer)+"!",
				"Oh "+str(slam_AI.select_slammer) + " is not looking good after that!"
			],
		"Full Nelson": 
			[
				str(game_manager.username[4]) + " Snuck behind "+str(slam_AI.select_slammer) + " and put him into a Full Nelson!",
				str(slam_AI.select_slammer) + " Is not looking comfortable!"
			],
		"Hammerlock": 
			[
				str(game_manager.username[4]) + " Has the arm of "+str(slam_AI.select_slammer) + " behind his back in a Hammerlock!",
				str(slam_AI.select_slammer) + "'s arm is looking like a lost cause!"
			],
		"Ground and Pound": 
			[
				"Whoa! " + str(game_manager.username[4]) + " is cookin' with that Ground & Pound on "+str(slam_AI.select_slammer)+"", 
				str(slam_AI.select_slammer) + " Is gonna be chop liver after that!"
			],
		"Neck Breaker": 
			[
				"Oh no it's a Neck Breaker on "+str(slam_AI.select_slammer)+"!",
				str(game_manager.username[4]) + " Is ruthless in the streets!"
			],
		"Body Lock": 
			[
				"And just like that " + str(game_manager.username[4]) + "has strong armed "+str(slam_AI.select_slammer) + " into a Body Lock",
				str(slam_AI.select_slammer) + " Is going nowhere fast!"
			],
		"Choke Hold": 
			[
				"Oh no! " + str(game_manager.username[4]) + "has the neck of "+str(slam_AI.select_slammer) + " in a vicious Choke Hold",
				"I think "+str(slam_AI.select_slammer) + " is starting to turn purple!"
			],
		"Shoulder Block": 
			[
				"Grabbing "+str(slam_AI.select_slammer)+"'s arm, " + str(game_manager.username[4]) + "goes for an Armbar Leg Sweep attempt!",
				str(slam_AI.select_slammer) + " Was just flattened like a pancake!"
			],
		"Bear Hug": 
			[
				str(game_manager.username[4]) + " Has "+str(slam_AI.select_slammer) + " in a vicious bear hug!",
				"He's literally squeezing the life out of him!"
			],
		"Arm Bar Takedown": 
			[
				"Ouch! " + str(game_manager.username[4]) + "secured the Arm Bar Takedown on "+str(slam_AI.select_slammer)+"!",
				"How fast is  " + str(game_manager.username[4]) + "?!?"
			],
		"Waist Lock": 
			[
				"Whoa! That's a tight waist lock " + str(game_manager.username[4]) + "has on "+str(slam_AI.select_slammer),
				"Those ribs gotta be hurting for "+str(slam_AI.select_slammer)
			],

	}
	Miss = {
		"Vertical Suplex Powerbomb": 
			[
				str(game_manager.username[4]) + " Muscles "+str(slam_AI.select_slammer) + " into position for a Vertical Suplex Powerbomb", 
				"But "+str(slam_AI.select_slammer) + " breaks free! "
			],
		"Gorilla Press Drop":
			[
				str(game_manager.username[4]) + " Is lifting "+str(slam_AI.select_slammer) + " above his head for a Gorilla Press Drop! ",
				str(game_manager.username[4]) + " Doesn't have enough juice and "+str(slam_AI.select_slammer) + " escapes!"
			],
		"Double Underhook Power Bomb":
			[
				str(game_manager.username[4]) + " Locks up "+str(slam_AI.select_slammer) + " for a Double Underhook Power Bomb!",
				"But "+str(slam_AI.select_slammer) + " slips out of  " + str(game_manager.username[4]) + "'s hooks!"
			],
		"Powerbomb": 
			[
				str(game_manager.username[4]) + " Is trying to Powerbomb "+str(slam_AI.select_slammer)+"!",
				"But "+str(slam_AI.select_slammer) + " is glued to the floor and going nowhere!"
			],
		"Superplex": 
			[
				"Looks like " + str(game_manager.username[4]) + "is going for a Superplex on "+str(slam_AI.select_slammer)+"!",
				"But "+str(slam_AI.select_slammer) + " reverses and takes the advantage!"
			],
		"Full Nelson": 
			[
				str(game_manager.username[4]) + " Is behind "+str(slam_AI.select_slammer) + " trying to get him into a Full Nelson",
				str(slam_AI.select_slammer) + " Is too strong for " + str(game_manager.username[4]) + "and won't allow it!"
			],
		"Hammerlock": 
			[
				str(game_manager.username[4]) + " Grabs "+str(slam_AI.select_slammer)+"'s arm and goes for a Hammerlock!",
				str(slam_AI.select_slammer) + " Twists and turns his way out of it!"
			],
		"Ground and Pound": 
			[
				str(game_manager.username[4]) + " Get's on top of "+str(slam_AI.select_slammer) + " for a Ground & Pound!", 
				"But "+str(slam_AI.select_slammer) + " throws " + str(game_manager.username[4]) + "right off of him!"
			],
		"Neck Breaker": 
			[
				str(game_manager.username[4]) + " Is trying get serious with a Neck Break on "+str(slam_AI.select_slammer)+"!",
				"But "+str(slam_AI.select_slammer) + " is making  " + str(game_manager.username[4]) + "'s attempt look silly!"
			],
		"Body Lock": 
			[
				str(game_manager.username[4]) + " Grabs  " + str(game_manager.username[4]) + " for an apparent Body Lock",
				str(slam_AI.select_slammer) + " Is having none of it and breaks that weak Body Lock!"
			],
		"Choke Hold": 
			[
				str(game_manager.username[4]) + " Grabs "+str(slam_AI.select_slammer) + " by the neck in a Choke Hold",
				str(slam_AI.select_slammer) + " Breaks the hold by " + str(game_manager.username[4]) + "with ease!"
			],
		"Shoulder Block": 
			[
				str(game_manager.username[4]) + " Running straight for "+str(slam_AI.select_slammer) + " it looks like a Shoulder Block!",
				str(game_manager.username[4]) + " Just hit a brick wall and did more damage to himself!"
			],
		"Bear Hug": 
			[
				"Oh, " + str(game_manager.username[4]) + "Goes for a Bear Hug",
				"But "+str(slam_AI.select_slammer) + " is too fast for him this time!"
			],
		"Arm Bar Takedown": 
			[
				"Why would " + str(game_manager.username[4]) + "go for an Arm Bar Takedown on "+str(slam_AI.select_slammer) + " right now?",
				"They say play the odds around here "+str(slam_AI.select_slammer) + " has to keep taking his shots!"
			],
		"Waist Lock": 
			[
				str(game_manager.username[4]) + " 's connects around "+str(slam_AI.select_slammer) + " for a waist lock ",
				"Oh no! " + str(game_manager.username[4]) + " doesn't have enough to hold "+str(slam_AI.select_slammer)
			],

	}
