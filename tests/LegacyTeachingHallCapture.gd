extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scene := Node3D.new()
	root.add_child(scene)
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	var error := document.append_from_file(ProjectSettings.globalize_path("res://references/legacy-gta-20261011/teaching-a-hall-preview.glb"), state)
	if error != OK:
		push_error("Legacy reference import failed: %s" % error)
		quit(1)
		return
	var model := document.generate_scene(state)
	scene.add_child(model)
	var clay := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = "shader_type spatial; render_mode cull_disabled; varying vec3 p; void vertex(){p=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;} void fragment(){if(p.y>3.8)discard;ALBEDO=vec3(0.42,0.46,0.49);ROUGHNESS=0.94;}"
	clay.shader = shader
	for child in model.find_children("*", "MeshInstance3D", true, false):
		child.material_override = clay
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("d4dbe0")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color.WHITE
	env.ambient_light_energy = 0.32
	environment.environment = env
	scene.add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -30, 0)
	sun.light_energy = 0.7
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 6000
	scene.add_child(sun)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.far = 10000
	scene.add_child(camera)
	camera.make_current()
	var shots := [
        ["hall-overview", Vector3(45, 55, 62), Vector3(0, 1, 0), 70.0],
        ["hall-plan", Vector3(0, 90, 0.1), Vector3.ZERO, 65.0],
        ["hall-inside", Vector3(24, 3, 20), Vector3(0, 2, -8), 35.0],
    ]
	for shot in shots:
		camera.projection = Camera3D.PROJECTION_PERSPECTIVE if shot[0]=="hall-inside" else Camera3D.PROJECTION_ORTHOGONAL
		camera.fov = 65
		camera.position = shot[1]
		camera.look_at(shot[2])
		camera.size = shot[3]
		for i in range(5):
			await process_frame
		await RenderingServer.frame_post_draw
		var path := "res://references/legacy-gta-20261011/legacy-%s-cutaway.png" % shot[0]
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
		print("CAPTURED ", path)
	quit(0)
