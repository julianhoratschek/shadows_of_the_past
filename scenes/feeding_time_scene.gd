extends Node


@onready var door := $TileMap/Door


## Just one mouth has to be fed
func _on_mouth_fed():
	door.open()
