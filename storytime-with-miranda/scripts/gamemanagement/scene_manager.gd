extends Node2D
class_name NSceneManager
 
# A collection of scenes in the game. Scenes are added through the Inspector panel
# Both the keys and values of the dictionary must be StringNames
# Code from: https://www.nightquestgames.com/changing-scenes-in-godot-4-is-easy/
@export var Scenes : Dictionary = {}
 
# Alias of the currently selected scene
var m_CurrentSceneAlias : String = ""
var activeScene
var previousScene
var scene_anim
var fade_scene_in = false

# Define some signals
signal _scene_changed

# Description: Add a new scene to the scene collection
# Parameter sceneAlias: The alias used for finding the scene in the collection
# Parameter scenePath: The full path to the scene file in the file system
func AddScene(sceneAlias : String, scenePath : String) -> void:
	Scenes[sceneAlias] = scenePath

# Description: Remove an existing scene from the scene collection
# Parameter sceneAlias: The scene alias of the scene to remove from the collection
func RemoveScene(sceneAlias : String) -> void:
	Scenes.erase(sceneAlias)

# Description: Switch to the requested scene based on its alias
# Parameter sceneAlias: The scene alias of the scene to switch to
func SwitchScene(sceneAlias : String) -> void:
	# If party in current scene, set new party stats
	# TODO: Need a better way to do this, it throws errors if it can't find the node
	previousScene = activeScene
	if sceneAlias != "MainMenu": # This is not a good way to do this
		fade_in()
		get_tree().change_scene_to_file(Scenes[sceneAlias])
	#get_tree().change_scene_to_file(Scenes[sceneAlias])
	activeScene = get_tree().current_scene
	m_CurrentSceneAlias = sceneAlias
	fade_out()

# Load scene from save based on its alias
func LoadScene(sceneAlias : String) -> void:
	var load_scene = load(String(Scenes[sceneAlias]))
	# Make the scene has loaded before we start loading everything else
	var error: Error = get_tree().change_scene_to_packed(load_scene)
	if error == OK:
		if not get_tree().node_added.is_connected(_on_node_added):
			get_tree().node_added.connect(_on_node_added)
		await _scene_changed
	#get_tree().change_scene_to_file(Scenes[sceneAlias])
	activeScene = get_tree().current_scene
	m_CurrentSceneAlias = sceneAlias

# Check if the scene is ready before adding other things
func _on_node_added(node: Node) -> void:
	if node == get_tree().current_scene:
		activeScene = get_tree().current_scene
		get_tree().node_added.disconnect(_on_node_added)
		# Here `_tree.current_scene` is already changed.
		# But note we are in the middle of executing `tree.root.add_child(current_scene)`.
		# So likely deferring it a little further is wanted, e.g. until its `ready` signal.
		await get_tree().current_scene.ready
		_scene_changed.emit()

# Description: Restart the current scene
func RestartScene() -> void:
	get_tree().reload_current_scene()

# Description: Quit the game
func QuitGame() -> void:
	get_tree().quit()

# Convenience functions
# Description: Return the number of scenes in the collection
func GetSceneCount() -> int:
	return Scenes.size()

# Description: Returns the alias of the current scene
func GetCurrentSceneAlias() -> String:
	return m_CurrentSceneAlias

# Description: Find the initial scene as defined in the project settings
func _ready() -> void:
	var mainScene : StringName = ProjectSettings.get_setting("application/run/main_scene")
	m_CurrentSceneAlias = Scenes.find_key(mainScene)
	activeScene = get_tree().current_scene
	scene_anim = $SceneTransition/AnimationPlayer

# Functions to fade scenes in and out
func fade_in() -> void:
	# animate fade in
	fade_scene_in = true
	scene_anim.play("dissolve")

func fade_out() -> void:
	# animate fade out
	fade_scene_in = false
	scene_anim.play_backwards("dissolve")

# Function to start a new game
func StartNewGame() -> void:
	# start fade to new scene
	fade_in()
	# TBD
	fade_out()
