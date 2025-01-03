extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1300
@onready var jump_sound: AudioStreamPlayer = %jumpSound
@onready var animation: AnimatedSprite2D = $Animation
@onready var run_col: CollisionShape2D = $runCol
@onready var duck_col: CollisionShape2D = $duckCol


func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			animation.play("idle")
			pass
		else:
			run_col.disabled= false
			if Input.is_action_pressed("ui_accept"):
				velocity.y = JUMP_SPEED
				animation.play("jump")
				jump_sound.play()
			elif Input.is_action_pressed("ui_down"):
				animation.play("duck")
				run_col.disabled = true
			else:
				animation.play("run")
	
		
		
	move_and_slide()

func _is_animation_playing(animation_playing: String) -> bool:
	print(animation.animation)
	print(animation_playing)
	if animation.animation == animation_playing:
		return true
	else: return false
