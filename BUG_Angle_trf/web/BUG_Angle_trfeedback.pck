GDPC                                                                                @   res://.import/gradient.jpg-32594b13ed3addf92ad8c15ba2ccd54f.stex�A      �B      ]M�p�_A�j=�.i<   res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex �      �      �p��<f��r�g��.�   res://Node2D.tscn   �      L>      �����c�lu�Χַ�   res://default_env.tres  �@      �       um�`�N��<*ỳ�8   res://gradient.jpg.import   p�      �      3{X7�"�%������   res://icon.png   �      i      ����󈘥Ey��
�   res://icon.png.import   ��      �      �����%��(#AB�   res://project.binary��      Y      :
��Z�
v�F�o���        [gd_scene load_steps=8 format=2]

[ext_resource path="res://gradient.jpg" type="Texture" id=1]
[ext_resource path="res://icon.png" type="Texture" id=2]

[sub_resource type="Shader" id=1]
code = "shader_type particles;
uniform float spread;
uniform float flatness;
uniform float initial_linear_velocity;
uniform float initial_angle;
uniform float angular_velocity;
uniform float orbit_velocity;
uniform float linear_accel;
uniform float radial_accel;
uniform float tangent_accel;
uniform float damping;
uniform float scale;
uniform float hue_variation;
uniform float anim_speed;
uniform float anim_offset;
uniform float initial_linear_velocity_random;
uniform float initial_angle_random;
uniform float angular_velocity_random;
uniform float orbit_velocity_random;
uniform float linear_accel_random;
uniform float radial_accel_random;
uniform float tangent_accel_random;
uniform float damping_random;
uniform float scale_random;
uniform float hue_variation_random;
uniform float anim_speed_random;
uniform float anim_offset_random;
uniform vec4 color_value : hint_color;
uniform int trail_divisor;
uniform vec3 gravity;
uniform sampler2D color_ramp;


float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0)
	s = 305420679;
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0)
		s += 2147483647;
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

float rand_from_seed_m1_p1(inout uint seed) {
	return rand_from_seed(seed) * 2.0 - 1.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

void vertex() {
	uint base_number = NUMBER / uint(trail_divisor);
	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);
	float angle_rand = rand_from_seed(alt_seed);
	float scale_rand = rand_from_seed(alt_seed);
	float hue_rot_rand = rand_from_seed(alt_seed);
	float anim_offset_rand = rand_from_seed(alt_seed);
	float pi = 3.14159;
	float degree_to_rad = pi / 180.0;

	if (RESTART) {
		float tex_linear_velocity = 0.0;
		float tex_angle = 0.0;
		float tex_anim_offset = 0.0;
		float spread_rad = spread * degree_to_rad;
		float angle1_rad = rand_from_seed_m1_p1(alt_seed) * spread_rad;
		vec3 rot = vec3(cos(angle1_rad), sin(angle1_rad), 0.0);
		VELOCITY = rot * initial_linear_velocity * mix(1.0, rand_from_seed(alt_seed), initial_linear_velocity_random);
		float base_angle = (initial_angle + tex_angle) * mix(1.0, angle_rand, initial_angle_random);
		CUSTOM.x = base_angle * degree_to_rad;
		CUSTOM.y = 0.0;
		CUSTOM.z = (anim_offset + tex_anim_offset) * mix(1.0, anim_offset_rand, anim_offset_random);
		VELOCITY = (EMISSION_TRANSFORM * vec4(VELOCITY, 0.0)).xyz;
		TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
		VELOCITY.z = 0.0;
		TRANSFORM[3].z = 0.0;
	} else {
		CUSTOM.y += DELTA / LIFETIME;
		float tex_linear_velocity = 0.0;
		float tex_orbit_velocity = 0.0;
		float tex_angular_velocity = 0.0;
		float tex_linear_accel = 0.0;
		float tex_radial_accel = 0.0;
		float tex_tangent_accel = 0.0;
		float tex_damping = 0.0;
		float tex_angle = 0.0;
		float tex_anim_speed = 0.0;
		float tex_anim_offset = 0.0;
		vec3 force = gravity;
		vec3 pos = TRANSFORM[3].xyz;
		pos.z = 0.0;
		// apply linear acceleration
		force += length(VELOCITY) > 0.0 ? normalize(VELOCITY) * (linear_accel + tex_linear_accel) * mix(1.0, rand_from_seed(alt_seed), linear_accel_random) : vec3(0.0);
		// apply radial acceleration
		vec3 org = EMISSION_TRANSFORM[3].xyz;
		vec3 diff = pos - org;
		force += length(diff) > 0.0 ? normalize(diff) * (radial_accel + tex_radial_accel) * mix(1.0, rand_from_seed(alt_seed), radial_accel_random) : vec3(0.0);
		// apply tangential acceleration;
		force += length(diff.yx) > 0.0 ? vec3(normalize(diff.yx * vec2(-1.0, 1.0)), 0.0) * ((tangent_accel + tex_tangent_accel) * mix(1.0, rand_from_seed(alt_seed), tangent_accel_random)) : vec3(0.0);
		// apply attractor forces
		VELOCITY += force * DELTA;
		// orbit velocity
		float orbit_amount = (orbit_velocity + tex_orbit_velocity) * mix(1.0, rand_from_seed(alt_seed), orbit_velocity_random);
		if (orbit_amount != 0.0) {
		     float ang = orbit_amount * DELTA * pi * 2.0;
		     mat2 rot = mat2(vec2(cos(ang), -sin(ang)), vec2(sin(ang), cos(ang)));
		     TRANSFORM[3].xy -= diff.xy;
		     TRANSFORM[3].xy += rot * diff.xy;
		}
		if (damping + tex_damping > 0.0) {
			float v = length(VELOCITY);
			float damp = (damping + tex_damping) * mix(1.0, rand_from_seed(alt_seed), damping_random);
			v -= damp * DELTA;
			if (v < 0.0) {
				VELOCITY = vec3(0.0);
			} else {
				VELOCITY = normalize(VELOCITY) * v;
			}
		}
		float base_angle = (initial_angle + tex_angle) * mix(1.0, angle_rand, initial_angle_random);
		base_angle += CUSTOM.y * LIFETIME * (angular_velocity + tex_angular_velocity) * mix(1.0, rand_from_seed(alt_seed) * 2.0 - 1.0, angular_velocity_random);
		CUSTOM.x = base_angle * degree_to_rad;
		CUSTOM.z = (anim_offset + tex_anim_offset) * mix(1.0, anim_offset_rand, anim_offset_random) + CUSTOM.y * (anim_speed + tex_anim_speed) * mix(1.0, rand_from_seed(alt_seed), anim_speed_random);
	}
	float tex_scale = 1.0;
	float tex_hue_variation = 0.0;
	float hue_rot_angle = (hue_variation + tex_hue_variation) * pi * 2.0 * mix(1.0, hue_rot_rand * 2.0 - 1.0, hue_variation_random);
	float hue_rot_c = cos(hue_rot_angle);
	float hue_rot_s = sin(hue_rot_angle);
	mat4 hue_rot_mat = mat4(vec4(0.299, 0.587, 0.114, 0.0),
			vec4(0.299, 0.587, 0.114, 0.0),
			vec4(0.299, 0.587, 0.114, 0.0),
			vec4(0.000, 0.000, 0.000, 1.0)) +
		mat4(vec4(0.701, -0.587, -0.114, 0.0),
			vec4(-0.299, 0.413, -0.114, 0.0),
			vec4(-0.300, -0.588, 0.886, 0.0),
			vec4(0.000, 0.000, 0.000, 0.0)) * hue_rot_c +
		mat4(vec4(0.168, 0.330, -0.497, 0.0),
			vec4(-0.328, 0.035,  0.292, 0.0),
			vec4(1.250, -1.050, -0.203, 0.0),
			vec4(0.000, 0.000, 0.000, 0.0)) * hue_rot_s;
	COLOR = hue_rot_mat * textureLod(color_ramp, vec2(CUSTOM.y, 0.0), 0.0);

	TRANSFORM[0] = vec4(cos(CUSTOM.x), -sin(CUSTOM.x), 0.0, 0.0);
	TRANSFORM[1] = vec4(sin(CUSTOM.x), cos(CUSTOM.x), 0.0, 0.0);
	TRANSFORM[2] = vec4(0.0, 0.0, 1.0, 0.0);
	float base_scale = mix(scale * tex_scale, 1.0, scale_random * scale_rand);
	if (base_scale == 0.0) {
		base_scale = 0.000001;
	}
	TRANSFORM[0].xyz *= base_scale;
	TRANSFORM[1].xyz *= base_scale;
	TRANSFORM[2].xyz *= base_scale;
	VELOCITY.z = 0.0;
	TRANSFORM[3].z = 0.0;
}

"

[sub_resource type="ShaderMaterial" id=2]
shader = SubResource( 1 )
shader_param/spread = 45.0
shader_param/flatness = 0.0
shader_param/initial_linear_velocity = 0.0
shader_param/initial_angle = 0.0
shader_param/angular_velocity = null
shader_param/orbit_velocity = 0.0
shader_param/linear_accel = 0.0
shader_param/radial_accel = 0.0
shader_param/tangent_accel = 0.0
shader_param/damping = 0.0
shader_param/scale = 1.0
shader_param/hue_variation = 0.0
shader_param/anim_speed = 0.0
shader_param/anim_offset = 0.0
shader_param/initial_linear_velocity_random = 0.0
shader_param/initial_angle_random = 0.0
shader_param/angular_velocity_random = 0.0
shader_param/orbit_velocity_random = 0.0
shader_param/linear_accel_random = 0.0
shader_param/radial_accel_random = 0.0
shader_param/tangent_accel_random = 0.0
shader_param/damping_random = 0.0
shader_param/scale_random = 0.0
shader_param/hue_variation_random = 0.0
shader_param/anim_speed_random = 0.0
shader_param/anim_offset_random = 0.0
shader_param/color_value = Color( 1, 1, 1, 1 )
shader_param/trail_divisor = 1
shader_param/gravity = Vector3( 0, 98, 0 )
shader_param/color_ramp = ExtResource( 1 )

[sub_resource type="Shader" id=3]
code = "shader_type particles;
uniform float spread;
uniform float flatness;
uniform float initial_linear_velocity;
uniform float initial_angle;
uniform float angular_velocity;
uniform float orbit_velocity;
uniform float linear_accel;
uniform float radial_accel;
uniform float tangent_accel;
uniform float damping;
uniform float scale;
uniform float hue_variation;
uniform float anim_speed;
uniform float anim_offset;
uniform float initial_linear_velocity_random;
uniform float initial_angle_random;
uniform float angular_velocity_random;
uniform float orbit_velocity_random;
uniform float linear_accel_random;
uniform float radial_accel_random;
uniform float tangent_accel_random;
uniform float damping_random;
uniform float scale_random;
uniform float hue_variation_random;
uniform float anim_speed_random;
uniform float anim_offset_random;
uniform vec4 color_value : hint_color;
uniform int trail_divisor;
uniform vec3 gravity;
uniform sampler2D color_ramp;
uniform sampler2D test;


float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0)
	s = 305420679;
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0)
		s += 2147483647;
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

float rand_from_seed_m1_p1(inout uint seed) {
	return rand_from_seed(seed) * 2.0 - 1.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

void vertex() {
	uint base_number = NUMBER / uint(trail_divisor);
	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);
	float angle_rand = rand_from_seed(alt_seed);
	float scale_rand = rand_from_seed(alt_seed);
	float hue_rot_rand = rand_from_seed(alt_seed);
	float anim_offset_rand = rand_from_seed(alt_seed);
	float pi = 3.14159;
	float degree_to_rad = pi / 180.0;

	if (RESTART) {
		float tex_linear_velocity = 0.0;
		float tex_angle = 0.0;
		float tex_anim_offset = 0.0;
		float spread_rad = spread * degree_to_rad;
		float angle1_rad = rand_from_seed_m1_p1(alt_seed) * spread_rad;
		vec3 rot = vec3(cos(angle1_rad), sin(angle1_rad), 0.0);
		VELOCITY = rot * initial_linear_velocity * mix(1.0, rand_from_seed(alt_seed), initial_linear_velocity_random);
		float base_angle = (initial_angle + tex_angle) * mix(1.0, angle_rand, initial_angle_random);
		CUSTOM.x = base_angle * degree_to_rad;
		CUSTOM.y = 0.0;
		CUSTOM.z = (anim_offset + tex_anim_offset) * mix(1.0, anim_offset_rand, anim_offset_random);
		VELOCITY = (EMISSION_TRANSFORM * vec4(VELOCITY, 0.0)).xyz;
		TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
		VELOCITY.z = 0.0;
		TRANSFORM[3].z = 0.0;
	} else {
		CUSTOM.y += DELTA / LIFETIME;
		float tex_linear_velocity = 0.0;
		float tex_orbit_velocity = 0.0;
		float tex_angular_velocity = 0.0;
		float tex_linear_accel = 0.0;
		float tex_radial_accel = 0.0;
		float tex_tangent_accel = 0.0;
		float tex_damping = 0.0;
		float tex_angle = 0.0;
		float tex_anim_speed = 0.0;
		float tex_anim_offset = 0.0;
		vec3 force = gravity;
		vec3 pos = TRANSFORM[3].xyz;
		pos.z = 0.0;
		// apply linear acceleration
		force += length(VELOCITY) > 0.0 ? normalize(VELOCITY) * (linear_accel + tex_linear_accel) * mix(1.0, rand_from_seed(alt_seed), linear_accel_random) : vec3(0.0);
		// apply radial acceleration
		vec3 org = EMISSION_TRANSFORM[3].xyz;
		vec3 diff = pos - org;
		force += length(diff) > 0.0 ? normalize(diff) * (radial_accel + tex_radial_accel) * mix(1.0, rand_from_seed(alt_seed), radial_accel_random) : vec3(0.0);
		// apply tangential acceleration;
		force += length(diff.yx) > 0.0 ? vec3(normalize(diff.yx * vec2(-1.0, 1.0)), 0.0) * ((tangent_accel + tex_tangent_accel) * mix(1.0, rand_from_seed(alt_seed), tangent_accel_random)) : vec3(0.0);
		// apply attractor forces
		VELOCITY += force * DELTA;
		// orbit velocity
		float orbit_amount = (orbit_velocity + tex_orbit_velocity) * mix(1.0, rand_from_seed(alt_seed), orbit_velocity_random);
		if (orbit_amount != 0.0) {
		     float ang = orbit_amount * DELTA * pi * 2.0;
		     mat2 rot = mat2(vec2(cos(ang), -sin(ang)), vec2(sin(ang), cos(ang)));
		     TRANSFORM[3].xy -= diff.xy;
		     TRANSFORM[3].xy += rot * diff.xy;
		}
		if (damping + tex_damping > 0.0) {
			float v = length(VELOCITY);
			float damp = (damping + tex_damping) * mix(1.0, rand_from_seed(alt_seed), damping_random);
			v -= damp * DELTA;
			if (v < 0.0) {
				VELOCITY = vec3(0.0);
			} else {
				VELOCITY = normalize(VELOCITY) * v;
			}
		}
		float base_angle = (initial_angle + tex_angle) * mix(1.0, angle_rand, initial_angle_random);
		base_angle += CUSTOM.y * LIFETIME * (angular_velocity + tex_angular_velocity) * mix(1.0, rand_from_seed(alt_seed) * 2.0 - 1.0, angular_velocity_random);
		CUSTOM.x = base_angle * degree_to_rad;
		CUSTOM.z = (anim_offset + tex_anim_offset) * mix(1.0, anim_offset_rand, anim_offset_random) + CUSTOM.y * (anim_speed + tex_anim_speed) * mix(1.0, rand_from_seed(alt_seed), anim_speed_random);
	}
	float tex_scale = 1.0;
	float tex_hue_variation = 0.0;
	float hue_rot_angle = (hue_variation + tex_hue_variation) * pi * 2.0 * mix(1.0, hue_rot_rand * 2.0 - 1.0, hue_variation_random);
	float hue_rot_c = cos(hue_rot_angle);
	float hue_rot_s = sin(hue_rot_angle);
	mat4 hue_rot_mat = mat4(vec4(0.299, 0.587, 0.114, 0.0),
			vec4(0.299, 0.587, 0.114, 0.0),
			vec4(0.299, 0.587, 0.114, 0.0),
			vec4(0.000, 0.000, 0.000, 1.0)) +
		mat4(vec4(0.701, -0.587, -0.114, 0.0),
			vec4(-0.299, 0.413, -0.114, 0.0),
			vec4(-0.300, -0.588, 0.886, 0.0),
			vec4(0.000, 0.000, 0.000, 0.0)) * hue_rot_c +
		mat4(vec4(0.168, 0.330, -0.497, 0.0),
			vec4(-0.328, 0.035,  0.292, 0.0),
			vec4(1.250, -1.050, -0.203, 0.0),
			vec4(0.000, 0.000, 0.000, 0.0)) * hue_rot_s;
	COLOR = hue_rot_mat * textureLod(color_ramp, vec2(CUSTOM.y, 0.0), 0.0);
	COLOR = hue_rot_mat * textureLod(test, vec2(CUSTOM.y, 0.0), 0.0);

	TRANSFORM[0] = vec4(cos(CUSTOM.x), -sin(CUSTOM.x), 0.0, 0.0);
	TRANSFORM[1] = vec4(sin(CUSTOM.x), cos(CUSTOM.x), 0.0, 0.0);
	TRANSFORM[2] = vec4(0.0, 0.0, 1.0, 0.0);
	float base_scale = mix(scale * tex_scale, 1.0, scale_random * scale_rand);
	if (base_scale == 0.0) {
		base_scale = 0.000001;
	}
	TRANSFORM[0].xyz *= base_scale;
	TRANSFORM[1].xyz *= base_scale;
	TRANSFORM[2].xyz *= base_scale;
	VELOCITY.z = 0.0;
	TRANSFORM[3].z = 0.0;
}

"

[sub_resource type="ViewportTexture" id=4]
viewport_path = NodePath("Viewport")

[sub_resource type="ShaderMaterial" id=5]
resource_local_to_scene = true
shader = SubResource( 3 )
shader_param/spread = 45.0
shader_param/flatness = 0.0
shader_param/initial_linear_velocity = 0.0
shader_param/initial_angle = 0.0
shader_param/angular_velocity = null
shader_param/orbit_velocity = 0.0
shader_param/linear_accel = 0.0
shader_param/radial_accel = 0.0
shader_param/tangent_accel = 0.0
shader_param/damping = 0.0
shader_param/scale = 1.0
shader_param/hue_variation = 0.0
shader_param/anim_speed = 0.0
shader_param/anim_offset = 0.0
shader_param/initial_linear_velocity_random = 0.0
shader_param/initial_angle_random = 0.0
shader_param/angular_velocity_random = 0.0
shader_param/orbit_velocity_random = 0.0
shader_param/linear_accel_random = 0.0
shader_param/radial_accel_random = 0.0
shader_param/tangent_accel_random = 0.0
shader_param/damping_random = 0.0
shader_param/scale_random = 0.0
shader_param/hue_variation_random = 0.0
shader_param/anim_speed_random = 0.0
shader_param/anim_offset_random = 0.0
shader_param/color_value = Color( 1, 1, 1, 1 )
shader_param/trail_divisor = 1
shader_param/gravity = Vector3( 0, 98, 0 )
shader_param/color_ramp = ExtResource( 1 )
shader_param/test = SubResource( 4 )

[node name="Node2D" type="Node2D"]

[node name="gradient" type="Sprite" parent="."]
position = Vector2( 513.211, 297.947 )
scale = Vector2( 1.98684, 1 )
texture = ExtResource( 1 )

[node name="Viewport" type="Viewport" parent="."]
size = Vector2( 512, 512 )
usage = 0
render_target_update_mode = 3

[node name="Sprite" type="Sprite" parent="Viewport"]
texture = ExtResource( 1 )
centered = false

[node name="Particles2D" type="Particles2D" parent="."]
position = Vector2( 452.324, 214.531 )
amount = 2
lifetime = 3.0
process_material = SubResource( 2 )
texture = ExtResource( 2 )

[node name="Particles2D2" type="Particles2D" parent="."]
position = Vector2( 683.903, 215.584 )
amount = 2
lifetime = 3.0
process_material = SubResource( 5 )
texture = ExtResource( 2 )
    [gd_resource type="Environment" load_steps=2 format=2]

[sub_resource type="ProceduralSky" id=1]

[resource]
background_mode = 2
background_sky = SubResource( 1 )
             GDST              �B  PNG �PNG

   IHDR         {C�    IDATx��ݺ�*���^��U��o�SI��p��T[
��y` �y�7���<����p�p$�>���#�s���_�Y��H�r�-���o8Τ�����?Y8�J��-����kl8;�._^��M�7Nv������8#wٸq���|>����џ�I~���}~('�y�[&Ѐk�`2����O16k#����&S�_\Z�=wW�6��=� �gzc�|����]�&�����z-�5�B)�^��A�t�����*0�|��ԛD�*�U��v9p DGi��m2�7�$��'�!������)�k��~@ \3wvYI��XB�:ؒP/�����nW�$��=}3��)��}<��܉� ����]��+�Ohx���� ��3�1&��~�@�*y�p��	@]< ހ ���0Z�A��LH���$���i��P`���dM~kTD��	4B]�b�B�XZ����]f�Bge��uDnklI ���[e��$�K� �SZH�+?��-�|>eK �7�5�x�lܴ)�?A:�%I�5o�6n c� ,FMP��c�Z䔵gE�6�ς<p�5�Hv;n����m�P3�/ob�Z�4�$<���*�˧]�le�\�� ܩp <  k3��&*��ٽ�q��b@  ؊��]p�  Je��`)���q�A���"��?�.4
����-�߲��Ǵw�Y�-8�o��9�-)V���#���n�[1�΃��������4��� x51�c��D  /�!��Ikz���SP`sbq��;��\  �����	��6�$q�9���m7���i>W  ����|�c=� ��  w�;벜���e�^ ��Voփ7��˝O-s�)2��r�&�����[�"��O<~��鑓�1ZHV���J���c��vn;k�j0+Pnn��������OD�(Sl���w"�����Q`�XȤ+   8b���� �o�vi_�b�� ���>(�꺴����l@s�ӵu�*IP���4��< �D�Sfj�^��}�W  ��a3Ǭ7�d�*�I�;͠!Hހ �ǖ�h�F����E�;i	h`2!,�����#y��eX���4�)/�S��e޽�9~ǝ-�&�Ӣ�qY]��t/?�>�9V��(ϡG���}��\������ѝ�V�}Zl�!�W���-�8��)���ǿ$:Ǭ�������`>{������lў)��Wʞ����j� �R�["FH�yFM��h�L�jE:?}p�7۲��J1X���*�j�'8  ` �/#�̈ǻ�D��İث֎�SQ���`2N���)���w�m`��}6 Ѐ��E[W�|�m{Y&�r.��8B���%��Q}�%��<��:���[?��Sl`*[Ď��/�Z���U�m�zOM�?r����9�&�S�U���u]�`�]F���ٸ6|eG�n���,�g��� P	 ����<)f�y6�
��t�2�3%�Sp�x0�ހ ,I��rkq�kP���w�=� �U�9;�l�h� �s��	�f��N � �Z0�5�	6�:j��/a9  o���D�K @ <��Ɲm�gֱk4%_=��Zf�Q{�5���|l�!�7HoK7%ȫ�P�������!�ɱ�}v�c2�c�}����[;�n������rh??��b`�n�������� X��T+�<��݂~6�eXkV{+\R��V>�  뱐��W'���K�x����@ ��a�L4�y�8az/��/ 2��LwdN`���^с�  @{0�K �{���n��p��v�Ŕm7��˿����ty�Lr��R��&�~P���d��
d�H�?�KKԵnuBJQ1bW�^���@Z(k����߿xA��n-	 ��G�K��6sQ�A�9�̉�ǅ��g1eb��	��%u�1�ܷ0�)�+��W*D��ص5�{U�y��9�
�Y@ �_Vw�v|_��H�Nb�`i  ���.`�_����[f���V�ru�~!�7�o���������a�����C�@ ��x��kaxv�P�����p#��>��=����Z�2�Z��
f�6�=jj|�=܎ a��߿�Ӈ�����������^�e��m�x�R�c؝�{F����Y]���a��A'�  ��p����f�Q�'<��� �S���n�նm���@ �G��+o��he����5��̢iƌ�ӗ�������ʒW��	`>��3��->�,�w<\iC�� ��2`�  ����p���9��<�����ޟد���2��e�q�+��Ρձ�wcJ(þ�|{'�JH��g�ˊX/�U����
YN8�zL��g���5�U�V��(�?��+�䘅�3�	���!���N��5k���{~8��� �p��qk<:Mͳ������ŶM��*>�]� �A��lHǢCjiv�)���B���&��`W����r�kS� ��z�a�D���5�-�bX���{!.�Z5Y��'��G:S�;�w�E�ӑ�3�d���TSW�%nYx��@ @j�:+�s�fd�;{�C}H������po�}���Y������Ì~K��Y����?�l�p�M�H#e�Y����5��y�@5��Vwc�`�$:���HU��|�d����5����&�	�p���<���ue=v����� $�����? ���>�s�V�z�m$ �@ �`�yh;�]Mu�۸ 	�� �TԵJW�3���_E�U�H �1��=��F9?� 0 xƧ�o��~ ��4Ԥ{#i����ou�)��n#+�&��lP��u�a�oYʼL�[������U�l'��o��~�;����
|�qs�<?�Q�(����1z?�T
4�
�}`[F��J{*/��t�  ���
F���ҥ_�7��3*�����JL۲[� 0��~��cG�{SSo}��3�9��94��@�r�G�lB�4YT<��}q9�,��6 �Q������ �@ ��z U�"7�x0��M��ٲ$���,��Y.�
��-�B� �.���~%_�B/d����e�&�'w�E��L�WkQ7<�{�z��s�e7K��
�� ��<�2Й`: /�%�S�U�Բ��M�`W  o�+��	�U��>6����#�1t�;� xd�|�����6�Y�y%�N���Y5( �^ت/}�Y8�m���3V�]JY�{A" ����z{]CK�0  /e����Y���
�q�ޫ�^�+�ٷGdO�c�q=j���� 7
����涄�D�����<3g7B���!��-�j�k����|�]�э#vo@'
�s-�D�A�k�0�d�O�</ j� �C�{�%F�gW�zM�M���T��`3  ����bd𧉎V^�.��i@[  [�j��r&�/h�-{x�aI�*�� ~�yp�_Z��m��$����� ��� �0�;������p$����_8ɟ0��S��rw�J���B�դ��+3�6wm#+/�/ɐ�y�1e�x4��&��3�T�}�.r�wM� ��e��~�� �a�(�� � Q����=�7�F�{헦�h��,���Ҽ�LSr�q��� `4�]L��X�W�U��H��a����x�@  sx�2���U��@'� �ĕ�T�k�5o
 ��솎2f�����ϕ��� GȞNY���՟�G��fU$g3P��H��S
�_I��̔��@lћ&��昫�!%�KK����6�Vr����xz��|�_i��ocJ����m��~�  ���]�d �2��+k��u��"\���@"��h8��8@Mi�qST��
�
�T��X�S\�����j�Q�Nf�*��*����@ ���т�����G�k�^o�`9  ��;�����]�X� �@ ^���8�)Ψk�/t��J@o  �9߫>���5Z"S�Y�j�:=��M�y	�gevUJ̇^��{׼:�Y�F=-�q�Dlo�����]��eu��?��/*�Ut���m����Ă�N���C  �7�ό0]��K�6)�7oN�-�y �̚�&+e3�m�ښ�xg�$�f}��K��!�Ι%9�ߙb��T�eObv�Z~ʵ�bO�-fe��X��+���Sj����И�ť��d�॰��Z�y�D�V��SG���`  ��,��nT�fg@� ��yX������������q�ȗi�j��c���]�
���#�v�a���^�E���z�H��;����Ƅ��33h������~v�������|Dn�l��|�m�%���#�'̭ȃ)�z�aOJO:���Y� �s�{p�WK+j:֡ހ�@ �g���]����&y�>y48�Ev�-��:��4�x�G��n��n_����D]5)n]`�D�w�c1  ��h�BL�ގ���ʔh|9d��U�`㧥��&R�QtoC�X ����zLT�аa���O �Pban;Z����\{�F��Ϡ�D��)�Ff����>z��Y椇2��spW�ީU�;˞!{^֢&�3�X{���M���z/�Q+Rwȟ�!~�?��y����׺^`��~x΁  ?�6�?;�JU�_�@ �~|�G0�������j��7����Iϧ�D���2  ��y�x����ܙrY����菵x��
 E]\=�7�=���H���6�7��ˆ�_����1cX�g�{�����K U�ڠ�g  �H\O��Շ�F��{��UW�K͎��O^�%��X��F�et�}�NP�(�ӌ�UoM,�N�$��� ��	�_�Z����jv�O��+�q�9�G�O\�@ �'k:r�*3v�Cø\e�S�q�K�  ����ۨ�Ȅ�ް����&@ �#+Eo��L��t}�o{���'=�u��� M���c̡�ܕђD�zI�[f$ڦ,e�@ ��O5~$vmY�5��B *���8��W�
�3,����K�b��� ����=K, �DO5��72��`4v�4�5�Ώ���o���� b'�PCV��c�2���OI�x��L��9����S�����#�W���Ú���G-���q_EO`��
�62����� M�E:��Z  .����$��m���|�K����J>�P�5�  W^�'�(E�bO6)�?�4�6v�	���k��2k��io:�Wf-킽� L&=����UW�KZ9����	�V�~�'��˃�֭D��� T�p��/��62�����ǐ�^y0�����#���Xnڵ��A���φf�e�� �d��oxc{�����F��)^� O�s����}�'�<Kl.�O/������	l(*��̠'���-Z��pyf��K��n��<b�B?��o�������(�6L ~ȝ6�K�2��Ķe=�֕7���@ F��I�
gY�q]�ދ��s��_RӁ "w��mPobtN���Tq�t*�T���Ƶ�J3�¡��zD�Å���Ok"��ǣI�� �@ ����D�P�ɘp��9	�x��Ml�z����@ �HW��}���럲�)�
 ���z��Nl���}�mЀu� "��ǦQ�A��Ɗ2�nXzp�ҘU1�U����b����X�z�Z(����a�C�K�m�E�=��{��/m��3O��������R`�4���L�w��@����oIC�۟��V�e"�ԧ���E;�G�>���Rgy��z�S�|⩩����ݿ��`ᠲ��0罩�����J��-��c�BW��X�Ufm�SS�T�.`<.f 0���x@��髣)��Q��KYՕ6 ��wx�����T� ն
o��2pe6h`1����:Ɇ����:���+`  �ӥ����?����s�B�d|c���p#E'V�Z/;�f�Ӵ��'n���9JZ�4��³��q�pY;� ��U'�c��U�B��N��h�̲O��}7^�oe���r��G��ϭ�� �B���v�{� $�ǉ�D\�2�~�@ �d ��g��v-Q�5�w��649�9�$� 0����L2w����[�r�D&�jE����5��C�N\MS�`�ݶM�oE���뽹8�G�t e@ @�|q�k��W��Y|� ��� ����T���?@*@��܉�j�C�\�\l���Ԗ|	��\7�7 '��fV�W�e�Z�W��=�v�$��Ut�gX�������+y�L��]�Z�nqP�P����)�ΆCt�z8�>��2�ߪd��������i2��-M/��c�:�-���SKA: P��B��&��*K��SI���Ձ �M�P3\�;����#��bŞ1  �t�w����-f��ƹ���W �q�FQo�2̉�y��%�uU��~�Ö@ ^JWw���\5�G~ �AЌ��r�[n�j�LsY~�yt��Z�)v3���dvy��}*@����h����$Zh�x��~VN��[l`�T�����g  ��a � �@���y�߃N@ �d���[	�u��i~q�� ��+��7��@ &�����
����@ �����}���vX� 0� �. � 0��%}]�p?~�=h^9M�/W_�n����M	!\&�KԄt�B���#>��!���R��>��2��!��
f-ͯ�����'�	��矿��J��KrO	�)�&j3��7�����Gok��j�[��	�-d�*x�mG`VieU'^�n"-#ݯ�ӌ�V$�����مM��� ��ā��8�݋��Ub9�N  KR?����%H_��
���}R�(N����@ v�����k��wƥc_5f颲�ɻ7����f\���{ծt�u���8��m ���PĐ���n�y��m���8B.?�7|K���+:M�9|�χ]�f���;%򫦁��RX�:3�.~������q���C�ֱ�y�Q�+��O�f)��N9ef7+��ɴ	�sbɴ(����X7��A��Q��@c�X�a#j���t�2�>bS0� ���~k��5�&.u�n�� �{�E ��d�<^b���։���UcW���E� �Gs����5���T��F�R$�X�̣�����c��عn����2�?�_8�-� ,���e�\���~I8�  h)�bv0����B�;������S���f�	�b����餑c�"N��1�����X��g%H�d�2��v�l�<n�cyC�|wh�s�h.4̖�ǾӁ ��1`�"�>�ٿF�W��tΉ���E�=��I=� �J�K��͸���*��wLCj�f.�-.؇�	:D�(j�@�%���ʗ3^�,r��)V��t�h� ��#F�U�������"�`�OZ `&m3,1/3X�s���*6�u� �&1��\������Rf��M�Lg��'H0�y}��I��7	G�V {����������U��`m,�=fmB >�sd/���-4�]f���V}�n�P�cv�թ���o�J���B쒔�e{�\����7�����c��*Yu�1oتR0��E� �DC1Hw��!���]FncAнހ ��OBΩ�π^�Ƃnr[��  `1���e��7�*+���������@`i  ���;T�e,6�85��i� ��vz� ��tJT��sj�	|�ĳm�9�	��ض�\u�m��d�v��
��iXtY� XZw���߿w����OK��{����j����L�v��ބ��p�l�l��#�n�ڨ�m�E����ǥ��?��s���V�j'mT�����`�V�xo5�~�G�f  ;����Cz�y��F97��b�[�_5�3���Z���lܴ� �Gz.MVi��|��Sɞi�n� l°����&��kא�K��0�a�`��    IDAT@ �!�G;f!:��7�v���A0�� 
4 Li��@ ���W���<���>�*��_���u�A�-�N;^̲��ɉo��r�U�r#'��N�V�I�*@z��:�Nl����%�B-Q��}K���d�k��)f �� ��uΛ\�`'  �8�P��sW�{�gz������@ ^�\o���&=�XH�E��M�Hm�@ v@�[���N�Jb)|��m��mw� X���W�Sh>��6a4��)ʚ�HP�d�^{���V@ ^
KY�e��_�
#�A���b  ��|�ن��ȗ���`  �0�����\i5]�>������u]jrw�1F<DZHkQ7(���4sv�z<���>�]�=x]���Y��g7F�8�"�Bց췗���x(Y �� x�*�f�W�\{� DY���8���'�5l	`gr�I�/e��ѵ��py�J;Qj_B�  �{��#�v��g
۲|��</�6�u� ے�SwE�RA+   �bK�>� ��e���y�D�B�Y��t��p�)��%e�F���Ҭ�S��|v���f�KN=B-dw��L����Ƚ�j��K6�<u��,Y��7j������3��� P�b��3X�g  0ҩe�ǋQ��6$��S&� ��J�m��%�M4Ɏ��.顔ee~����<?� 	`�7Gr�+W�\�����U2��_�$�F`.��h2��ǘm\��d���K6w��Z�%p`�����4+��Rvۮ���K�;�m��'��j� *�A���R�S.9ī�i��.�ʒe�6%\��%��Pr���x��<-v�Q5�UWw	Ю`���5;~���|�Ƌ2�^52Yc���c1���n���//M�'�,x  ��%u�Z���4 �e(vX��p�#]SZ�4�����g�~*��%h!��d%V��a�PN/_.T�����>,k� l t�I���}�&K� ����\a,Y���	~Ǫ�#3�x�=�}��������cp`߿W�߾����\rD�汓�9,��_�熳sb;�z���g8�����> �pz��'�g�F��&*���i�s�4���ؚ��0Nm�-*�U���+����1�d<vH��y�Kzy���En�cC���s��ܼ���vs�u� e���Ŝ�s�9zu'�n��6n`���|�Z��4�ܶ3���;�k�� 0��I"�Q�	=�)������>�� ���Ə�#��XW�I2婲���r@ �1`��: 1��ep� X� h����Ǫb��2#^ݲT�&�r��V;m=[�K>��~�<��ggJ{d����n��ˬ�BmP;�8�p�Ny�mw������L�}��(�~N� �l<�dr;� z X �S�)nq�/���,�,��N   %�j�\pJ2RY��@ ��d3�1cm�T���$�a�����q�{�tp %�k�[�e�Gk��J7:w�14`  ː��7`�ԫ��m��Ը~$� 
 �$&>�_�N@ �B����=K���1w �܍@�4@=n$�˓�U_�
~va8._(����ij�j-�_�1��\u���ßp`���Kb�K�>�<j��Vڠ޻��2�ew2��v����c`: 0�wNi��j� ��\�m�I���VŖ1� �6  ����{}L+K$����ƔE]�t� t:���b�O��0�QR��ѯ:x��� ������[̂��ε�-���f�	ʀ ,��80������d��tu�  �XB��<>C�e��U��� t�f��^H?���҃��Я
�ݩ�#��a��	^���X��ItjjQ�Q4鞞/s�CcC����e쟐�N�-M���~�����;Q�A�ۦp]�p��C�� 0)�O��*������LྷНV����	=�mk7f�YuM��H��h/�0��̤�<Ȁ���7d!��Ԫ�U�m� M� ̡f6ڵ�D�'��/�[c��/����<�����c�[3e��
`&��%�C%���!�ܢ&>
4\P[�����t���@Y���Ě�m&ƹݮf.��'� h�F
� ��� ���r{  s#0�S���s�ư<��!QP���󹮋Km��+��<��.��O�)��YKYE섘mj(��+1XO{ �4z0v���j:��j]ꍐ?��oR���� �FZ��zrZ��3��΁�� ��ӱ�]TW��o�o�����hB ����ͳtKzp$���` G,��=��vH�DA�kno�����K���g  �B@M��\R��\y��֜-喍�	���bg�jjYO�}��v�2�3x?  �=�7���a���I֟��1��N`��x�����������!�mg��/���� |��2�߃ܯ�ٱ��$}v���nh%�w�6Am~��l~�Y)�<q U�`CTg7��X�C�M��kp��ҁ ,F�x{����1:�ͯ{��~!�}x��o��nb��Fij�_�@+  ~�G��4�/N:��GNߪk�A�+  �8M�~�����@ v�U#s�f�Z�z����8ʲ�7��l@��/( -�=���\�0��\i��o�x�	n��Wz
�i~{K�L0W��Kت���i��-��b��X������a�ʭ�B�=��2i[�C�������CO�7��,�XHX��,1�[�țN���.�i`]  ;��,�y��.�g'�07?u��XP`=�K��i$YUȰ�����]�L�m�إ�1�f��@ ��j��{���vc'Z�_t�� ����@���o�rU���`��>�	|X�zo>`X6��2�}]>����@. Ќ%�}��%<���0˹CT� 0#!�K�/�X��E}ELAi�ʁ��lllN)!v	k�;!��U-��Kbh^�P�3�o陪r�U|�8��.����0I�� �@ �F�H�=X�x��֪p� D�Ǒc�����7r��X,
 ,@��e#H���v ���0e�6 �`G�+�t�N�jz ~��q����n7Ǩ(ˆ�M�MZ��b�X�a�N=@�gK  ���<��^d���5b���
 ��7��Wy�`3  ��X~��������f�?�����_}_�[T�1��L��,�S��?���)o�F��)�q�d��O���x���+ގ��{�I	��?'�p��p����v�Q��! ׌��[�6��<�m��%��$X ώ	 �. Ќ���[�wB�_ؤ��`��� �AJ�����#l�,a���	l p��V�EQ��/��+ И�����K��! �jhg�ĳ`j��L-7�Q}�����z��䙷m�k�1�KK����<Vw�w��Kjzl� ��GA��W�-�î��P�
t�[f R�c�;6h�h]r��t} Xó��\�J0�ڬ��"���t����o!�`6�5Y7����B(Fd��L�).'Vx�r�  `�/��䔀� ^��,� W@ \��0�9 ueu�MՄ��G�[�X�t ���qW���R^�YkV�?�� �� ����J��͵Un|�k ����u`:���	}<��vM{��{��J.��r5�˯W?>�ij��� �>��cV�H��	�](+b���Z��۬մ@VH؅`��u>V�*������}6'f��� x��)e�;�J�>��{���Ā �#=9����o ]���\��i��I��x�:��%z���kڠ+�h;���,�Y�   �x�6�tp�����7 �~Sfǘ��� X�7�Cg�b�tAJF����!Ns�2Y^?ml�O�R�%���jZ6���"V]�
�[VW������)���� ��o�S�"u�	��뺂������  
Y��� � �B��ڻ����L0��q����l����S�7,����&�-L�Ģd�[� ؄�4��ډ��z:�~��R_�0yVo����>W3�`U�x�1����k�~����D�΁ l��a�d���|��B�g#�J=�� ��@ F���ҫ�԰�&��r�.�  �Q��!���~�Az�%��Ϫ��.L����ZVE���E�Y!r5���R�`�����*��Xsdj?�6M]_��)f&���,4��V�zcE�~��4v>���ß4���0ù��=4�Gpm`]  ��I0�:�M��t2>��a�^��=���9<���5�^�)��&!����ӽ��m>�l��_�`�_$zۂ��N���@W�m� ��'�" P�C���#�a��8h8ˋ���!�:�ƳD~��;���u�#,��YK��Р��>a��|�x~k-?��k�Qo��b�Y�!X����_�M��[C���9����
� ����G��Jgs���yzO�ʿ���  �� �c�;3M̋�4��:Y�H<yL�����0c�ݤ��7��N��N���Nsr�Vu���y��7���؅��¾���5��Q�NݕU��Q�-����4�v�;��=��� ��ʒ�>睊L��sG@  v�'����)ì����@6 �	����|�|w����pYv�ֲ�0�.��r�#��/�ĭʤ�,�����d���ث�B��~�n�`k�,f|�����Fv$&��c�i����X������ސ�7�;���<���s�͆�i�0h ̧���.٭c�l��?�7����G��Q��ց7  s��>rQ�U�-��L���ҫ�� 0���jue6�5y�R<�3jۘL�ʺjR�]%���@ ����@���&��l�	�A�v�S6�̃#i>�~[�N@ �h�d�~U����6)s� 4��Р�����hg�my�T?[V�Z)����@3�|j�('�mV��z<��A.���:-и5_��薰��uoh���_�����A��C  ;P0�<�Fce�QW���L�kwy�6Li�� �Ib"���yL�-��	��N.���x�H�%�qa0�~\}�iR)p`#���9�3�1bG���'�!fҰ�����2uH���Z���P���2�=�s��K��x��Mj�s�r�0u����S��,�uE�������gm�������G�2�Z*Kh�jی�� �
�P���e�L��\sw2Ur/�+-"����'k1 �`&S, �áXr$?8a�,���NV��@ F�>A��n�ab��ejۓJ9�����g�=:���j���IA�NcO�g�Fѯ�˓���d�����f;Vz_XG1�c��[�K�w6T�b��ٸL�R���`����Яp��	 �C�e��m�L���>o@ v 멼Ʌ�TRS8[��-	F�>8k���*(�N@ �E�?7�rCS:�h������V=F��(y���>�/��)�n]ɀ�z � �=�o8�����/���G�V�N�i
P� v��q �@ F@����M�K�4�<��p-�+}4����LRHM����2F���(���ǅk���+���D��7:_�0L��2l�-�П�Q�|j�L�ߞ�Ɣ�w����j6�`��f0#�:}�}�8�=� x!k�٩;�����az�YuUf�@w+A�0��@� �]���,�A&��?ř��v�� L�kHG�y�gVHK�̽���#���mRr��!��/R���9��A]�mKG���*�~��q?
`Y���B�9�z���b����-�@ ����R��^`j�EMu���wZ�u]��y��χ~Kk)����
�*d�8�$�&��}ܡ��d��2�=�"�Y����U����-@.��@ڷ�j'?v��?���!�m����ȁ  �����r���9K@���;��3=gf�м^8�~f��id9�25Ư�PRM�1wC]S_

/4-
�r3  `)o��e��u�>6V,zBo�_��`�F�S���	^`�N�e���С�o�R���*v{W��ޗ XcL��Ն(GJ�# ���(��گF�Y.9Mi� �%�]hfz��f�Df�� �d�*�;J���s�b���]�c�My|G��K���)3�L�~Ѯέ"��b�#�1<��>��ݽx��	�#c�̏���jJ���^À ��Ul$Q��lǎ���@��!in� ����\�er�R2J�͐�t�%��;�6]SKc΢2j�D�g���VYf�o,��)^; ��"�H�k.[��LWI�͏uE�}��E�0�a�%��p��i`�ֿ҃�|����T�5a|?'�W�tzT���� h�<�E���l@V�l�ʉ����LwwCh�!?]�
��Yn;-��~ɋ�喂�-�9j]P�Y�c�A�H=5�>�.����ɬ������3-?�����������ܱ���e�.�H  o����4���3t�^CYQ��x�F�K���m����8��&{xϚU��T�`C}!�h8����}J-G�ˑ �� �x4Vz"oNV����2��oV�[u]�PX�2��(�24�sn9 �@ � �L�A��@ -X�|�7����qv>�&���z�aa
41��⫽�>�Zv��04gM���$���94�]��!���zYE�8�|>������D�z~�a�a!    �R  ˀY�x:�_�^��l;`��� �r�N�F:JY���aqb�cw����Q��i����i���'rn� g�- ��;i��q�e��b@ @	�}J[�d ��X��$X	�גx��Y@ ����.ֱ��X	,ɚm�U�~�î:���BϤ��rk�̗����������;8���X�*����Τ�r��o�ݤ��P�$�?��~� �Cב�j�2�%�Ϸ���yI'f�Ձ ,��Ngu�+i�|5�R�Ӌr�4 F�J����6�&�^c�˅|K  ����,3�L�C����9K��@. P��51��9����ةA1{��@ �n�U�J��p<h`!���~���|>�opC�=����
����6��bڒ��Mc7=�+nb���h�B�ñ�M�I2�_� ���2�������L,I�`����<���� ���Q���<��ęε{�  �����/���7��ҟ� �@ ���A~ �I��P�L����,�Ď�o�i8`�/N�1�>�"F��)�8rr��� �M�"jM|qA�~sc�WY�&Q>=78��������8�9�5�l���m	F $  �fd�МZ<�,  C�ߓ~o0�4Kc��)GR�'�2�c�O�vP.iƊ��Kͻ��Q,�_N���iM�g���b,���h��Nտ�S���x�v8��%�t\��4~'`:�}Xk�<�)�!]�Os�C�Z��WX�m��$�`PO��vP=y@g�!� d`�qf��ے�§[M��R�����&~�U�c�t̶`������ �Fl��4m�1x�{�WI�]�	��w�)e��� k�a!b�I�륌�с  ��2�[�C��\0�'y����� tG�J��q9��X*:�%�+���vcSR8�^B͐+�v�W�i�%���^.��1�^�!�̌�ЙZ�������!�A�^��-d]�=�O��}yˀ7  �� è��1玟�f@ @�r������V���]�o^,� `����X�A[ߺG����=��@ ���t� ��X�L?�;l���&��o `~\R=;�eKp�@
����N�/�͝}����0� ٸ���> d�Η ����#�_���2/���x2����	2�P�H.D���R�s�h��I�p��
��
��Suf��A���.zZ�6�.�����g�ք�/�N���~cc|���A}���'"�|�%��U���'%��q3�C��we�D5P `�ң��Z{.cdi�6+��늚(�`4@<e����=���S�+g��  qIDAT�v��5��Z ��9��aw-�IY�lN���0���Ƶe�pP`ab^C�g�PW�K�e��s{�nx  �����{�,`2�:q���4_>���y�׾����K��.��G���E,y�vH�<����b��¸�0���JK�Iz�ms���I����s�l(����6�����%$� x�{LW��u�W�>j���;��w����y\۪i��zzc?c�@ <�&���HE[c�gc�g�>�S��ؘJ�01Q8��Ձ �f�t�,djYZ�;�Q~<�`�FW���c9�EH6�N�G=g�^��Җ�}g�C
�ހ �"�cJ�$�V��/�ʉ�n�fO�j Pr���_ 5f|��v]2+�-�@ F ��߱����2k>���d��-�M�>H��U�lS���Z����(9�Ly���\�%�E�s� Z0M��^���ߕ/�<���hգ�)��/����뺂��W��ǁOp{���1�@��>(�/�P�fr��c�so.{�l`��E����aĪ[hS( 0�~���V���4l	`�F2d�&��;ޒw�v5�j9   �f�W��~'  �3���R/�� �:�����    IEND�B`�              [remap]

importer="texture"
type="StreamTexture"
path="res://.import/gradient.jpg-32594b13ed3addf92ad8c15ba2ccd54f.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://gradient.jpg"
dest_files=[ "res://.import/gradient.jpg-32594b13ed3addf92ad8c15ba2ccd54f.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=true
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
    GDST@   @           |  PNG �PNG

   IHDR   @   @   �iq�  ?IDATx��{pTU�����;�N7	�����%"fyN�8��r\]fEgةf���X�g��F�Y@Wp\]|,�D@��	$$���	��I�n���ҝt����JW�s��}�=���|�D(���W@T0^����f��	��q!��!i��7�C���V�P4}! ���t�ŀx��dB.��x^��x�ɏN��贚�E�2�Z�R�EP(�6�<0dYF���}^Ѡ�,	�3=�_<��(P&�
tF3j�Q���Q�B�7�3�D�@�G�U��ĠU=� �M2!*��[�ACT(�&�@0hUO�u��U�O�J��^FT(Qit �V!>%���9 J���jv	�R�@&��g���t�5S��A��R��OO^vz�u�L�2�����lM��>tH
�R6��������dk��=b�K�љ�]�י�F*W�볃�\m=�13� �Є,�ˏy��Ic��&G��k�t�M��/Q]�أ]Q^6o��r�h����Lʳpw���,�,���)��O{�:א=]� :LF�[�*���'/���^�d�Pqw�>>��k��G�g���No���\��r����/���q�̾��	�G��O���t%L�:`Ƶww�+���}��ݾ ۿ��SeŔ����  �b⾻ǰ��<n_�G��/��8�Σ�l]z/3��g����sB��tm�tjvw�:��5���l~�O���v��]ǚ��֩=�H	u���54�:�{"������}k����d���^��`�6�ev�#Q$�ήǞ��[�Ặ�e�e��Hqo{�59i˲����O+��e������4�u�r��z�q~8c
 �G���7vr��tZ5�X�7����_qQc�[����uR��?/���+d��x�>r2����P6����`�k��,7�8�ɿ��O<Ė��}AM�E%�;�SI�BF���}��@P�yK�@��_:����R{��C_���9������
M��~����i����������s���������6�,�c�������q�����`����9���W�pXW]���:�n�aұt~9�[���~e�;��f���G���v0ԣ� ݈���y�,��:j%gox�T
�����kְ�����%<��A`���Jk?���� gm���x�*o4����o��.�����逊i�L����>���-���c�����5L����i�}�����4����usB������67��}����Z�ȶ�)+����)+H#ۢ�RK�AW�xww%��5�lfC�A���bP�lf��5����>���`0ċ/oA-�,�]ĝ�$�峋P2/���`���;����[Y��.&�Y�QlM���ƌb+��,�s�[��S ��}<;���]�:��y��1>'�AMm����7q���RY%9)���ȡI�]>�_l�C����-z�� ;>�-g�dt5іT�Aͺy�2w9���d�T��J�}u�}���X�Ks���<@��t��ebL������w�aw�N����c����F���3
�2먭�e���PQ�s�`��m<1u8�3�#����XMڈe�3�yb�p�m��܇+��x�%O?CmM-Yf��(�K�h�بU1%?I�X�r��� ��n^y�U�����1�玒�6..e��RJrRz�Oc������ʫ��]9���ZV�\�$IL�OŨ��{��M�p�L56��Wy��J�R{���FDA@
��^�y�������l6���{�=��ή�V�hM�V���JK��:��\�+��@�l/���ʧ����pQ��������׷Q^^�(�T������|.���9�?I�M���>���5�f欙X�VƎ-f͚ո���9����=�m���Y���c��Z�̚5��k~���gHHR�Ls/l9²���+ ����:��杧��"9�@��ad�ŝ��ѽ�Y���]O�W_�`Ֆ#Դ8�z��5-N^�r�Z����h���ʆY���=�`�M���Ty�l���.	�/z��fH���������֗�H�9�f������G� ̛<��q��|�]>ں}�N�3�;i�r"�(2RtY���4X���F�
�����8 �[�\锰�b`�0s�:���v���2�f��k�Zp��Ω&G���=��6em.mN�o.u�fԐc��i����C���u=~{�����a^�UH������¡,�t(jy�Q�ɋ����5�Gaw��/�Kv?�|K��(��SF�h�����V��xȩ2St쯹���{6b�M/�t��@0�{�Ԫ�"�v7�Q�A�(�ľR�<	�w�H1D�|8�]�]�Ո%����jҢ꯸hs�"~꯸P�B�� �%I}}��+f�����O�cg�3rd���P�������qIڻ]�h�c9��xh )z5��� �ƾ"1:3���j���'1;��#U�失g���0I}�u3.)@�Q�A�ĠQ`I�`�(1h��t*�:�>'��&v��!I?�/.)@�S�%q�\���l�TWq�������լ�G�5zy6w��[��5�r���L`�^���/x}�>��t4���cݦ�(�H�g��C�EA�g�)�Hfݦ��5�;q-���?ư�4�����K����XQ*�av�F��������񵏷�;>��l�\F��Þs�c�hL�5�G�c�������=q�P����E �.���'��8Us�{Ǎ���#������q�HDA`b��%����F�hog���|�������]K�n��UJ�}������Dk��g��8q���&G����A�RP�e�$'�i��I3j�w8������?�G�&<	&䪬R��lb1�J����B$�9�꤮�ES���[�������8�]��I�B!
�T
L:5�����d���K30"-	�(��D5�v��#U�����jԔ�QR�GIaó�I3�nJVk���&'��q����ux��AP<�"�Q�����H�`Jң�jP(D��]�����`0��+�p�inm�r�)��,^�_�rI�,��H>?M-44���x���"� �H�T��zIty����^B�.��%9?E����П�($@H!�D��#m�e���vB(��t �2.��8!���s2Tʡ �N;>w'����dq�"�2����O�9$�P	<(��z�Ff�<�z�N��/yD�t�/?�B.��A��>��i%�ǋ"�p n� ���]~!�W�J���a�q!n��V X*�c �TJT*%�6�<d[�    IEND�B`�        [remap]

importer="texture"
type="StreamTexture"
path="res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex"
metadata={
"vram_texture": false
}

[deps]

source_file="res://icon.png"
dest_files=[ "res://.import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex" ]

[params]

compress/mode=0
compress/lossy_quality=0.7
compress/hdr_mode=0
compress/bptc_ldr=0
compress/normal_map=0
flags/repeat=0
flags/filter=true
flags/mipmaps=false
flags/anisotropic=false
flags/srgb=2
process/fix_alpha_border=true
process/premult_alpha=false
process/HDR_as_SRGB=false
process/invert_color=false
stream=false
size_limit=0
detect_3d=true
svg/scale=1.0
�PNG

   IHDR   @   @   �iq�  0IDATx��}pTU����L����W�$�@HA�%"fa��Yw�)��A��Egةf���X�g˱��tQ���Eq�!�|K�@BHH:�t>�;�����1!ݝn�A�_UWw����{λ��sϽO�q汤��X,�q�z�<�q{cG.;��]�_�`9s��|o���:��1�E�V� ~=�	��ݮ����g[N�u�5$M��NI��-
�"(U*��@��"oqdYF�y�x�N�e�2���s����KҦ`L��Z)=,�Z}"
�A�n{�A@%$��R���F@�$m������[��H���"�VoD��v����Kw�d��v	�D�$>	�J��;�<�()P�� �F��
�< �R����&�կ��� ����������%�u̚VLNfڠus2�̚VL�~�>���mOMJ���J'R��������X����׬X�Ϲ虾��6Pq������j���S?�1@gL���±����(�2A�l��h��õm��Nb�l_�U���+����_����p�)9&&e)�0 �2{��������1���@LG�A��+���d�W|x�2-����Fk7�2x��y,_�_��}z��rzy��%n�-]l����L��;
�s���:��1�sL0�ڳ���X����m_]���BJ��im�  �d��I��Pq���N'�����lYz7�����}1�sL��v�UIX���<��Ó3���}���nvk)[����+bj�[���k�������cݮ��4t:= $h�4w:qz|A��٧�XSt�zn{�&��õmQ���+�^�j�*��S��e���o�V,	��q=Y�)hԪ��F5~����h�4 *�T�o��R���z�o)��W�]�Sm銺#�Qm�]�c�����v��JO��?D��B v|z�կ��܈�'�z6?[� ���p�X<-���o%�32����Ρz�>��5�BYX2���ʦ�b��>ǣ������SI,�6���|���iXYQ���U�҅e�9ma��:d`�iO����{��|��~����!+��Ϧ�u�n��7���t>�l捊Z�7�nвta�Z���Ae:��F���g�.~����_y^���K�5��.2�Zt*�{ܔ���G��6�Y����|%�M	���NPV.]��P���3�8g���COTy�� ����AP({�>�"/��g�0��<^��K���V����ϫ�zG�3K��k���t����)�������6���a�5��62Mq����oeJ�R�4�q�%|�� ������z���ä�>���0�T,��ǩ�����"lݰ���<��fT����IrX>� � ��K��q�}4���ʋo�dJ��م�X�sؘ]hfJ�����Ŧ�A�Gm߽�g����YG��X0u$�Y�u*jZl|p������*�Jd~qcR�����λ�.�
�r�4���zپ;��AD�eЪU��R�:��I���@�.��&3}l
o�坃7��ZX��O�� 2v����3��O���j�t	�W�0�n5����#è����%?}����`9۶n���7"!�uf��A�l܈�>��[�2��r��b�O�������gg�E��PyX�Q2-7���ʕ������p��+���~f��;����T	�*�(+q@���f��ϫ����ѓ���a��U�\.��&��}�=dd'�p�l�e@y��
r�����zDA@����9�:��8�Y,�����=�l�֮��F|kM�R��GJK��*�V_k+��P�,N.�9��K~~~�HYY��O��k���Q�����|rss�����1��ILN��~�YDV��-s�lfB֬Y�#.�=�>���G\k֬fB�f3��?��k~���f�IR�lS'�m>²9y���+ �v��y��M;NlF���A���w���w�b���Л�j�d��#T��b���e��[l<��(Z�D�NMC���k|Zi�������Ɗl��@�1��v��Щ�!曣�n��S������<@̠7�w�4X�D<A`�ԑ�ML����jw���c��8��ES��X��������ƤS�~�׾�%n�@��( Zm\�raҩ���x��_���n�n���2&d(�6�,8^o�TcG���3���emv7m6g.w��W�e
�h���|��Wy��~���̽�!c� �ݟO�)|�6#?�%�,O֫9y������w��{r�2e��7Dl �ׇB�2�@���ĬD4J)�&�$
�HԲ��
/�߹�m��<JF'!�>���S��PJ"V5!�A�(��F>SD�ۻ�$�B/>lΞ�.Ϭ�?p�l6h�D��+v�l�+v$Q�B0ūz����aԩh�|9�p����cƄ,��=Z�����������Dc��,P��� $ƩЩ�]��o+�F$p�|uM���8R��L�0�@e'���M�]^��jt*:��)^�N�@�V`�*�js�up��X�n���tt{�t:�����\�]>�n/W�\|q.x��0���D-���T��7G5jzi���[��4�r���Ij������p�=a�G�5���ͺ��S���/��#�B�EA�s�)HO`���U�/QM���cdz
�,�!�(���g�m+<R��?�-`�4^}�#>�<��mp��Op{�,[<��iz^�s�cü-�;���쾱d����xk瞨eH)��x@���h�ɪZNU_��cxx�hƤ�cwzi�p]��Q��cbɽcx��t�����M|�����x�=S�N���
Ͽ�Ee3HL�����gg,���NecG�S_ѠQJf(�Jd�4R�j��6�|�6��s<Q��N0&Ge
��Ʌ��,ᮢ$I�痹�j���Nc���'�N�n�=>|~�G��2�)�D�R U���&ՠ!#1���S�D��Ǘ'��ೃT��E�7��F��(?�����s��F��pC�Z�:�m�p�l-'�j9QU��:��a3@0�*%�#�)&�q�i�H��1�'��vv���q8]t�4����j��t-}IـxY�����C}c��-�"?Z�o�8�4Ⱦ���J]/�v�g���Cȷ2]�.�Ǣ ��Ս�{0
�>/^W7�_�����mV铲�
i���FR��$>��}^��dُ�۵�����%��*C�'�x�d9��v�ߏ � ���ۣ�Wg=N�n�~������/�}�_��M��[���uR�N���(E�	� ������z��~���.m9w����c����
�?���{�    IEND�B`�       ECFG      _global_script_classes             _global_script_class_icons             application/config/name         BUG_Angle_trfeedback   application/run/main_scene         res://Node2D.tscn      application/config/icon         res://icon.png  )   rendering/environment/default_environment          res://default_env.tres         GDPC