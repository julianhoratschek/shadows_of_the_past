extends Node2D

class_name BaseRoom


func center_camera(cam: Camera2D, tile_map: TileMap):
	cam.global_position = Vector2i(32, 32) * tile_map.get_used_rect().get_center()


func load_properties(player: Player):
	if g.player_properties:
		player.transmutable_properties.set_properties(g.player_properties)
