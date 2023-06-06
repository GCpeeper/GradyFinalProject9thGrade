extends EnemyTopDown

const HIT_STATES = [State.HIT_DOWN,State.HIT_LEFT,State.HIT_RIGHT,State.HIT_UP]
const DAMAGE = [30,29,28,29,30,30,31,32,33,34,35,31,30,29]
var lastMoveState = null
var lastHealth
var justRevived = false

func hit(dam,hitter):
	health -= dam
	print(health)
	if health <= 0:
		dead.emit()
		switch_to(State.DYING)
	modulate = Color.DARK_RED
	after_hit = 0

	var dir = hitter.position - self.position
	var ang = rad_to_deg(dir.angle())
		
	if ang > -45 and ang < 45:
		switch_to(State.HIT_RIGHT)
	elif ang > 45 and ang < 135:
		switch_to(State.HIT_DOWN)
	elif ang < -45 and ang > -135:
		switch_to(State.HIT_UP)
	else:
		switch_to(State.HIT_LEFT)



func switch_to(new_state: State):
	if new_state == curstate:
		return true
	print("switching to: ",curstate)
	state_time = 0
	curstate = new_state
	
	justRevived = true
	$HitArea.monitoring = false
	$AnimatedSprite2D.show()
	$CollisionShape2D.disabled = false
	if new_state == State.DYING:
		justRevived = true
		$AnimatedSprite2D.play("death")
	elif new_state in MOVE_STATES:
		justRevived = false
		if curstate == State.RIGHT:
			$AnimatedSprite2D.play("walk_right")
			lastMoveState = new_state
		elif curstate == State.LEFT:
			$AnimatedSprite2D.play("walk_left")
			lastMoveState = new_state
		elif curstate == State.DOWN:
			$AnimatedSprite2D.play("walk_down")
			lastMoveState = new_state
		elif curstate == State.UP:
			$AnimatedSprite2D.play("walk_up")
			lastMoveState = new_state
	elif new_state in HIT_STATES:
		justRevived = false
		$HitArea.monitoring = true
		if curstate == State.HIT_RIGHT:
			$AnimatedSprite2D.play("slash_right")
		elif curstate == State.HIT_LEFT:
			$AnimatedSprite2D.play("slash_left")
		elif curstate == State.HIT_DOWN:
			$AnimatedSprite2D.play("slash_down")
		elif curstate == State.HIT_UP:
			$AnimatedSprite2D.play("slash_up")
	elif new_state == State.REVIVING:
		health = lastHealth + 10
		lastHealth = health
		$AnimatedSprite2D.play_backwards("death")
	elif new_state == State.DEAD:
		justRevived = true
		$AnimatedSprite2D.hide()
		$CollisionShape2D.disabled = true
	elif new_state == State.IDLE:
		justRevived = true
		if lastMoveState == State.DOWN:
			$AnimatedSprite2D.play("idle_down")
		elif lastMoveState == State.UP:
			$AnimatedSprite2D.play("idle_up")
		elif lastMoveState == State.RIGHT:
			$AnimatedSprite2D.play("idle_right")
		elif lastMoveState == State.LEFT:
			$AnimatedSprite2D.play("idle_left")

	
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
		health = lastHealth + 10
		lastHealth = health


func _ready():
	switch_to(State.IDLE)
	health = 30
	lastHealth = health

func _process(delta):
	if after_hit < 0.5:
		after_hit +=delta
		
	if after_hit > 0.5:
		modulate = Color.WHITE

func _physics_process(delta):
	state_time += delta
	
	if health < 0 and curstate != State.DYING and curstate != State.DEAD and curstate != State.REVIVING and not justRevived:
		dead.emit()
		switch_to(State.DYING)
		justRevived = true
	
	if curstate == State.IDLE:
		switch_to(MOVE_STATES.pick_random())
	
	if curstate in MOVE_STATES:
		collided = move_and_collide(MOVE_VECTORS[curstate]*delta)
	
	if collided:
		var turn
		while not turn:
			turn = switch_to(MOVE_STATES.pick_random())
	
	if curstate == State.DEAD and state_time > 3:
		switch_to(State.REVIVING)


func _on_animated_sprite_2d_animation_finished():
	if curstate == State.DYING:
		switch_to(State.DEAD)
	elif curstate == State.REVIVING:
		switch_to(State.IDLE)
	elif curstate in HIT_STATES:
		switch_to(State.IDLE)
	else:
		update_animation()
	



func _on_hit_area_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	var struck = false
	
	if curstate in HIT_STATES:
		
		if local_shape_index == 0 and curstate == State.HIT_DOWN:
			struck = true
		elif local_shape_index == 1 and curstate == State.HIT_LEFT:
			struck = true
		elif local_shape_index == 2 and curstate == State.HIT_RIGHT:
			struck = true
		elif local_shape_index == 3 and curstate == State.HIT_UP:
			struck = true
	
		if body is Charater and struck:
			body.hit(DAMAGE.pick_random(),self)
