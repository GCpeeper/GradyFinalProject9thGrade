extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass





func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is Charater:
		body.position = Vector2(-100,120)
		SceneSwitcher.goto_scene("res://level_1.tscn")

func save_all():
	pass
	
func load_all(scene):
	pass
