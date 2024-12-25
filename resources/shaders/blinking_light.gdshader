shader_type spatial;
render_mode unshaded;


void fragment() {
	ALBEDO=vec3(abs(sin(TIME*2.0)),0,0);
	ALPHA=abs(sin(TIME*2.0));
}
