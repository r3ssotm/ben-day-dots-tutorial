extends CharacterBody3D

const SPEED := 5.0
const JUMP_VELOCITY := 4.5

const LOOK_SENSITIVITY := 0.005
@onready var camera: Camera3D = $Camera3D
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	# Rotate with mouse.
	rotate(Vector3.UP, -_mouse_delta.x * LOOK_SENSITIVITY)
	camera.rotation.x = clamp(camera.rotation.x - _mouse_delta.y * LOOK_SENSITIVITY, -PI/2, PI/2)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	
	
	


var _mouse_delta := Vector2.ZERO
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_mouse_delta = event.relative
	
	
	if Input.is_action_just_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_VISIBLE
	
	
	await get_tree().process_frame
	_mouse_delta = Vector2.ZERO
