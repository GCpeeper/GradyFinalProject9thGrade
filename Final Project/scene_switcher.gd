extends CanvasLayer



#from Godot docs

var current_scene = null
var scenes_saved = []

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	scenes_saved = []
	
func _process(delta):
	pass

func reset_scenes():
	scenes_saved = []

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	$AnimationPlayer.play("fade")
	await $AnimationPlayer.animation_finished
	call_deferred("_deferred_goto_scene", path)
	$AnimationPlayer.play_backwards("fade")


func _deferred_goto_scene(path):
	var player_health
	if current_scene.name != "MainMenu" and current_scene.name != "YouLost" and current_scene.name != "YouWon":
		if current_scene.name == "Level1":
			player_health = current_scene.find_child("Player1").health
		elif current_scene.name == "Level2":
			player_health = current_scene.find_child("Player2").health
		elif current_scene.name == "Level4":
			player_health = current_scene.find_child("Player4").health
		
	current_scene.save_all()
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()
	
	if path in scenes_saved:
		current_scene.load_all(current_scene)
	
	scenes_saved.append(path)
	
	if current_scene.name != "MainMenu" and current_scene.name != "YouLost":
		if current_scene.name == "Level1":
			current_scene.find_child("Player1").health = player_health
		elif current_scene.name == "Level2":
			current_scene.find_child("Player2").health = player_health
		elif current_scene.name == "Level4":
			current_scene.find_child("Player4").health = player_health

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
