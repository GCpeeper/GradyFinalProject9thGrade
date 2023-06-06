extends Node2D
const chance = [1,2,3,4]
var time = 0
var post_time = 0
var fire
var in_fire = false
var first = false

# Called when the node enters the scene tree for the first time.
func _ready():
	fire = chance.pick_random()
	$Flame/FlameArea.monitoring = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	post_time += delta
	
	if time > 2:
		print("Exploded")
		if fire == 2:
			if first:
				$BoomBoom.queue_free()
				first = false
			print("Killed")
			$Flame/FlameArea.monitoring = true
			post_time = 0
			$Flame.show()
		else:
			queue_free()
	
	if post_time > 5:
		queue_free()
	


func _on_bomb_area_body_entered(body):
	if body is Charater:
		body.burn(50)


func _on_flame_area_body_entered(body):
	if body is Charater:
		body.burn(10)


func _on_flame_area_body_exited(body):
	if body is Charater:
		body.stop_burn() 
