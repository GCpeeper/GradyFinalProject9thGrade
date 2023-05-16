extends "res://Charater.gd"

enum {IDLE, MOVE_RIGHT, MOVE_LEFT, JUMP, ATTACK, DYING, DEAD}
var SPEED = 100.0
var JUMP_VELOCITY = -233.3
var last_dir = Vector2.ZERO
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var dir = Vector2.ZERO
var gems_collected = 0
var deaths = 0
var jumps = 0
var control = false
var swipe_damage = 10
var stab_damage = 5
var max_jumps = 2
var fly = false
# Called when the node enters the scene tree for the first time.
func control_set():
	control = true

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y += gravity * delta
		dir.y += gravity * delta
	
	if is_on_floor():
		jumps = 0
	if control:
		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
			dir.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			dir.x = move_toward(velocity.x, 0, SPEED)
		if Input.is_action_just_pressed("jump") and jumps<max_jumps:
			velocity.y = JUMP_VELOCITY
			dir.y = JUMP_VELOCITY
			jumps += 1
		elif Input.is_action_pressed("down") and fly:
			velocity.y = -JUMP_VELOCITY
			
	
	velocity.y += gravity*delta
	dir.y += gravity*delta
	
	if position.y > 575:
		position.x = 580
		position.y = 270
		deaths += 1
	
	move_and_slide()
		
	last_dir = dir
	
func _process(delta):
	var game_scene = get_node("/root/Level1") # Get a reference to the GameScene node
	var plays = game_scene.plays
	
	if not plays:
		if dir.x > 0 or last_dir.x > 0:		
			$KnightSheet.flip_h = false
		elif dir.x < 0 or last_dir.x < 0:
			$KnightSheet.flip_h = true
		if not is_on_floor():
			$KnightSheet.play("Jump")
		elif dir.x == 0:
			$KnightSheet.play("Idle")
		else:
			$KnightSheet.play("Walk")

func _on_animated_sprite_2d_animation_finished():
	pass # Replace with function body.
