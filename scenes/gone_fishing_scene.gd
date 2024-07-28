extends Node


@onready var door := $TileMap/Door
var _fed_mouths := 0

func _on_mouth_fed():
	_fed_mouths += 1
	if _fed_mouths == 3:
		door.open()
