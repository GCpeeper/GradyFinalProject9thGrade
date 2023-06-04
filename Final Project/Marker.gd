class_name Marker extends Area2D
var player_exited = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body is Goblin:
		body.turn()
	elif body is Charater and player_exited:
		body.marker()
		player_exited = false

func save():
	pass

func load(dict):
	pass
