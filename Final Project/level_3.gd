extends Node2D

var summonArea = [Vector2(767,-358),Vector2(780,529),Vector2(-539,499),Vector2(-577,-49),Vector2(-329,-359)]
var randGen = RandomNumberGenerator.new()

func _ready():
	pass

func _physics_process(delta):
	var bomb = load("res://bomb.tscn")
	var new_instance = bomb.instance()
	add_child(new_instance) 
	new_instance.position = genRandPos()

func genRandPos():
	var minX = -577
	var maxX = 780
	var minY = -359
	var maxY = 529

	var randX = randGen.randi_range(minX,maxX)
	var randY = randGen.randi_range(minY,maxY)

	return Vector2(randX, randY)

