shader_type spatial;
render_mode unshaded;

instance uniform float alpha=0.0;
instance uniform vec3 color=vec3(2,0,0);

void fragment() {
	ALBEDO=color;
	ALPHA=alpha;
}
