extends Sprite2D

class_name Character

@export var character_name: String
@export var image_main: Texture2D

func _ready() -> void:
	_set_sprites()

func _set_sprites() -> void:
	self.texture = image_main
