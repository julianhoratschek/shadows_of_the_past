extends BaseRoom


func _ready():
	load_properties($Player)
	center_camera($Camera2D, $TileMap)
