extends Control

var level1 = load("res://level_1.tscn")

func _ready():
	pass

func _on_play_pressed():
	SceneSwitcher.goto_scene("res://level_1.tscn")
	
