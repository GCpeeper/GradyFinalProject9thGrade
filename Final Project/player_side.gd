extends "res://Charater.gd"

enum State {IDLE, MOVE_LEFT, MOVE_RIGHT, JUMP, ATTACK, DYING, DEAD, FALLLING}
const MOVE_STATES = [State.MOVE_LEFT,State.MOVE_RIGHT]
const MOVE_VECTORS= {
	State.MOVE_LEFT: Vector2(-800,0),
	State.MOVE_RIGHT: Vector2(800,0),
	State.JUMP: Vector2(0,-2500)
}
const Attacks = ["Attack1","Attack2","Attack3"]
const DAMAGE = [4,5,6]

var SPEED = 200.0
var JUMP_VELOCITY = -233.3
var lastMoveState: State = State.MOVE_RIGHT
var lastdir: Vector2 = Vector2.ZERO
var gravity = 400
var dir = Vector2.ZERO
var gems_collected = 0
var deaths = 0
var jumps = 0
var control = true
var swipe_damage = 10
var stab_damage = 5
var max_jumps = 2
var curstate = State.IDLE
var state_time = 0.0
var health = 100
var attack = Attacks.pick_random()
var after_hit = 0.5

# Called when the node enters the scene tree for the first time.

func control_set():
	control = true
	
func switch_to(new_state: State):
	curstate = new_state
	state_time = 0.0
	$Attack1.monitoring = false
	$Attack2.monitoring = false
	$Attack3.monitoring = false
	attack = Attacks.pick_random()
	
	if new_state in MOVE_STATES:
		#$SwordArea.monitoring = false
		if new_state == State.MOVE_RIGHT:
			$AnimatedSprite2D.play("Walk")
			$AnimatedSprite2D.flip_h = false
			lastMoveState = State.MOVE_RIGHT
		elif new_state == State.MOVE_LEFT:
			$AnimatedSprite2D.play("Walk")
			$AnimatedSprite2D.flip_h = true
			lastMoveState = State.MOVE_LEFT
	elif new_state == State.IDLE:
		#$SwordArea.monitoring = false
		if lastMoveState == State.MOVE_RIGHT:
			$AnimatedSprite2D.play("Idle")
			$AnimatedSprite2D.flip_h = false
		elif lastMoveState == State.MOVE_LEFT:
			$AnimatedSprite2D.play("Idle")
			$AnimatedSprite2D.flip_h = true
	elif new_state == State.ATTACK:
		#$SwordArea.monitoring = true
		if lastMoveState == State.MOVE_RIGHT:
			$AnimatedSprite2D.play(attack)
			$AnimatedSprite2D.flip_h = false
		elif lastMoveState == State.MOVE_LEFT:
			$AnimatedSprite2D.play(attack)
			$AnimatedSprite2D.flip_h = true
		
		if attack == "Attack1":
			$Attack1.monitoring = true
		elif attack == "Attack2":
			$Attack2.monitoring = true
		elif attack == "Attack3":
			$Attack3.monitoring = true
	elif new_state == State.DYING:
		if lastMoveState == State.MOVE_RIGHT:
			$AnimatedSprite2D.play("dying")
			$AnimatedSprite2D.flip_h = false
		elif lastMoveState == State.MOVE_LEFT:
			$AnimatedSprite2D.play("dying")
			$AnimatedSprite2D.flip_h = true
	elif new_state == State.JUMP:
		if lastMoveState == State.MOVE_RIGHT:
			$AnimatedSprite2D.play("Jump")
			$AnimatedSprite2D.flip_h = false
		elif lastMoveState == State.MOVE_LEFT:
			$AnimatedSprite2D.play("Jump")
			$AnimatedSprite2D.flip_h = true
			
func _ready():
	floor_max_angle = 0.82030475
	wall_min_slide_angle = 0.82030475
	health = 100

func _process(delta):
	if after_hit < 0.5:
		after_hit +=delta
		
	if after_hit > 0.5:
		modulate = Color.WHITE

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y += gravity * delta
		dir.y += gravity * delta
	
	if health < 0:
		switch_to(State.DYING)
		control = false
	
	if is_on_floor():
		if curstate == State.FALLLING or curstate == State.JUMP:
			switch_to(State.IDLE)
	

	
	if control:
		# Handle Jump.
		if Input.is_action_just_pressed("moveup") and is_on_floor() and curstate != State.ATTACK:
			velocity.y = JUMP_VELOCITY
			dir.y = JUMP_VELOCITY
			switch_to(State.JUMP)
		elif Input.is_action_just_pressed("attack") and is_on_floor() and curstate != State.ATTACK:
			switch_to(State.ATTACK)

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("moveleft", "moveright")
		if direction:
			if curstate == State.ATTACK:
				velocity.x = direction * SPEED /2
				dir.x = direction * SPEED / 2
			else: 
				velocity.x = direction * SPEED
				dir.x = direction * SPEED
			if direction < 0 and is_on_floor() and curstate != State.ATTACK:
				switch_to(State.MOVE_LEFT)
				lastMoveState = State.MOVE_LEFT
			elif direction > 0 and is_on_floor() and curstate != State.ATTACK:
				switch_to(State.MOVE_RIGHT)
				lastMoveState = State.MOVE_RIGHT
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			dir.y = move_toward(velocity.x, 0, SPEED)
		
			
		if is_on_floor():
			jumps = 0
			
		if dir.y < 0 and curstate != State.JUMP:
			switch_to(State.JUMP)
			
		if dir == Vector2.ZERO and curstate != State.ATTACK and curstate != State.JUMP:
			switch_to(State.IDLE)
		
		move_and_slide()
		lastdir = dir
		dir *= 0


func _on_animated_sprite_2d_animation_finished():
	if curstate == State.ATTACK:
		switch_to(State.IDLE)
	elif curstate == State.DYING:
		switch_to(State.DEAD)
	elif not is_on_floor() and curstate == State.JUMP:
			switch_to(State.FALLLING)
			


func save():
	return {
		"filename": get_scene_file_path(),
		"pos_x": position.x,
		"pos_y": position.y,
		"state_time": state_time,
		"lastMoveState": lastMoveState,
		"lastdir": lastdir,
		"health": health,
		"curstate": curstate
}

func load(dict):
	assert(dict["filename"] == get_scene_file_path())
	position.x = dict["pos_x"]
	position.y = dict["pos_y"]
	state_time = dict["state_time"]
	lastMoveState = dict["lastMoveState"]
	health = dict["health"]
	curstate = dict["curstate"]


func _on_attack_1_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):

	if curstate == State.ATTACK and body != self:
		var struck = false

		if lastMoveState == State.MOVE_RIGHT and local_shape_index == 0:
			struck = true
		elif lastMoveState == State.MOVE_LEFT and local_shape_index == 1:
			struck = true

		if body is Enemy and struck:
			body.hit(DAMAGE.pick_random())


func _on_attack_2_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if curstate == State.ATTACK and body != self:
		var struck = false

		if lastMoveState == State.MOVE_RIGHT and local_shape_index == 0:
			struck = true
		elif lastMoveState == State.MOVE_LEFT and local_shape_index == 1:
			struck = true

		if body is Enemy and struck:
			body.hit(DAMAGE.pick_random())




func _on_attack_3_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if curstate == State.ATTACK and body != self:
		var struck = false

		if lastMoveState == State.MOVE_RIGHT and local_shape_index == 0:
			struck = true
		elif lastMoveState == State.MOVE_LEFT and local_shape_index == 1:
			struck = true

		if body is Enemy and struck:
			body.hit(DAMAGE.pick_random())

func hit(damage):
	health -= damage
	self.modulate = Color.RED
	after_hit = 0
