extends Enemy

func _ready():
	health = 50

func hit(dam,hitter):
	health -= dam
	if health <= 0:
		dead.emit()
		queue_free()
	modulate = Color.DARK_RED
	after_hit = 0


func _process(delta):
	if after_hit < 0.5:
		after_hit +=delta
		
	if after_hit > 0.5:
		modulate = Color.WHITE
		
func load(dict):
	pass

func save():
	pass
