shader_type spatial;
render_mode diffuse_burley;
varying vec3 world_point;

void vertex() {
    world_point=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
}

void fragment() {
    // Gentle crossed waves change reflection direction, not the colour in periodic stripes.
    // Use world normals directly: the authored pond mesh has no tangent/UV normal-map basis.
    vec2 p=world_point.xz-vec2(38.0,-290.0);
    float a=dot(p,vec2(.81,.59))*2.1+TIME*.32;
    float b=dot(p,vec2(-.44,.90))*3.7-TIME*.24;
    float c=dot(p,vec2(.96,-.28))*.73+TIME*.16;
    vec2 slope=vec2(.81,.59)*cos(a)*.009+vec2(-.44,.90)*cos(b)*.005+vec2(.96,-.28)*cos(c)*.007;
    NORMAL=normalize((VIEW_MATRIX*vec4(normalize(vec3(-slope.x,1.0,-slope.y)),0.0)).xyz);
    // Opaque deep-water response; the physical basin and waterline remain unchanged.
    ALBEDO=vec3(.018,.042,.038);
    METALLIC=0.0;
    ROUGHNESS=.13;
    SPECULAR=.5;
}
