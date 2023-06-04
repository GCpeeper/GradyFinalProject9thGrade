extends Node2D

var done = false
var left = false
var right = false
var up = false
var down = false
var tree_dead = false
var nodes = []

func _ready():
	$Door.monitoring = false
	var red_tree = get_node("RedTree")
	red_tree.dead.connect(_on_red_tree_dead)
	nodes = find_nodes()
	
func _process(delta):
	if Input.is_action_pressed("moveup"):
		up = true
		$Player1/Camera2D/VBoxContainer/Up.hide()
	elif Input.is_action_pressed("movedown"):
		down = true
		$Player1/Camera2D/VBoxContainer/Down.hide()
	elif Input.is_action_pressed("moveleft"):
		left = true
		$Player1/Camera2D/VBoxContainer/Left.hide()
	elif Input.is_action_pressed("moveright"):
		right = true
		$Player1/Camera2D/VBoxContainer/Right.hide()
		
	if up and down and left and right and tree_dead:
		done = true
		$Door.monitoring = true
		$Player1/Camera2D/VBoxContainer/Label.text = "Quests complete go through the door"
		$Player1/Camera2D/VBoxContainer/Label.show()
		$Player1/Camera2D/VBoxContainer/Quests.hide()
	


func _on_door_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is Charater:
		body.position = Vector2(710,5)
		SceneSwitcher.goto_scene("res://level_2.tscn")


func _on_red_tree_dead():
	tree_dead = true
	$Player1/Camera2D/VBoxContainer/Label.hide()
	
func save_all():
	var dict = {}
	if not FileAccess.file_exists("user://savegame.json"):
		print("Error could not load file")
		return 
		
	var load_file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var start = JSON.parse_string(load_file.get_as_text())
	# Load in node data into our newly made scene
	for nodename in start:
		if nodename not in nodes:
			dict[nodename] = start[nodename]
	
	# Go through each Enemy and save it
	for child in find_children("*", "Enemy"):
		dict[child.name] = child.save()
		
	# Save the player node too
	dict["Player1"] = $Player1.save()
	dict["Level1"] = save()
	
	# Write the dictionary as a JSON file
	# Check the https://docs.godotengine.org/en/4.0/tutorials/io/data_paths.html docs to see
	# where this will end up
	
	var save_file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	save_file.store_string(JSON.stringify(dict))
	print(dict)
	print("Saved")

func save():
	return {
		"filename": get_scene_file_path(),
		"done": done,
		"tree_dead": tree_dead
	}
	
func load_self(dict):
	assert(dict["filename"] == get_scene_file_path())
	done = dict["done"]
	tree_dead = dict["tree_dead"]

func load_all(scene):
	
	if not FileAccess.file_exists("user://savegame.json"):
		print("Error could not load file")
		return 
		
	var load_file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var dict = JSON.parse_string(load_file.get_as_text())
	# Load in node data into our newly made scene
	for nodename in dict:
		if nodename == "Player1":
			var node = scene.find_child("Player1")
			node.load(dict[nodename])
			print("Loading ", nodename)
		elif nodename in nodes:
			var node = scene.find_child(nodename)
			node.load(dict[nodename])
			print("Loading ", nodename)
		elif nodename == "Level1":
			load_self(dict[nodename])
	
	if tree_dead:
		$RedTree.queue_free()
		
	if done:
		up = true
		down = true
		left = true
		right = true
		$Player1/Camera2D/VBoxContainer/Right.hide()
		$Player1/Camera2D/VBoxContainer/Left.hide()
		$Player1/Camera2D/VBoxContainer/Up.hide()
		$Player1/Camera2D/VBoxContainer/Down.hide()
	
	# Add the newly made scene to the tree so it starts showing

func find_nodes():
	var found = []
	for child in find_children("*", "Node"):
		found.append(child.name)
	return found
