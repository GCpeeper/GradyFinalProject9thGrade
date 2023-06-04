class_name Goblin extends Enemy


enum State {LEFT, RIGHT, DEAD, DYING, IDLE, HIT}

const MOVE_STATES = [State.LEFT, State.RIGHT]
const MOVE_VECTORS = {
	State.LEFT: Vector2(-250,0),
	State.RIGHT: Vector2(250,0)
}
const TYPES = ["Spear","Dagger"]
const DAMAGE = [9,10,11,10,10,9,11,8,12]
var type = TYPES.pick_random()
var state_time = 0.0
var curstate = State.IDLE
var collided = false
var dir = Vector2.ZERO
var gravity = 400
var SPEED = 400
var lastMove = null
var planedState = null
var direction = 1
var right_ground = null
var left_ground = null

func switch_to(new_state: State):
	state_time = 0
	curstate = new_state
	if type == "Spear":
		if new_state == State.DYING:
			#$AnimatedSprite2D.play("death")
			pass
		elif new_state in MOVE_STATES:
			$Spear.play("Move")
			if new_state == State.RIGHT:
				$Spear.flip_h = true
				lastMove = State.RIGHT
			elif new_state == State.LEFT:
				$Spear.flip_h = false
				lastMove = State.LEFT
		elif new_state == State.IDLE:
			$Spear.play("Idle")
			if lastMove == State.LEFT:
				$Spear.flip_h = false
			elif lastMove == State.RIGHT:
				$Spear.flip_h = true
		elif new_state == State.HIT:
			$Spear.play("Attack")
			if lastMove == State.LEFT:
				$Spear.flip_h = false
			elif lastMove == State.RIGHT:
				$Spear.flip_h = true
	elif type == "Dagger":
		if new_state == State.DYING:
			#$AnimatedSprite2D.play("death")
			pass
		elif new_state in MOVE_STATES:
			$Dagger.play("Move")
			if new_state == State.RIGHT:
				$Dagger.flip_h = true
				lastMove = State.RIGHT
			elif new_state == State.LEFT:
				$Dagger.flip_h = false
				lastMove = State.LEFT
		elif new_state == State.IDLE:
			$Dagger.play("Idle")
			if lastMove == State.LEFT:
				$Dagger.flip_h = false
			elif lastMove == State.RIGHT:
				$Dagger.flip_h = true
		elif new_state == State.HIT:
			$Dagger.play("Attack")
			if lastMove == State.LEFT:
				$Dagger.flip_h = false
			elif lastMove == State.RIGHT:
				$Dagger.flip_h = true

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
				$Spear.flip_h = false
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
				
func turn():
	if curstate == State.LEFT and state_time > 0.25:
		switch_to(State.RIGHT)
	elif curstate == State.RIGHT and state_time > 0.25:
		switch_to(State.LEFT)
	else:
		switch_to(MOVE_STATES.pick_random())

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
		velocity.x = direction * SPEED * delta
	
	move_and_slide()
	
	




func _on_left_turn_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if lastMove == State.LEFT:
		turn()

func _on_right_turn_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if lastMove == State.RIGHT:
		turn()




func _on_attack_area_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	var struck = false
	if lastMove == State.RIGHT and local_shape_index == 1:
		struck = true
	elif lastMove == State.LEFT and local_shape_index == 0:
		struck = true
	
	if body is Charater and struck:
		switch_to(State.HIT)
	
	if curstate == State.HIT and body != self and body != TileMap:
		if body is Charater:
			body.hit(DAMAGE.pick_random())


func _on_dagger_animation_finished():
	if curstate == State.DYING:
		switch_to(State.DEAD)
	elif curstate == State.HIT:
		turn()
	update_animation()


func _on_spear_animation_finished():
	if curstate == State.DYING:
		switch_to(State.DEAD)
	elif curstate == State.HIT:
		turn()
	update_animation()


func save():
	return {
		"filename": get_scene_file_path(),
		"pos_x": position.x,
		"pos_y": position.y,
		"state_time": state_time,
		"lastMove": lastMove,
		"health": health,
		"curstate": curstate,
		"type": type
}

func load(dict):
	assert(dict["filename"] == get_scene_file_path())
	position.x = dict["pos_x"]
	position.y = dict["pos_y"]
	state_time = dict["state_time"]
	lastMove= dict["lastMove"]
	health = dict["health"]
	curstate = dict["curstate"]
	type = dict["type"]
