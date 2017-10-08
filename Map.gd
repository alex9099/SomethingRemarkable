extends Node
# Member variables
const GRAVITY = 500.0 # Pixels/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 200
const STOP_FORCE = 1300
const JUMP_SPEED = 200
const JUMP_MAX_AIRBORNE_TIME = 0.2

const SLIDE_STOP_VELOCITY = 1.0 # One pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # One pixel

var velocity = Vector2()
var on_air_time = 100
var jumping = false

var prev_jump_pressed = false
var paused = false
func _ready():
	set_physics_process(true)
	set_process(true)
	print("test")

func _physics_process(delta):
	# Create forces
	var force = Vector2(0, GRAVITY)

	var walk_left = Input.is_action_pressed("ui_left")
	var walk_right = Input.is_action_pressed("ui_right")
	var jump = Input.is_action_pressed("ui_up")

	var stop = true

	if (walk_left):
		if (velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED):
			force.x -= WALK_FORCE
			stop = false
	elif (walk_right):
		if (velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED):
			force.x += WALK_FORCE
			stop = false

	if (stop):
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)

		vlen -= STOP_FORCE*delta
		if (vlen < 0):
			vlen = 0

		velocity.x = vlen*vsign

	# Integrate forces to velocity
	velocity += force*delta
	# Integrate velocity into motion and move

	velocity = get_node("HBoxContainer/Stickman").move_and_slide(velocity,Vector2(0,-1))

	if (get_node("HBoxContainer/Stickman").is_on_floor()):
		on_air_time=0

	if (jumping and velocity.y > 0):
		# If falling, no longer jumping
		jumping = false

	if (on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping):
		# Jump must also be allowed to happen if the character left the floor a little bit ago.
		# Makes controls more snappy.
		velocity.y = -JUMP_SPEED
		jumping = true

	on_air_time += delta
	prev_jump_pressed = jump


func _on_Pause_pressed():
	get_tree().set_pause(true)
	get_node("HBoxContainer/PauseMenu").show()

func _on_Resume_pressed():
	get_node("HBoxContainer/PauseMenu").hide()
	get_tree().set_pause(false)

func _process(delta):
#	print(get_node("HBoxContainer/Stickman").move_and_collide(Vector2(0,0)).collider_id)
#	print(get_node("HBoxContainer/Stickman/RayCast2D").get_collider())
#	if (get_node("HBoxContainer/Stickman/RayCast2D").get_collider() == get_node("HBoxContainer/Colliders/Blue")):
#		get_tree().set_pause(true)
#		get_node("HBoxContainer/PauseMenu").show()
	pass

func _on_Blue_body_entered( body ):
	get_tree().change_scene("Blue.tscn")

func _on_Red_body_entered( body ):
	get_tree().change_scene("Red.tscn")
