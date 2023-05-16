extends Charater

enum State {IDLE, MOVE_RIGHT, MOVE_LEFT, MOVE_UP, MOVE_DOWN, ATTACK, DYING, DEAD}
const MOVE_STATES = [State.MOVE_DOWN, State.MOVE_LEFT, State.MOVE_RIGHT, State.MOVE_UP]
const MOVE_VECTORS = {
	State.MOVE_LEFT: Vector2(-250,0),
	State.MOVE_RIGHT: Vector2(250,0),
	State.MOVE_UP: Vector2(0,-250),
	State.MOVE_DOWN: Vector2(0,250)
}

var curstate = State.IDLE
var lastMoveState: State = State.MOVE_DOWN
var lastdir: Vector2 = Vector2.ZERO
var state_time = 0.0
var health = 100
var inside = false

var in_up = false
var in_down = false
var in_right = false
var in_left = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("stand_down")
	print("Player was made")
	

func switch_to(new_state: State):
	curstate = new_state
	state_time = 0.0
	
	if new_state in MOVE_STATES:
		$SwordArea.monitoring = false
		if new_state == State.MOVE_RIGHT:
			$AnimatedSprite2D.play("walk_right")
			$AnimatedSprite2D.flip_h = false
			lastMoveState = State.MOVE_RIGHT
		elif new_state == State.MOVE_LEFT:
			$AnimatedSprite2D.play("walk_right")
			$AnimatedSprite2D.flip_h = true
			lastMoveState = State.MOVE_LEFT
		elif new_state == State.MOVE_UP:
			$AnimatedSprite2D.play("walk_up")
			$AnimatedSprite2D.flip_h = false
			lastMoveState = State.MOVE_UP
		elif new_state == State.MOVE_DOWN:
			$AnimatedSprite2D.play("walk_down")
			$AnimatedSprite2D.flip_h = false
			lastMoveState = State.MOVE_DOWN
	elif new_state == State.IDLE:
		$SwordArea.monitoring = false
		if lastMoveState == State.MOVE_DOWN:
			$AnimatedSprite2D.play("stand_down")
			$AnimatedSprite2D.flip_h = false
		elif lastMoveState == State.MOVE_UP:
			$AnimatedSprite2D.play("stand_up")
			$AnimatedSprite2D.flip_h = false
		elif lastMoveState == State.MOVE_RIGHT:
			$AnimatedSprite2D.play("stand_right")
			$AnimatedSprite2D.flip_h = false
		elif lastMoveState == State.MOVE_LEFT:
			$AnimatedSprite2D.play("stand_right")
			$AnimatedSprite2D.flip_h = true
	elif new_state == State.ATTACK:
		$SwordArea.monitoring = true
		if lastMoveState == State.MOVE_DOWN:
			$AnimatedSprite2D.play("swing_down")
			$AnimatedSprite2D.flip_h = false
		elif lastMoveState == State.MOVE_UP:
			$AnimatedSprite2D.play("swing_up")
			$AnimatedSprite2D.flip_h = false
		elif lastMoveState == State.MOVE_RIGHT:
			$AnimatedSprite2D.play("swing_right")
			$AnimatedSprite2D.flip_h = false
		elif lastMoveState == State.MOVE_LEFT:
			$AnimatedSprite2D.play("swing_right")
			$AnimatedSprite2D.flip_h = true
	elif new_state == State.DYING:
		if lastMoveState == State.MOVE_RIGHT:
			$AnimatedSprite2D.play("dying")
			$AnimatedSprite2D.flip_h = false
		elif lastMoveState == State.MOVE_LEFT:
			$AnimatedSprite2D.play("dying")
			$AnimatedSprite2D.flip_h = true
		if lastMoveState == State.MOVE_UP:
			$AnimatedSprite2D.play("dying")
			$AnimatedSprite2D.flip_h = false
		elif lastMoveState == State.MOVE_DOWN:
			$AnimatedSprite2D.play("dying")
			$AnimatedSprite2D.flip_h = true

		
func update_movement_animation():
	if curstate in MOVE_STATES:
		if curstate == State.MOVE_RIGHT:
			$AnimatedSprite2D.play("walk_right")
			$AnimatedSprite2D.flip_h = false
			lastMoveState = State.MOVE_RIGHT
		elif curstate == State.MOVE_LEFT:
			$AnimatedSprite2D.play("walk_right")
			$AnimatedSprite2D.flip_h = true
			lastMoveState = State.MOVE_LEFT
		elif curstate == State.MOVE_UP:
			$AnimatedSprite2D.play("walk_up")
			$AnimatedSprite2D.flip_h = false
			lastMoveState = State.MOVE_UP
		elif curstate == State.MOVE_DOWN:
			$AnimatedSprite2D.play("walk_down")
			$AnimatedSprite2D.flip_h = false
			lastMoveState = State.MOVE_DOWN


func _physics_process(delta):
	state_time += delta
	
	if Input.is_action_just_pressed("attack"):
		switch_to(State.ATTACK)
	elif Input.is_action_pressed("moveup") and curstate != State.ATTACK:
		switch_to(State.MOVE_UP)
	elif Input.is_action_pressed("movedown") and curstate != State.ATTACK:
		switch_to(State.MOVE_DOWN)
	elif Input.is_action_pressed("moveleft") and curstate != State.ATTACK:
		switch_to(State.MOVE_LEFT)
	elif Input.is_action_pressed("moveright") and curstate != State.ATTACK:
		switch_to(State.MOVE_RIGHT)
	
	
	if curstate in MOVE_STATES:
		var collided = move_and_collide(MOVE_VECTORS[curstate]*delta)
		if Input.is_action_just_released("moveup"):
			switch_to(State.IDLE)
		elif Input.is_action_just_released("movedown"):
			switch_to(State.IDLE)
		elif Input.is_action_just_released("moveleft"):
			switch_to(State.IDLE)
		elif Input.is_action_just_released("moveright"):
			switch_to(State.IDLE)
		


func _on_sword_area_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	# Figure out which collision shape to use for our sword, and hit an enemy with it
	inside = true
	
#	if body != self:
#		if local_shape_index == 0:
#			in_up = true
#		elif local_shape_index == 1:
#			in_down = true
#		elif local_shape_index == 2:
#			in_right = true
#		elif local_shape_index == 3:
#			in_left = true
	if curstate == State.ATTACK and body != self:
		var struck = false

		if lastMoveState == State.MOVE_RIGHT and local_shape_index == 2:
			struck = true
		elif lastMoveState == State.MOVE_LEFT and local_shape_index == 3:
			struck = true
		elif lastMoveState == State.MOVE_DOWN and local_shape_index == 1:
			struck = true
		elif lastMoveState == State.MOVE_UP and local_shape_index == 0:
			struck = true

		if body is Enemy and struck:
			body.hit()


func _on_sword_area_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	inside = false
	
#	if body != self:
#		if local_shape_index == 0:
#			in_up = true
#		elif local_shape_index == 1:
#			in_down = true
#		elif local_shape_index == 2:
#			in_right = true
#		elif local_shape_index == 3:
#			in_left = true


func _on_animated_sprite_2d_animation_finished():
	print("animation ended")
	if curstate == State.ATTACK:
		switch_to(State.IDLE)
	elif curstate == State.DYING:
		switch_to(State.DEAD)
