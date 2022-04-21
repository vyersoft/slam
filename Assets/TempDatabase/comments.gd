extends Node

var Hit = {}
var Miss = {}

func _ready():
	fill_dialogue()

func fill_dialogue():
	# hit/miss = {move:[announcer1, announcer2]}
	Hit = {
		"Vertical Suplex Powerbomb": 
			[
				game_manager.slammer_name + " Just went nuclear on "+ slam_AI.slammer_name + " with a Vertical Suplex Powerbomb!", 
				"I don't think "+ slam_AI.slammer_name + " is getting up after that..."
			],
		"Gorilla Press Drop":
			[
				game_manager.slammer_name + " Has "+ slam_AI.slammer_name + " lifted up above him for a Gorilla Press Drop!",
				slam_AI.slammer_name + " Was not expecting a drop like that!"
			],
		"Double Underhook Power Bomb":
			[
				game_manager.slammer_name + " has "+ slam_AI.slammer_name + " locked! And lands a Double Underhook Power Bomb!",
				"No way "+ slam_AI.slammer_name + " gets up after that crushing blow!"
			],
		"Powerbomb": 
			[
				game_manager.slammer_name + " Launches and slams "+ slam_AI.slammer_name + " with a Powerbomb!",
				slam_AI.slammer_name + " Is seeing stars!"
			],
		"Superplex": 
			[
				"Superplex! " + game_manager.slammer_name + "Absolutely stuns "+ slam_AI.slammer_name+"!",
				"Oh "+ slam_AI.slammer_name + " is not looking good after that!"
			],
		"Full Nelson": 
			[
				game_manager.slammer_name + " Snuck behind "+ slam_AI.slammer_name + " and put him into a Full Nelson!",
				slam_AI.slammer_name + " Is not looking comfortable!"
			],
		"Hammerlock": 
			[
				game_manager.slammer_name + " Has the arm of "+ slam_AI.slammer_name + " behind his back in a Hammerlock!",
				slam_AI.slammer_name + "'s arm is looking like a lost cause!"
			],
		"Ground and Pound": 
			[
				"Whoa! " + game_manager.slammer_name + " is cookin' with that Ground & Pound on "+ slam_AI.slammer_name+"", 
				slam_AI.slammer_name + " Is gonna be chop liver after that!"
			],
		"Neck Breaker": 
			[
				"Oh no it's a Neck Breaker on "+ slam_AI.slammer_name+"!",
				game_manager.slammer_name + " Is ruthless in the streets!"
			],
		"Body Lock": 
			[
				"And just like that " + game_manager.slammer_name + "has strong armed "+ slam_AI.slammer_name + " into a Body Lock",
				slam_AI.slammer_name + " Is going nowhere fast!"
			],
		"Choke Hold": 
			[
				"Oh no! " + game_manager.slammer_name + "has the neck of "+ slam_AI.slammer_name + " in a vicious Choke Hold",
				"I think "+ slam_AI.slammer_name + " is starting to turn purple!"
			],
		"Shoulder Block": 
			[
				"Grabbing "+ slam_AI.slammer_name+"'s arm, " + game_manager.slammer_name + "goes for an Armbar Leg Sweep attempt!",
				slam_AI.slammer_name + " Was just flattened like a pancake!"
			],
		"Bear Hug": 
			[
				game_manager.slammer_name + " Has "+ slam_AI.slammer_name + " in a vicious bear hug!",
				"He's literally squeezing the life out of him!"
			],
		"Arm Bar Takedown": 
			[
				"Ouch! " + game_manager.slammer_name + "secured the Arm Bar Takedown on "+ slam_AI.slammer_name+"!",
				"How fast is  " + game_manager.slammer_name + "?!?"
			],
		"Waist Lock": 
			[
				"Whoa! That's a tight waist lock " + game_manager.slammer_name + "has on "+ slam_AI.slammer_name,
				"Those ribs gotta be hurting for "+ slam_AI.slammer_name
			],

	}
	Miss = {
		"Vertical Suplex Powerbomb": 
			[
				game_manager.slammer_name + " Muscles "+ slam_AI.slammer_name + " into position for a Vertical Suplex Powerbomb", 
				"But "+ slam_AI.slammer_name + " breaks free! "
			],
		"Gorilla Press Drop":
			[
				game_manager.slammer_name + " Is lifting "+ slam_AI.slammer_name + " above his head for a Gorilla Press Drop! ",
				game_manager.slammer_name + " Doesn't have enough juice and "+ slam_AI.slammer_name + " escapes!"
			],
		"Double Underhook Power Bomb":
			[
				game_manager.slammer_name + " Locks up "+ slam_AI.slammer_name + " for a Double Underhook Power Bomb!",
				"But "+ slam_AI.slammer_name + " slips out of  " + game_manager.slammer_name + "'s hooks!"
			],
		"Powerbomb": 
			[
				game_manager.slammer_name + " Is trying to Powerbomb "+ slam_AI.slammer_name+"!",
				"But "+ slam_AI.slammer_name + " is glued to the floor and going nowhere!"
			],
		"Superplex": 
			[
				"Looks like " + game_manager.slammer_name + "is going for a Superplex on "+ slam_AI.slammer_name+"!",
				"But "+ slam_AI.slammer_name + " reverses and takes the advantage!"
			],
		"Full Nelson": 
			[
				game_manager.slammer_name + " Is behind "+ slam_AI.slammer_name + " trying to get him into a Full Nelson",
				slam_AI.slammer_name + " Is too strong for " + game_manager.slammer_name + "and won't allow it!"
			],
		"Hammerlock": 
			[
				game_manager.slammer_name + " Grabs "+ slam_AI.slammer_name+"'s arm and goes for a Hammerlock!",
				slam_AI.slammer_name + " Twists and turns his way out of it!"
			],
		"Ground and Pound": 
			[
				game_manager.slammer_name + " Get's on top of "+ slam_AI.slammer_name + " for a Ground & Pound!", 
				"But "+ slam_AI.slammer_name + " throws " + game_manager.slammer_name + "right off of him!"
			],
		"Neck Breaker": 
			[
				game_manager.slammer_name + " Is trying get serious with a Neck Break on "+ slam_AI.slammer_name+"!",
				"But "+ slam_AI.slammer_name + " is making  " + game_manager.slammer_name + "'s attempt look silly!"
			],
		"Body Lock": 
			[
				game_manager.slammer_name + " Grabs  " + game_manager.slammer_name + " for an apparent Body Lock",
				slam_AI.slammer_name + " Is having none of it and breaks that weak Body Lock!"
			],
		"Choke Hold": 
			[
				game_manager.slammer_name + " Grabs "+ slam_AI.slammer_name + " by the neck in a Choke Hold",
				slam_AI.slammer_name + " Breaks the hold by " + game_manager.slammer_name + "with ease!"
			],
		"Shoulder Block": 
			[
				game_manager.slammer_name + " Running straight for "+ slam_AI.slammer_name + " it looks like a Shoulder Block!",
				game_manager.slammer_name + " Just hit a brick wall and did more damage to himself!"
			],
		"Bear Hug": 
			[
				"Oh, " + game_manager.slammer_name + "Goes for a Bear Hug",
				"But "+ slam_AI.slammer_name + " is too fast for him this time!"
			],
		"Arm Bar Takedown": 
			[
				"Why would " + game_manager.slammer_name + "go for an Arm Bar Takedown on "+ slam_AI.slammer_name + " right now?",
				"They say play the odds around here "+ slam_AI.slammer_name + " has to keep taking his shots!"
			],
		"Waist Lock": 
			[
				game_manager.slammer_name + " 's connects around "+ slam_AI.slammer_name + " for a waist lock ",
				"Oh no! " + game_manager.slammer_name + " doesn't have enough to hold " + slam_AI.slammer_name
			],

	}	
