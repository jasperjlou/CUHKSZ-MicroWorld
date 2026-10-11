shader_type spatial;
render_mode cull_disabled, diffuse_burley;
varying vec4 leaf_tint;
void vertex() { leaf_tint=COLOR; }
void fragment() {
    if (!FRONT_FACING) NORMAL=-NORMAL;
    float midrib=1.0-smoothstep(.012,.035,abs(UV.x-.5));
    ALBEDO=leaf_tint.rgb*(.97+midrib*.07);
    ROUGHNESS=.94;SPECULAR=.10;
    BACKLIGHT=leaf_tint.rgb*.12;
}
