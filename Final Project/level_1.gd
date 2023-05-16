extends Node2D

var done = false
var left = false
var right = false
var up = false
var down = false
var tree_dead = false

func _ready():
	$Door.monitoring = false
	var red_tree = get_node("RedTree")
	red_tree.dead.connect(_on_red_tree_dead)
	
func _process(delta):
	if Input.is_action_pressed("moveup"):
		up = true
		$Player/Camera2D/VBoxContainer/Up.hide()
	elif Input.is_action_pressed("movedown"):
		down = true
		$Player/Camera2D/VBoxContainer/Down.hide()
	elif Input.is_action_pressed("moveleft"):
		left = true
		$Player/Camera2D/VBoxContainer/Left.hide()
	elif Input.is_action_pressed("moveright"):
		right = true
		$Player/Camera2D/VBoxContainer/Right.hide()
		
	if up and down and left and right and tree_dead:
		$Door.monitoring = true
		$Player/Camera2D/VBoxContainer/Label.text = "Quests complete go through the door"
		$Player/Camera2D/VBoxContainer/Label.show()
		$Player/Camera2D/VBoxContainer/Quests.hide()

func _on_door_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is Charater:
		get_tree().change_scene_to_file("res://level_2.tscn")


func _on_red_tree_dead():
	tree_dead = true
	$Player/Camera2D/VBoxContainer/Label.hide()
