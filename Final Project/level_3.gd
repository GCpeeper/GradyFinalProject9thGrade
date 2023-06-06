extends Node2D

var summonArea = [Vector2(767,-358),Vector2(780,529),Vector2(-539,499),Vector2(-577,-49),Vector2(-329,-359)]
var randGen = RandomNumberGenerator.new()
var randList = []
var bomb = preload("res://bomb.tscn")

func _ready():
	for i in range(100):
		randList.append(genRandPos())

func _physics_process(delta):

	var bomb_scene = preload("res://bomb.tscn")

	# Put this where you want to spawn the bombs
	var mob = bomb_scene.instantiate()
	
	mob.position = randList.pick_random()
	# Spawn it by adding it to the Main scene.
	add_child(mob)


func genRandPos():
	var minX = -577
	var maxX = 780
	var minY = -359
	var maxY = 529

	var randX = randGen.randi_range(minX,maxX)
	var randY = randGen.randi_range(minY,maxY)

	return Vector2(randX, randY)

