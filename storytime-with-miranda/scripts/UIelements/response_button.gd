extends Button

class_name ResponseButton

signal _return_button_name(button)

func _on_pressed():
	
	_return_button_name.emit(self)
