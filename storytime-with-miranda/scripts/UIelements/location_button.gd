extends TextureButton

class_name LocationButton

signal start_dialog(dialog_target_character)
signal activate_dialoge

func _ready() -> void:
	start_dialog.connect(TestDialogSystem.start_dialog)
	activate_dialoge.connect(GlobalProperties.change_dialog_status)

func _on_pressed():
	if not GlobalProperties.dialog_is_active:
		print("button pressed")
		var dialog_target_character : Character = CharacterManager.choose_character()
		activate_dialoge.emit()
		start_dialog.emit(dialog_target_character)
