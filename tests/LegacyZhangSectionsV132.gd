extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
	var scene:=Node3D.new();root.add_child(scene)
	var document:=GLTFDocument.new();var state:=GLTFState.new()
	if document.append_from_file(ProjectSettings.globalize_path("res://references/legacy-gta-20261011/lower-campus-reference.glb"),state)!=OK:quit(1);return
	var model:=document.generate_scene(state);scene.add_child(model)
	var shader:=Shader.new()
	# Unlit derivative normals avoid both missing imported normals and cast shadows
	# from clipped upper geometry. Height clipping does not cap the cut surfaces.
	shader.code="shader_type spatial; render_mode unshaded,cull_disabled; uniform float cut_height=23.5; varying vec3 p; void vertex(){p=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;} void fragment(){if(p.y>cut_height)discard;vec3 n=normalize(cross(dFdx(p),dFdy(p)));float shade=0.42+0.38*abs(dot(n,normalize(vec3(0.3,0.85,0.4))));float h=clamp((p.y-12.0)/60.0,0.0,1.0);ALBEDO=mix(vec3(0.27,0.35,0.39),vec3(0.88,0.85,0.74),h)*shade;}"
	var clay:=ShaderMaterial.new();clay.shader=shader
	for mesh in model.find_children("*","MeshInstance3D",true,false):
		mesh.material_override=clay
		mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var we:=WorldEnvironment.new();var e:=Environment.new();e.background_mode=Environment.BG_COLOR;e.background_color=Color("d4dbe0");e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;e.ambient_light_energy=.5;we.environment=e;scene.add_child(we)
	var sun:=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-55,-20,0);sun.light_energy=.6;sun.shadow_enabled=true;sun.directional_shadow_max_distance=6000;scene.add_child(sun)
	var camera:=Camera3D.new();scene.add_child(camera);camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.far=10000;camera.make_current()
	for shot:Array in [["lower",23.5,Vector3(-305,1000,-130),Vector3(-305,0,-200),240.0],["first",34.5,Vector3(-305,1000,-130),Vector3(-305,0,-200),240.0],["roof",100.0,Vector3(-305,1000,-130),Vector3(-305,0,-200),240.0],["lower-oblique",23.5,Vector3(-185,200,-45),Vector3(-305,18,-200),240.0]]:
		clay.set_shader_parameter("cut_height",shot[1]);camera.position=shot[2];camera.look_at(shot[3]);camera.size=shot[4]
		for i in 6:await process_frame
		await RenderingServer.frame_post_draw
		var p:="res://references/legacy-gta-20261011/legacy-zhang-"+str(shot[0])+"-v132.png"
		if root.get_texture().get_image().save_png(ProjectSettings.globalize_path(p))!=OK:quit(1);return
		print("REFERENCE_CAPTURE ",p," cut=",shot[1])
	quit(0)
