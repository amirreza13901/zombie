extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.clear_black_screen()
		# Create the dialogue data
	var intro_dialogue = [
		{ "speaker": "", "line": " to grab the ledge jump and then..." },
		{ "speaker": "", "line": "press C at the right time"},
		{ "speaker": "", "line": "when you catch the ledge..."},
		{ "speaker": "", "line": "then press Z to climb"} ]
		# Immediately trigger the dialogue. 
		# We pass 'true' so the DialogueManager knows to handle the fade from black.
	DialogueManager.start_dialogue(intro_dialogue, false)


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	var dial = [
		{ "speaker": "", "line": "alright you did it" },
		
		# Line 1 (This line will trigger the choices!)
		{ 
			"speaker": "", 
			"line": "did you get it?", 
			"options": [
				{ "text": "No.", "next_index": 2 }, # If clicked, goes to Line 2
				{ "text": "Yes.", "next_index": 3 }       # If clicked, goes to Line 3
			]
		},
		
		# Line 2 (Player chose "No")
		{ "speaker": "Survivor", "line": "ok" }, 
		
		# Line 3 (Player chose "Yes")
		{ "speaker": "Survivor", "line": "alright!" } 
	]
	DialogueManager.start_dialogue(dial, false)
