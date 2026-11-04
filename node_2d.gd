extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var my_dialogue = [
	# Line 0
		{ "speaker": "Survivor", "line": "Are you bit? Tell me the truth." },
		
		# Line 1 (This line will trigger the choices!)
		{ 
			"speaker": "Survivor", 
			"line": "Answer me!", 
			"options": [
				{ "text": "No, I'm fine.", "next_index": 2 }, # If clicked, goes to Line 2
				{ "text": "...Yes.", "next_index": 3 }       # If clicked, goes to Line 3
			]
		},
		
		# Line 2 (Player chose "No")
		{ "speaker": "Survivor", "line": "Good. We need to get out of here." }, 
		
		# Line 3 (Player chose "Yes")
		{ "speaker": "Survivor", "line": "Damn it... I'll have to put you down." } 
	]
		
		# Immediately trigger the dialogue. 
		# We pass 'true' so the DialogueManager knows to handle the fade from black.
	DialogueManager.start_dialogue(my_dialogue, true)
