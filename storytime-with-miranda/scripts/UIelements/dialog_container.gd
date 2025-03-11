extends TabContainer

class_name DialogContainer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var character_name: Panel = $CharacterName
@onready var dialog_text: RichTextLabel = $CharacterName/MarginContainer/DialogText

func _ready() -> void:
	animation_player.animation_finished.connect(TestDialogSystem._on_animation_player_animation_finished)

# Set the character name
func set_character_name(input_name: String) -> void:
	character_name.name = input_name

# Play the dialog
func play_dialog() -> void:
	animation_player.play("typewriter")

# Set the dialog text
func set_dialog_text(dialog_line) -> void:
	dialog_text.text = dialog_line
