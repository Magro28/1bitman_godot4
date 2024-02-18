extends CharacterBody2D


@export var movement_data : PlayerMovementData

#double jump
var air_jump = false
var just_wall_jumped = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position

func _physics_process(delta):

	apply_gravity(delta)
	handle_wall_jump()
	handle_jump()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_axis = Input.get_axis("ui_left", "ui_right")
	handle_acceleration(input_axis, delta)
	handle_air_accelaration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	updated_animations(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	#coyote jump logic (when you just left a ledge give a grace period where the player can jump)
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	
	just_wall_jumped = false
	#switch movement data on runtime
	#if Input.is_action_just_pressed("ui_accept"):
	#	movement_data = load("res://LowGravityMovementData.tres")
	

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta
		
func handle_wall_jump():
	if not is_on_wall_only(): return
	var wall_normal = get_wall_normal() # normal is vector which points away from wall
	if  Input.is_action_just_pressed("ui_up"): #and (Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right")) and (wall_normal == Vector2.LEFT or wall_normal == Vector2.RIGHT):
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity
		just_wall_jumped = true

func handle_jump():
	if is_on_floor(): air_jump = true
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = movement_data.jump_velocity
	elif not is_on_floor():
		if Input.is_action_just_released("ui_up") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2
		#double jump
		if Input.is_action_just_pressed("ui_up") and air_jump and not just_wall_jumped:
			velocity.y = movement_data.jump_velocity * 0.8 #reduce air jump effectivness by 20%
			air_jump = false
			
func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x,movement_data.speed * input_axis,movement_data.acceleration * delta)

func handle_air_accelaration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration  * delta)

func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
	
func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)
		
func updated_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h=(input_axis < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")


func _on_hazard_detector_area_entered(area):
	#respawn
	global_position = starting_position
	#kills the player node
	#queue_free()
