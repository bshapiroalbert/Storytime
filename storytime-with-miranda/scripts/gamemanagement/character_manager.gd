extends Node2D

# We need to maintain a list of characters
# Dictionary format is Character Name (String) : Path to Character Scene (String)
@export var Characters : Dictionary = {}

# Internal variables
var character_node : Node2D
var active_characters : Array

# Returns the list of all characters in the scene
func get_characters():
	return character_node.get_children()

# Choose which characters are in the dialog or what is shown
func choose_character() -> Character:
	# TODO: Eventually replace this with a way to choose which character speaks when the location button is pressed
	# For now default to our test
	
	# Get the list of characters in the scene
	#var characters_in_scene = get_characters()
	
	var character : Character = character_node.get_node("Stickman")
	
	# Add characters in the dialog to the list so we can show them
	active_characters.append(character)
	# Now set their positions
	set_character_positions()
	
	return character

# Function to set the position of the characters in the game window
func set_character_positions() -> void:
	# get the screen size
	var screensize = DisplayServer.window_get_size()
	
	# Now position characters in window
	for i in range(0, len(active_characters)):
		var character : Character = active_characters[i]
		var char_size = character.texture.get_size()
		print(char_size)
		character.position.x = 0
	
	print(screensize.x)
