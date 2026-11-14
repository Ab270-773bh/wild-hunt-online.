extends Node3D

const PlayerScript = preload("res://scripts/player.gd")

func _ready() -> void:
    _make_environment()
    _make_ground()
    _make_forest()
    _make_deer(Vector3(0, 0, -18))
    _make_deer(Vector3(12, 0, -28))
    var player = CharacterBody3D.new()
    player.name = "Player"
    player.set_script(PlayerScript)
    add_child(player)
    player.position = Vector3(0, 0.2, 5)
    _make_hud()

func _make_environment() -> void:
    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.sky.sky_material = ProceduralSkyMaterial.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.68, 0.75, 0.82)
    env.ambient_light_energy = 0.7
    world_env.environment = env
    add_child(world_env)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -32, 0)
    sun.light_energy = 1.15
    sun.shadow_enabled = true
    add_child(sun)

func _mat(color: Color, roughness := 1.0) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = roughness
    return m

func _make_ground() -> void:
    var ground := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(180, 180)
    ground.mesh = plane
    ground.material_override = _mat(Color(0.20, 0.34, 0.16))
    ground.position.y = -0.08
    add_child(ground)
    var body := StaticBody3D.new()
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(180, 0.2, 180)
    shape.shape = box
    body.add_child(shape)
    body.position.y = -0.18
    add_child(body)

func _make_forest() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 2481
    for i in range(95):
        var x := rng.randf_range(-65, 65)
        var z := rng.randf_range(-65, 65)
        if Vector2(x, z).length() < 9.0:
            continue
        _make_tree(Vector3(x, 0, z), rng.randf_range(0.75, 1.45))

func _make_tree(pos: Vector3, scale_factor: float) -> void:
    var tree := Node3D.new()
    tree.position = pos
    tree.scale = Vector3.ONE * scale_factor
    add_child(tree)
    var trunk := MeshInstance3D.new()
    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.top_radius = 0.22
    trunk_mesh.bottom_radius = 0.34
    trunk_mesh.height = 3.2
    trunk.mesh = trunk_mesh
    trunk.material_override = _mat(Color(0.25, 0.15, 0.08))
    trunk.position.y = 1.6
    tree.add_child(trunk)
    for j in range(3):
        var crown := MeshInstance3D.new()
        var cone := ConeMesh.new()
        cone.radius = 2.0 - j * 0.28
        cone.height = 3.0
        crown.mesh = cone
        crown.material_override = _mat(Color(0.08 + j * 0.015, 0.25 + j * 0.025, 0.10))
        crown.position.y = 3.0 + j * 1.25
        tree.add_child(crown)

func _make_deer(pos: Vector3) -> void:
    var deer := Node3D.new()
    deer.position = pos
    add_child(deer)
    var brown := _mat(Color(0.48, 0.27, 0.12))
    var body := MeshInstance3D.new()
    var body_mesh := CapsuleMesh.new()
    body_mesh.radius = 0.48
    body_mesh.height = 1.65
    body.mesh = body_mesh
    body.material_override = brown
    body.rotation_degrees.z = 90
    body.position.y = 1.15
    deer.add_child(body)
    var head := MeshInstance3D.new()
    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.28
    head.mesh = head_mesh
    head.material_override = brown
    head.position = Vector3(0, 1.75, -0.68)
    deer.add_child(head)
    for x in [-0.23, 0.23]:
        var leg := MeshInstance3D.new()
        var leg_mesh := CylinderMesh.new()
        leg_mesh.top_radius = 0.07
        leg_mesh.bottom_radius = 0.09
        leg_mesh.height = 0.85
        leg.mesh = leg_mesh
        leg.material_override = brown
        leg.position = Vector3(x, 0.48, -0.1)
        deer.add_child(leg)

func _make_hud() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var title := Label.new()
    title.text = "WILD HUNT ONLINE  |  HUNT COINS: 0"
    title.position = Vector2(24, 18)
    title.add_theme_font_size_override("font_size", 24)
    title.add_theme_color_override("font_color", Color.WHITE)
    layer.add_child(title)
    var hint := Label.new()
    hint.text = "اسحب يسار الشاشة للحركة، واسحب يمينها لتحريك الكاميرا"
    hint.position = Vector2(24, 58)
    hint.add_theme_font_size_override("font_size", 18)
    hint.add_theme_color_override("font_color", Color.WHITE)
    layer.add_child(hint)
    var view_button := Button.new()
    view_button.text = "تبديل المنظور"
    view_button.position = Vector2(1040, 24)
    view_button.size = Vector2(190, 58)
    view_button.pressed.connect(func(): get_node("Player").toggle_view())
    layer.add_child(view_button)
    var jump_button := Button.new()
    jump_button.text = "قفز"
    jump_button.position = Vector2(1080, 610)
    jump_button.size = Vector2(130, 70)
    jump_button.pressed.connect(func(): get_node("Player").request_jump())
    layer.add_child(jump_button)
