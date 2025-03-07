extends Node2D

# We need to maintain a list of characters
# Dictionary format is Character Name (String) : Path to Character Scene (String)
@export var Characters : Dictionary = {}

# Internal variables
var character_node : Node2D

# Returns the list of all characters in the scene
func get_characters():
	return character_node.get_children()

func choose_character() -> Character:
	# TODO: Eventually replace this with a way to choose which character speaks when the location button is pressed
	# For now default to our test
	
	# Get the list of characters in the scene
	#var characters_in_scene = get_characters()
	
	var character : Character = character_node.get_node("Stickman")
	
	return character
