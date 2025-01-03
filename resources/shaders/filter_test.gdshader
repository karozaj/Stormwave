shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D  uTexBlueNoise;
uniform float contrast = 1;
uniform float brightness = 0;
uniform float uTime1 = 1;
uniform float uTime2 = 2;
uniform float uTime3 = 4;
uniform float colors = 8;

float GetBlueNoiseDither( float grayscale, ivec2 pixelCoord, bool noise, vec2 ScreenUV )
{
    float blueNoiseValue = texture( uTexBlueNoise, vec2( ScreenUV.s, ScreenUV.t ) ).r;
    float blueNoiseValue2;
	float blueNoiseValue3;
	float blueNoiseValue4;
    if ( noise == true ) blueNoiseValue = sin( blueNoiseValue * 2.0 * 3.141592 + uTime1 ) * 0.5 + 0.5;
	if ( noise == true ) blueNoiseValue2 = sin( blueNoiseValue * 2.0 * 3.141592 + uTime2 ) * 0.5 + 0.5;
	if ( noise == true ) blueNoiseValue3 = sin( blueNoiseValue * 2.0 * 3.141592 + uTime3 ) * 0.5 + 0.5;
	if ( noise == true ) blueNoiseValue4 = 0.0;
    // Version 1
    //return blueNoiseValue < grayscale ? 1.0 : 0.0;

    // Version 2
    return (step( blueNoiseValue, grayscale ) + step( blueNoiseValue2, grayscale ) + step( blueNoiseValue3, grayscale ) + step( blueNoiseValue4, grayscale ))/4.0;
}

mat4 contrastMatrix( float _contrast ){
	float t = ( 1.0 - _contrast ) / 2.0;
    return mat4(
		vec4(_contrast, 0, 0, 0),
		vec4(0, _contrast, 0, 0),
		vec4(0, 0, _contrast, 0),
		vec4(t, t, t, 1));
}

void fragment() {
	vec4 tex = texture(screen_texture, SCREEN_UV);
	tex.r = round(tex.r*(colors))/colors;
	tex.g = round(tex.g*(colors))/colors;
	tex.b = round(tex.b*(colors))/colors;

	float ditherColorR = GetBlueNoiseDither( tex.r, ivec2( SCREEN_UV.st ), true, SCREEN_UV );
	float ditherColorG = GetBlueNoiseDither( tex.g, ivec2( SCREEN_UV.st ), true, SCREEN_UV );
	float ditherColorB = GetBlueNoiseDither( tex.b, ivec2( SCREEN_UV.st ), true, SCREEN_UV );

	COLOR.rgba = tex.rgba * (vec4(ditherColorR,ditherColorG,ditherColorB, 1.0) * contrastMatrix(contrast) + brightness);
}
void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
