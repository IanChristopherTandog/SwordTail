extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
const FireBall = preload("res://Enemies/FireBall.tscn")

export var ACCELERATION = 200
export var MAX_SPEED = 40
export var FRICTION = 150
export var WANDER_TARGET_RANGE = 30

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var state = CHASE
var can_shoot = true  # Prevents firing multiple fireballs at once

onready var sprite = $AnimatedSprite
onready var stats = $WormStats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer
onready var animatedSprite = $AnimatedSprite
onready var wormSounds = $wormSounds
onready var fireBreath = $fireBreath
onready var fireballTimer = $FireballTimer  
onready var wormBar = $WormBar

func _ready():
	state = pick_random_state([IDLE, WANDER])
	
	
	fireballTimer.wait_time = 3 # Shoots every 2.8 seconds
	fireballTimer.start()
	
	wormBar.value = stats.health
	if PlayerStats.level == 6:		
		wormSounds.play()

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
				
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(wanderController.target_position, delta)
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
			
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
		if can_shoot:
			animatedSprite.play("Attack")  # Play attack animation
	else:
		animatedSprite.play("Fly")

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()


func shoot_fireball():
	if playerDetectionZone.player == null or not can_shoot:
		return 

	can_shoot = false  # Prevent shooting multiple fireballs at once
	var fireball = FireBall.instance()
	get_parent().add_child(fireball)
	
	
	var fireball_offset = Vector2(35, -25) 
	if sprite.flip_h:
		fireball_offset.x *= -1  # Flip position if facing left

	fireball.launch(global_position + fireball_offset, playerDetectionZone.player.global_position)

	yield(get_tree().create_timer(0.3), "timeout")  # Small delay before allowing another shot
	can_shoot = true
#
func _on_FireballTimer_timeout():
	if state == CHASE and playerDetectionZone.can_see_player() and can_shoot:
		animatedSprite.play("Attack")  
		yield(animatedSprite, "animation_finished")  # Wait for Attack animation


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 150
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)
	print(stats.health)
	wormBar.value = stats.health
	if stats.health <= 0:
		PlayerStats.add_expi(100)  # Gain 10 EXP per enemy killed
		PlayerStats.lifesteal()
		print("Enemy defeated! Current EXP:", PlayerStats.expi)  # Debug print
		queue_free()
		
		var enemyDeathEffect = EnemyDeathEffect.instance()
		get_parent().add_child(enemyDeathEffect)
		enemyDeathEffect.global_position = global_position


func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")


#func _on_AnimatedSprite_animation_finished():
#	if animatedSprite.animation == "Attack":
#		shoot_fireball()


func _on_AnimatedSprite_frame_changed():
	if animatedSprite.animation == "Attack":
		if animatedSprite.frame == 12: # Change '3' to the frame where you want to shoot
			shoot_fireball()
