extends KinematicBody

var speed = 7
const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1
onready var accel = ACCEL_DEFAULT
var gravity = 9.8
var jump = 5

var cam_accel = 40
var mouse_sense = 0.1
var snap

var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

onready var head = $Neck
onready var camera = $Neck/Camera
onready var footsteps = $Footsteps

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene("res://MainMenu.tscn")

func _process(delta):
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	if Engine.get_frames_per_second() > Engine.iterations_per_second:
		camera.set_as_toplevel(true)
		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = head.rotation.x
	else:
		camera.set_as_toplevel(false)
		camera.global_transform = head.global_transform
		
	#print(get_slide_collision())
		
func _physics_process(delta):
	#get keyboard input
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("movement_backward") - Input.get_action_strength("movement_forward")
	var h_input = Input.get_action_strength("movement_right") - Input.get_action_strength("movement_left")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	snap = -get_floor_normal()
	accel = ACCEL_DEFAULT
	gravity_vec = Vector3.ZERO
	
	footsteps.volume_db = (max(abs(f_input),abs(h_input))*20) - 40
	footsteps.pitch_scale = rand_range(.8,1.2)
	
	#make it move
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	movement = velocity + gravity_vec
	
	move_and_slide_with_snap(movement, snap, Vector3.UP)
