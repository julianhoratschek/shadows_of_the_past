shader_type canvas_item;

uniform float a: hint_range(0.0, 1.0);
uniform float phi;
uniform vec2 rect_center;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float x_dist = UV.x - rect_center.x;
	float y_dist = UV.y - rect_center.y;
	float tx_abs = abs(cos(phi) * x_dist - sin(phi) * y_dist);
	float ty_abs = abs(sin(phi) * x_dist + cos(phi) * y_dist);
	if (tx_abs < abs(a) && ty_abs < abs(a)) {
		COLOR.a = 0.0;
	}
	else
		COLOR.a = 1.0;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
