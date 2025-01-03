class_name main
extends Node

var godzilla = preload("res://Scene/Godzilla.tscn")
var tandil = preload("res://Scene/Tandil.tscn")
var mecha = preload("res://Scene/mecha.tscn")
var nefe = preload("res://Scene/nefe.tscn")
var gameOver = preload("res://Scene/game_over.tscn")
var new_view := gameOver.instantiate()

var obstacles_types := [godzilla, tandil, mecha, nefe]
var same_obs : Array
var obstacles : Array
var same
var mecha_height := 342
var nefe_height := 376

const RICO_START_POS := Vector2i(54,441)
const CAM_START_POS := Vector2i(288,324)
@onready var ground: StaticBody2D = $Ground
@onready var hud: CanvasLayer = $HUD
@onready var ricotero: CharacterBody2D = $Ricotero

var score: int
var score_modifier : int = 10
var speed: float
const START_SPEED : float = 500
const MAX_SPEED : float = 1000
const SPEED_MODIFIER: float = 0.009
var screen_size : Vector2i
var game_running: bool = false
var last_obs
var obs_type
var last_obs_type

func _ready() -> void:
	screen_size = get_window().size
	add_child(new_view)
	new_view.visible = false
	new_view.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game() ->void:
	for child in get_children():
		if child == new_view:
			if child.visible == true:
				child.visible = false
	last_obs = null
	obstacles.clear()
	
	ricotero.show()
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	$Ricotero.position = RICO_START_POS
	$Ricotero.velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	ground.position = Vector2i(0,-84)
	
	
	hud.get_node("StartLabel").show()


func _process(delta: float) -> void:
	if game_running:
		speed = START_SPEED + (score * SPEED_MODIFIER)
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		
		generate_obs()
		
		$Ricotero.position.x += speed*delta
		$Camera2D.position.x += speed*delta
		score += speed*0.02
		show_score()
		
		if $Camera2D.position.x - ground.position.x > screen_size.x * 1.5:
			ground.position.x += screen_size.x
		
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obstacle(obs)
	else:
		if Input.is_action_just_pressed("ui_accept"):
			game_running = true
			hud.get_node("StartLabel").hide()
		

func show_score() -> void:
	hud.get_node("Score").text = "Score: " +str(score / score_modifier)

func generate_obs() -> void:
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(100,300):
		obs_type = obstacles_types.pick_random()
		while obs_type == last_obs_type:
			obs_type = obstacles_types.pick_random()
		var obs
		obs = obs_type.instantiate()

		var obs_x : float = screen_size.x + score + 200
		var obs_y : float
		match obs_type:
			godzilla:
				obs_y = 477.0
			mecha:
				obs_y = 342.0
			nefe:
				obs_y = 376.0
			tandil:
				obs_y = 443.0
		last_obs = obs
		last_obs_type = obs_type
		add_obs(obs,obs_x,obs_y)

		

func add_obs(obs, x, y) ->void:
	obs.position = Vector2i(x,y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)
	
func remove_obstacle(obs):
	obs.queue_free()
	obstacles.erase(obs)

func hit_obs(body) ->void:
	if body.name == "Ricotero":
		ricotero.hide()
		game_over()

func game_over() ->void:
	new_view.visible = true
	new_view.get_node("player").play("game_over")
	get_tree().paused = true
	game_running = false
	
