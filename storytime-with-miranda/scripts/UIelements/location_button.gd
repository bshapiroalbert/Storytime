extends TextureButton

class_name LocationButton

signal start_dialog()

func _on_pressed():
	print("button pressed")
	start_dialog.emit()
