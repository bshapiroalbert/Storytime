extends TextureButton

class_name LocationButton

signal start_dialog(dialog_target_character)

func _ready() -> void:
	start_dialog.connect(TestDialogSystem.start_dialog)

func _on_pressed():
	print("button pressed")
	var dialog_target_character : Character = CharacterManager.choose_character()
	start_dialog.emit(dialog_target_character)
