extends CharacterBody2D

@export var speed : float = 150.0
@export var jump_velocity : float = -175.0
@export var double_jump_velocity : float = -150.0

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jumped : bool = false
var animation_locked : bool = false
var direction : Vector2 = Vector2.ZERO
var was_in_air : bool = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		was_in_air = true        
	else:
		has_double_jumped = false
		
		if was_in_air == true:
			land()
			animation_locked = false  # Unlock the animation when landing
		
		was_in_air = false

	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			# Normal jump from floor
			jump()
		elif not has_double_jumped:
			# Double jump in air
			double_jump()

	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_vector("left", "right", "up", "down")
	
	if direction.x != 0:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	
	# Update the character's animation based on its state
	update_animation()
	update_direction_facing()

func update_animation():
	if not animation_locked:
		if not is_on_floor() and velocity.y > 0:
			animated_sprite.play("jump_end")
		elif direction.x != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")

func update_direction_facing():
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true

func jump():
	velocity.y = jump_velocity
	animated_sprite.play("jump_start")
	animation_locked = true
	
func double_jump():
	velocity.y = double_jump_velocity
	animated_sprite.play("jump_double")
	animation_locked = true
	has_double_jumped = true

func land():
	animated_sprite.play("jump_end")
	animation_locked = true

func _on_animated_sprite_2d_animation_finished():
	if (["jump_end", "jump_start", "jump_double", "jump_end"].has(animated_sprite.animation)):
		animation_locked = false
