extends Node

@onready var _timer_dash_duration : Timer = $DashTimer
@onready var _timer_dash_input_buffer : Timer = $DashBuffer
@onready var _movement_component : Node

var _dash_input_in_buffer : bool = false

var _can_dash : bool = true
var dashing : bool = false
var _dash_direction : Vector2

@export var dash_duration : float = 0.0
@export var dash_length : int = 0

func _ready():
	# Check for presence of required inputs
	Input.get_axis("move_left", "move_right")
	Input.get_axis("move_up", "move_down")
	Input.get_axis("move_dash", "move_dash")
	
	_timer_dash_duration.wait_time = dash_duration
	_timer_dash_input_buffer.wait_time = owner.input_buffer_length

func _process(delta):
	_handle_dash()

func _physics_process(_delta):
	if owner.is_on_floor():
		_can_dash = true

func _get_dash_dir() -> void:
	var x_dir = Input.get_axis("move_left", "move_right")
	var y_dir = Input.get_axis("move_up", "move_down")
	_dash_direction = Vector2(x_dir, y_dir).normalized()
	if _dash_direction.is_equal_approx(Vector2.ZERO):
		_dash_direction = Vector2.UP

func _start_dash() -> void:
	_get_dash_dir()

	dashing = true
	_can_dash = false
	_timer_dash_duration.start()

func _handle_dash() -> void:
	_buffer_dash_input()
	if _can_dash and _dash_input_in_buffer:
		_start_dash()
	if dashing:
		owner.velocity = _dash_direction * (dash_length / _timer_dash_duration.wait_time)
		
func _buffer_dash_input() -> void:
	if Input.is_action_just_pressed("move_dash"):
		_dash_input_in_buffer = true
		_timer_dash_input_buffer.start()

func _on_dash_timer_timeout():
	dashing = false
	# TODO: Handle how dash will be finished

func _on_dash_buffer_timeout():
	_dash_input_in_buffer = false
