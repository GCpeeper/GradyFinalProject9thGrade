class_name EnemyTopDown extends Enemy

enum State {LEFT, RIGHT, UP, DOWN, DEAD, DYING, REVIVING, IDLE, HIT_UP, HIT_DOWN, HIT_LEFT, HIT_RIGHT}
const MOVE_STATES = [State.LEFT, State.RIGHT, State.DOWN, State.UP]
const MOVE_VECTORS = {
	State.LEFT: Vector2(-50,0),
	State.RIGHT: Vector2(50,0),
	State.UP: Vector2(0,-50),
	State.DOWN: Vector2(0,50)
}

var state_time = 0.0
var curstate = State.IDLE
var collided = false


func hit(dam,hitter):
	health -= dam
	if health <= 0:
		dead.emit()
		switch_to(State.DYING)
	modulate = Color.DARK_RED
	after_hit = 0





func switch_to(new_state: State):
	if new_state == curstate:
		return true
	state_time = 0
	curstate = new_state
	
	if new_state == State.DYING:
		$AnimatedSprite2D.play("death")
	elif new_state in MOVE_STATES:
		$AnimatedSprite2D.play("walk_right")
		if new_state == State.RIGHT:
			$AnimatedSprite2D.flip_h = false
		elif new_state == State.LEFT:
			$AnimatedSprite2D.flip_h = true
	elif new_state == State.REVIVING:
		$AnimatedSprite2D.play_backwards("death")
	
func update_animation():
	if curstate == State.DYING:
		$AnimatedSprite2D.play("death")
	elif curstate in MOVE_STATES:
		if curstate == State.RIGHT:
			$AnimatedSprite2D.play("walk_right")
		elif curstate == State.LEFT:
			$AnimatedSprite2D.play("walk_left")
		elif curstate == State.DOWN:
			$AnimatedSprite2D.play("walk_down")
		elif curstate == State.UP:
			$AnimatedSprite2D.play("walk_up")
	elif curstate == State.REVIVING:
		$AnimatedSprite2D.play_backwards("death")


func _ready():
	switch_to(State.IDLE)

func _process(delta):
	if after_hit < 0.5:
		after_hit +=delta
		
	if after_hit > 0.5:
		modulate = Color.WHITE

func _physics_process(delta):
	state_time += delta
	
	if curstate == State.IDLE:
		switch_to(MOVE_STATES.pick_random())
	
	if curstate in MOVE_STATES:
		collided = move_and_collide(MOVE_VECTORS[curstate]*delta)
	
	if collided:
		var turn = true
		while not turn:
			turn = switch_to(MOVE_STATES.pick_random())
	
	if curstate == State.DEAD and state_time > 3:
		switch_to(State.REVIVING)


func _on_animated_sprite_2d_animation_finished():
	if curstate == State.DYING:
		switch_to(State.DEAD)
	elif curstate == State.REVIVING:
		switch_to(State.IDLE)
	else:
		update_animation()
