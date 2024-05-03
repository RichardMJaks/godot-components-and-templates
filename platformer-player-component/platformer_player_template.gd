extends Node
class_name Player

# TODO: Controlled jump height option

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#region Get Timers
@onready var _timer_coyote_buffer : Timer = $CoyoteBuffer
@onready var _timer_jump_input_buffer : Timer = $JumpBuffer
#endregion

#region Player action control variables
var moving : bool = false

# Buffering
var _coyote_in_buffer : bool = true
var _jump_input_in_buffer : bool = false
#endregion

#region Player Stats
@export var acceleration_time = 0
@export var jump_height = 0
@export var move_speed = 0
@export var wall_climb_speed = 0
@export var _fall_gravity_reduction_multiplier = 0
#endregion

func _ready():
	# Check for presence of required inputs
	Input.get_axis("move_left", "move_right")
	Input.get_axis("move_up", "move_down")
	
	_timer_coyote_buffer.wait_time = owner.input_buffer_length
	_timer_jump_input_buffer.wait_time = owner.input_buffer_length

# Handles mostly the movement, avoid checking anything else but movement here
func _physics_process(delta) -> void:
	_handle_gravity_and_coyote(delta)
	_handle_jump()
	_handle_left_right_movement(delta)
	owner.move_and_slide()

#region Movement functions
#region Gravity & Coyote
func _handle_gravity_and_coyote(delta) -> void:
	if not owner.is_on_floor():
		
		# Reduce gravity on fall
		if owner.velocity.y > 0:
			owner.velocity.y -= gravity * delta * _fall_gravity_reduction_multiplier
		
		owner.velocity.y += gravity * delta
		if _timer_coyote_buffer.is_stopped():
			_timer_coyote_buffer.start()
	else:
		_coyote_in_buffer = true
		_timer_coyote_buffer.stop()
#endregion

#region Handlers
func _handle_jump() -> void:
	_buffer_jump_input()
	if _jump_input_in_buffer and _coyote_in_buffer:
		_jump()
#endregion

func _handle_left_right_movement(delta) -> void:
	var direction : float = Input.get_axis("move_left", "move_right")
	var accel_per_frame : float = (move_speed / acceleration_time) * delta
	if direction:
		_move(direction, accel_per_frame)
	else:
		_stop(accel_per_frame)
#endregion

#region Helper Functions
func _move(direction : float, accel_per_frame : float) -> void:
	owner.velocity.x = move_toward(
			owner.velocity.x, 
			move_speed * direction, 
			accel_per_frame
	)

func _stop(accel_per_frame : float) -> void:
	owner.velocity.x = move_toward(
			owner.velocity.x, 
			0, 
			accel_per_frame
	)

func _jump() -> void:
	_jump_input_in_buffer = false
	_coyote_in_buffer = false
	
	owner.velocity.y = -sqrt(2 * gravity/2 * abs(jump_height))
	
	_timer_jump_input_buffer.stop()

#endregion

#region Input Buffers
func _buffer_jump_input() -> void:
	if Input.is_action_just_pressed("move_jump"):
		_jump_input_in_buffer = true
		_timer_jump_input_buffer.start()


#endregion

#region Timer timeouts
func _on_coyote_timeout():
	_coyote_in_buffer = false

func _on_jump_buffer_timeout():
	_jump_input_in_buffer = false
#endregion
