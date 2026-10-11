shader_type spatial;
render_mode diffuse_burley;
uniform vec4 base_color : source_color = vec4(0.7, 0.7, 0.65, 1.0);
uniform int surface_kind = 0;
uniform vec2 tile_size = vec2(0.8, 0.4);
uniform float joint_width = 0.012;
uniform float variation = 0.08;
varying vec3 world_point;
varying vec3 world_normal;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453); }
float noise(vec2 p) {
    vec2 cell=floor(p), f=fract(p); f=f*f*(3.0-2.0*f);
    return mix(mix(hash(cell),hash(cell+vec2(1,0)),f.x),mix(hash(cell+vec2(0,1)),hash(cell+vec2(1,1)),f.x),f.y);
}
void vertex() {
    world_point=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
    world_normal=normalize((MODEL_MATRIX*vec4(NORMAL,0.0)).xyz);
}
void fragment() {
    vec3 n=abs(world_normal);
    vec2 p=n.y>0.7 ? world_point.xz : (n.x>n.z ? world_point.zy : world_point.xy);
    vec3 color=base_color.rgb;
    ROUGHNESS=0.86;
    if (surface_kind==0 || surface_kind==1) {
        vec2 q=p/tile_size;
        if (surface_kind==1) q.x+=mod(floor(q.y),2.0)*0.5;
        vec2 edge=min(fract(q),1.0-fract(q))*tile_size;
        float width=min(edge.x,edge.y);
        float aa=max(fwidth(width),0.001);
        float joint=1.0-smoothstep(joint_width-aa,joint_width+aa,width);
        color*=1.0+(hash(floor(q))-.5)*variation;
        color=mix(color,color*0.60,joint*0.60);
        color*=0.98+noise(p*12.0)*0.04;
    } else if (surface_kind==2) {
        color*=0.91+noise(p*18.0)*0.18;
        ROUGHNESS=0.95;
    } else if (surface_kind==3) {
        color*=0.82+noise(p*.16)*0.20+noise(p*2.5)*0.06;
        ROUGHNESS=1.0;
    } else if (surface_kind==4) {
        color=mix(color*0.65,color*1.1,noise(vec2(p.x*14.0,p.y*.45)));
        ROUGHNESS=0.7;
    } else if (surface_kind==5) {
        float warm=step(0.84,hash(floor(p/vec2(3.6,3.4))));
        color=mix(color,vec3(.59,.50,.34),warm*.35);
        color*=0.78+0.22*clamp(world_point.y/55.0,0.0,1.0);
        ROUGHNESS=0.24; METALLIC=0.25; SPECULAR=0.65;
    }
    ALBEDO=color;
}
