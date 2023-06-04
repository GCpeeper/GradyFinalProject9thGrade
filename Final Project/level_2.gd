extends Node2D
var tree_dead = false
var done = false
var alive_enemies = []
var enemies = []
var nodes = []
# Called when the node enters the scene tree for the first time.
func _ready():
	enemies = find_enemies()
	nodes = find_nodes()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Player.control == false:
		SceneSwitcher.goto_scene("res://end.tscn")





func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is Charater:
		body.position = Vector2(-100,120)
		SceneSwitcher.goto_scene("res://level_1.tscn")

func save_all():
	var dict = {}
	
	# Go through each Enemy and save it
	for child in find_children("*", "Enemy"):
		dict[child.name] = child.save()
		
	# Save the player node too
	dict["Player"] = $Player.save()
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
		if nodename in nodes:
			var node = scene.find_child(nodename)
			node.load(dict[nodename])
			print("Loading ", nodename)
		elif nodename == "Level2":
			load_self(dict[nodename])
	
	if tree_dead:
		$RedTree.queue_free()
	var i = 0
	var to_kill = enemies
	for name in alive_enemies:
		if name in to_kill:
			to_kill.remove_at(i)
		i += 1
	
	for name in to_kill:
		find_child(name).queue_free()
	
func save():
	return {
		"filename": get_scene_file_path(),
		"done": done,
		"tree_dead": tree_dead,
		"alive_enemies": find_enemies()
	}
	
func load_self(dict):
	assert(dict["filename"] == get_scene_file_path())
	done = dict["done"]
	tree_dead = dict["tree_dead"]
	alive_enemies = dict["alive_enemies"]


func _on_red_tree_dead():
	tree_dead = true


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
