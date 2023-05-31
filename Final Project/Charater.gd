class_name Charater extends CharacterBody2D

func save():
	return {
		"filename": get_scene_file_path(),
		"pos_x": position.x,
		"pos_y": position.y,
}
