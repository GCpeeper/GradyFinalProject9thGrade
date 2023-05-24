extends "res://Charater.gd"

enum State {IDLE, MOVE_LEFT, MOVE_RIGHT, JUMP, ATTACK, DYING, DEAD, FALLLING}
const MOVE_STATES = [State.MOVE_LEFT,State.MOVE_RIGHT]
const MOVE_VECTORS= {
	State.MOVE_LEFT: Vector2(-800,0),
	State.MOVE_RIGHT: Vector2(800,0),
	State.JUMP: Vector2(0,-2500)
}
const Attacks = ["Attack1","Attack2","Attack3"]
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

# Called when the node enters the scene tree for the first time.

func control_set():
	control = true
	
func switch_to(new_state: State):
	curstate = new_state
	state_time = 0.0
	
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
			$AnimatedSprite2D.play(Attacks.pick_random())
			$AnimatedSprite2D.flip_h = false
		elif lastMoveState == State.MOVE_LEFT:
			$AnimatedSprite2D.play(Attacks.pick_random())
			$AnimatedSprite2D.flip_h = true
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


func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y += gravity * delta
		dir.y += gravity * delta
	

	
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
			elif direction > 0 and is_on_floor() and curstate != State.ATTACK:
				switch_to(State.MOVE_RIGHT)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			dir.y = move_toward(velocity.x, 0, SPEED)
		
			
	if is_on_floor():
		jumps = 0
		
	if dir.y < 0 and curstate != State.JUMP:
		switch_to(State.JUMP)
		
	if dir == Vector2.ZERO:
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
