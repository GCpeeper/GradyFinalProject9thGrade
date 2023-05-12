extends Enemy

var health = 3

func hit():
	health -= 1
	if health <= 0:
		queue_free()
