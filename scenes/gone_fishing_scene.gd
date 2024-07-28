extends Node


@onready var door := $TileMap/Door
var _fed_mouths := 0

## Feed all three mouths to open door
func _on_mouth_fed():
	_fed_mouths += 1
	if _fed_mouths == 3:
		door.open()
