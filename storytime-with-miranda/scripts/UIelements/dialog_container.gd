extends PanelContainer

class_name DialogContainer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var character_name: Panel = $CharacterName
@onready var dialog_text: RichTextLabel = $CharacterName/MarginContainer/DialogText

# Set the character name
func set_character_name(name: String) -> void:
	character_name.name = name

# Play the dialog
func play_dialog() -> void:
	animation_player.play("typewriter")

# Set the dialog text
func set_dialog_text(dialog_line) -> void:
	dialog_text.text = dialog_line
