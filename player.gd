extends CharacterBody3D

const SPEED := 6.0
const JUMP_VELOCITY := 4.5
var gravity := 18.0
var yaw := 0.0
var pitch := -0.12
var first_person := false
var move_touch := Vector2.ZERO
var look_touch := Vector2.ZERO
var jump_requested := false
var touch_roles := {}

var camera: Camera3D
var camera_pivot: Node3D

func _ready() -> void:
    _build_player()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _build_player() -> void:
    var capsule := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.42
    shape.height = 1.8
    capsule.shape = shape
    capsule.position.y = 0.9
    add_child(capsule)

    var torso := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.4
    mesh.height = 1.75
    torso.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.18, 0.24, 0.15)
    torso.material_override = material
    torso.position.y = 0.9
    add_child(torso)

    camera_pivot = Node3D.new()
    camera_pivot.position.y = 1.55
    add_child(camera_pivot)
    camera = Camera3D.new()
    camera.position = Vector3(0, 0.45, 4.5)
    camera.current = true
    camera_pivot.add_child(camera)
    _update_camera()

func _physics_process(delta: float) -> void:
    var input_vec := Vector2.ZERO
    input_vec.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    input_vec.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    if move_touch.length() > 0.12:
        input_vec = move_touch
    input_vec = input_vec.limit_length(1.0)

    var direction := (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
    if direction.length() > 0.01:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED * 5 * delta)
        velocity.z = move_toward(velocity.z, 0, SPEED * 5 * delta)

    if not is_on_floor():
        velocity.y -= gravity * delta
    elif jump_requested or Input.is_action_just_pressed("ui_accept"):
        velocity.y = JUMP_VELOCITY
    jump_requested = false
    move_and_slide()

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            if event.position.x < get_viewport().size.x * 0.5:
                touch_roles[event.index] = "move"
            else:
                touch_roles[event.index] = "look"
        else:
            touch_roles.erase(event.index)
            if touch_roles.values().has("move"):
                move_touch = Vector2.ZERO
            if touch_roles.values().has("look"):
                look_touch = Vector2.ZERO
    elif event is InputEventScreenDrag:
        var role = touch_roles.get(event.index, "")
        if role == "move":
            var center := Vector2(get_viewport().size.x * 0.22, get_viewport().size.y * 0.78)
            move_touch = ((event.position - center) / 105.0).limit_length(1.0)
        elif role == "look":
            yaw -= event.relative.x * 0.004
            pitch = clamp(pitch - event.relative.y * 0.003, -0.75, 0.45)
            _update_camera()
    elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        yaw -= event.relative.x * 0.002
        pitch = clamp(pitch - event.relative.y * 0.002, -0.75, 0.45)
        _update_camera()

func _update_camera() -> void:
    rotation.y = yaw
    if camera_pivot:
        camera_pivot.rotation.x = pitch
        if first_person:
            camera.position = Vector3(0, 0.12, 0.12)
        else:
            camera.position = Vector3(0, 0.45, 4.5)

func toggle_view() -> void:
    first_person = not first_person
    _update_camera()

func request_jump() -> void:
    jump_requested = true
