extends Node2D

var tree_dead = false
var done = false
var alive_enemies = []
var enemies = []
var nodes = []
var dead_enemies = []
var killed_knights = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	enemies = find_enemies()
	nodes = find_nodes()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Player4.control == false:
		SceneSwitcher.goto_scene("res://end.tscn")
	
	$Player4/Camera2D/VBoxContainer/Knights.text = "Time Knight has Been Killed: "+str(killed_knights)+"/"+str(5)
	
	if killed_knights > 4:
		$Player4/Camera2D/VBoxContainer/Knights.hide()
		$Player4/Camera2D/VBoxContainer/Quests.hide()
		SceneSwitcher.goto_scene("res://won.tscn")
		
	

	
func markers():
	var markers = find_children("*", "Marker")
	return markers.size()


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
	dict["Player2"] = $Player4.save()
	dict["Level2"] = save()
	
	# Write the dictionary as a JSON file
	# Check the https://docs.godotengine.org/en/4.0/tutorials/io/data_paths.html docs to see
	# where this will end up
	
	var save_file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	save_file.store_string(JSON.stringify(dict))
	print(dict)
	print("Saved")
	
func load_all(scene):
	
	if not FileAccess.file_exists("user://savegame.json"):
		print("Error could not load file")
		return 
		
	var load_file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var dict = JSON.parse_string(load_file.get_as_text())
	# Load in node data into our newly made scene
	for nodename in dict:
		if nodename == "Player2":
			var node = scene.find_child("Player2")
			node.load(dict[nodename])
			print("Loading ", nodename)
		elif nodename in nodes:
			var node = scene.find_child(nodename)
			node.load(dict[nodename])
			print("Loading ", nodename)
		elif nodename == "Level2":
			load_self(dict[nodename])
	
	for name in dead_enemies:
		find_child(name).queue_free()
	
func save():
	return {
		"filename": get_scene_file_path(),
		"done": done,
		"alive_enemies": find_enemies(),
		"dead_enemies": dead_enemies
	}
	
func load_self(dict):
	assert(dict["filename"] == get_scene_file_path())
	done = dict["done"]
	tree_dead = dict["tree_dead"]
	alive_enemies = dict["alive_enemies"]
	dead_enemies = dict["dead_enemies"]


func find_enemies():
	var found = []
	for child in find_children("*", "Enemy"):
		found.append(child.name)
	return found

func find_nodes():
	var found = []
	for child in find_children("*", "Node"):
		found.append(child.name)
	return found


func _on_child_exiting_tree(node):
	if node is Enemy:
		dead_enemies.append(node.name)



func _on_knight_died():
	print(killed_knights)
	killed_knights += 1


func _on_area_2d_body_entered(body):
	if body is Charater:
		SceneSwitcher.goto_scene("res://level_2.tscn")
