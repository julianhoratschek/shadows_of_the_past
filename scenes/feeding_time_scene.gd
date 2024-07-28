extends Node


@onready var door := $TileMap/Door


func _on_mouth_fed():
	door.open()
