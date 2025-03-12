extends Panel

class_name DialogPanel

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var character_name: Label = $CharacterNamePanel/CharacterName
@onready var dialog_text: RichTextLabel = $DialogPanel/MarginContainer/DialogText

func _ready() -> void:
	animation_player.animation_finished.connect(TestDialogSystem._on_animation_player_animation_finished)

# Set the character name
func set_character_name(input_name: String) -> void:
	character_name.text = input_name
	#animation_player = get_node("%s/AnimationPlayer" % (character_name.name))
	#dialog_text = get_node("%s/MarginContainer/DialogText" % (character_name.name))
	#print(dialog_text)

# Play the dialog
func play_dialog() -> void:
	animation_player.play("typewriter")

# Set the dialog text
func set_dialog_text(dialog_line) -> void:
	dialog_text.text = dialog_line
