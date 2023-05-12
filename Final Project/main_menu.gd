extends Control

var level1 = load("res://level_1.tscn")

func _ready():
	pass

func _on_play_pressed():
	get_tree().change_scene_to_file("res://level_1.tscn")
	
