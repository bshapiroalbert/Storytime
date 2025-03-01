extends Node2D

class_name GProperties

# Signals
signal finished_saving_game(save_file_path: String)

# The name of the save file to save all the data to. Default to first save file
var current_save_file: String = "res://files/saves/save_file_1.dat"
var loading_from_save: bool = false

# Variables that need to be accessed easily but not saved
var dialog_is_active: bool = false

@export_group("Game State")
@export var total_unix_playtime: float = 0.0
var start_unix_time: float
var last_exit_ID: String

@export_group("World Properties")
var current_scene = SceneManager.m_CurrentSceneAlias # Might just want the alias here
var load_scene

"""
#### Package, Load, and Save Player Properties ####
"""

func _ready() -> void:
	# Get the current time
	start_unix_time = Time.get_unix_time_from_system()
	# Set up signals
	"""
	Eventually we will be reading this data from a save file. For now
	we need to initialize this somehow so it's set manually.
	"""
	# Initialize the party dictionary
	var properties_dict: Dictionary = {}
	# Assign values to the dictionary
	# TBD
	# Get the current scene
	current_scene = SceneManager.m_CurrentSceneAlias

func save_game_data_to_file(save_file: String) -> void:
	# Open the game data file to save it
	var game_data_file = FileAccess.open(save_file, FileAccess.WRITE)
	# Create a big dict of all properties
	var game_data_dict = _create_game_data_dict()
	# Make a JSON string of all the data to be saved
	var game_data_json = JSON.stringify(game_data_dict)
	# Save the data to the file
	# May want to eventually use store_pascal_string() to save as binary for storage purposes later
	game_data_file.store_string(game_data_json)
	# Close the file
	game_data_file.close()
	finished_saving_game.emit(save_file)

func _create_game_data_dict() -> Dictionary:
	# Make the dictionary of properties
	var game_data_dict: Dictionary = {}
	# Set the party properties dictionary
	game_data_dict["Party_Properties"] = {}
	# Get other game properties
	# Nothing to add here, cannot save in combat
	game_data_dict["Game_State"] = {"total_unix_playtime" : total_unix_playtime}
	# Get world state properties
	game_data_dict["World_Properties"] = {"current_scene" : current_scene}
	
	# Return the filled dictionary
	return game_data_dict
