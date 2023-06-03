extends Enemy


enum State {LEFT, RIGHT, DEAD, DYING, IDLE}

const MOVE_STATES = [State.LEFT, State.RIGHT]
const MOVE_VECTORS = {
	State.LEFT: Vector2(-250,0),
	State.RIGHT: Vector2(250,0)
}
const TYPES = ["Spear","Dagger"]
var type = TYPES.pick_random()
var state_time = 0.0
var curstate = State.IDLE
var collided = false
var dir = Vector2.ZERO
var gravity = 400
var SPEED = 250
var lastMove = null
var planedState = null
var direction = 1
var right_ground = null
var left_ground = null

func switch_to(new_state: State):
	state_time = 0
	curstate = new_state
	$RightGround.monitoring = false
	$RightTurn.monitoring = false
	$LeftGround.monitoring = false
	$LeftTurn.monitoring = false
	if type == "Spear":
		if new_state == State.DYING:
			#$AnimatedSprite2D.play("death")
			pass
		elif new_state in MOVE_STATES:
			$Spear.play("Move")
			if new_state == State.RIGHT:
				$Spear.flip_h = false
				lastMove = State.RIGHT
				$RightGround.monitoring = true
				$RightTurn.monitoring = true
			elif new_state == State.LEFT:
				$Spear.flip_h = true
				lastMove = State.LEFT
				$LeftGround.monitoring = true
				$LeftTurn.monitoring = true
		elif new_state == State.IDLE:
			$Spear.play("Idle")
			if lastMove == State.LEFT:
				$Dagger.flip_h = true
			elif lastMove == State.RIGHT:
				$Dagger.flip_h = false
	elif type == "Dagger":
		if new_state == State.DYING:
			#$AnimatedSprite2D.play("death")
			pass
		elif new_state in MOVE_STATES:
			$Dagger.play("Move")
			if new_state == State.RIGHT:
				$Dagger.flip_h = false
				lastMove = State.RIGHT
				$RightGround.monitoring = true
				$RightTurn.monitoring = true
			elif new_state == State.LEFT:
				$Dagger.flip_h = true
				lastMove = State.LEFT
				$LeftGround.monitoring = true
				$LeftTurn.monitoring = true
		elif new_state == State.IDLE:
			$Dagger.play("Idle")
			if lastMove == State.LEFT:
				$Dagger.flip_h = true
			elif lastMove == State.RIGHT:
				$Dagger.flip_h = false

func update_animation():
	if type == "Spear":
		if curstate == State.DYING:
			#$AnimatedSprite2D.play("death")
			pass
		elif curstate in MOVE_STATES:
			$Spear.play("Move")
			if curstate == State.RIGHT:
				$Spear.flip_h = true
			elif curstate == State.LEFT:
				$AnimatedSprite2D.flip_h = false
	elif type == "Dagger":
		if curstate == State.DYING:
			#$AnimatedSprite2D.play("death")
			pass
		elif curstate in MOVE_STATES:
			$Dagger.play("Move")
			if curstate == State.RIGHT:
				$Dagger.flip_h = true
			elif curstate == State.LEFT:
				$Dagger.flip_h = false

func _ready():
	switch_to(MOVE_STATES.pick_random())
	if type == "Spear":
		$Dagger.hide()
	elif type == "Dagger":
		$Spear.hide()

func _physics_process(delta):
	state_time += delta

	if not is_on_floor():
		velocity.y += gravity * delta
	
	if curstate in MOVE_STATES:
		if curstate == State.RIGHT:
			direction = 1
		elif curstate == State.LEFT:
			direction = -1
		velocity.x = direction * SPEED
	
	move_and_slide()
	
	if not right_ground and curstate == State.RIGHT:
		switch_to(State.LEFT)
	elif not left_ground and curstate == State.LEFT:
		switch_to(State.RIGHT)
	


func _on_animated_sprite_2d_animation_finished():
	if curstate == State.DYING:
		switch_to(State.DEAD)
	else:
		update_animation()


func _on_left_turn_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if local_shape_index == 0 and curstate == State.LEFT:
		switch_to(State.RIGHT)
		print("Collided and Going Right")

func _on_left_turn_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	pass

func _on_right_turn_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if local_shape_index == 0 and curstate == State.RIGHT:
		switch_to(State.LEFT)
		print("Collided and Going left")

func _on_right_turn_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	pass

func _on_right_ground_area_exited(area):
	right_ground = false

func _on_right_ground_area_entered(area):
	right_ground = true

func _on_left_ground_area_exited(area):
	left_ground = false

func _on_left_ground_area_entered(area):
	left_ground = true
