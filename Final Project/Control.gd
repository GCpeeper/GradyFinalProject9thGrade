extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	SceneSwitcher.reset_scenes()
	SceneSwitcher.goto_scene("res://main_menu.tscn")

func save_all():
	pass

func load_all(scence):
	pass
