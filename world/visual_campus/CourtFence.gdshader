shader_type spatial;
render_mode cull_disabled, depth_prepass_alpha;
uniform vec2 dimensions;
void fragment() {
    vec2 p=UV*dimensions;
    float span=max(length(dFdx(p)),length(dFdy(p)));
    float a=abs(fract((p.x+p.y)/.12)-.5);
    float b=abs(fract((p.x-p.y)/.12)-.5);
    float wire=1.-smoothstep(.025,.025+max(span/.12,.005),min(a,b));
    // Subpixel wires converge to coverage instead of flickering into a moire wall.
    ALPHA=mix(wire,.075,smoothstep(.008,.07,span));
    ALBEDO=vec3(.075,.16,.115);
    ROUGHNESS=.88;
}
