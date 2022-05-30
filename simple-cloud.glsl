// ノイズ関数
float noise(in vec3 p)
{
    p += iTime * 0.8;
    vec3 i = floor(p);
    vec3 f = fract(p); 
    vec2 uv = (i.xy + vec2(37., 239.) * i.z) + f.xy;
    vec2 rg = textureLod(iChannel0, uv / 256., 0.).yx;
    return mix(rg.x, rg.y, f.z);
}

// フラクタルノイズ
float map( in vec3 p )
{ 
    float uv_y = p.y;
    float f = 0.0;
    float amplitude = 0.5;
    int octaves = 10;
    for(int i = 0; i < octaves; i++){
        f += amplitude*noise( p ); 
        amplitude *= 0.5;
        p *= 2.0;
    }
    
    float attenuation = (-uv_y -2.);
    float wave_height = 2.0;
    return clamp(
    attenuation + wave_height * f,
    0.,
    1.);
}

vec4 raymarch( in vec3 ray_origin, in vec3 ray_direction)
{
    vec4 sum = vec4(0.);
    float ray_length = 0.;
    float ray_add_length_per_step = 0.1;
    int step_num = 100;
    float cloud_density_threshold = 0.01;
    for(int i = 0; i < step_num; i++)
    {
        vec3 pos = ray_origin + ray_length * ray_direction;
        float density = map( pos );
        if( density > cloud_density_threshold )
        {
            vec4  col = vec4( mix( vec3(1.0), vec3(0., 0., 0.5), density ), density);
            col.rgb *= density;
            sum += col* (1.0-sum.a);
        }
        
        ray_length += ray_add_length_per_step;
    }
    
    return clamp( sum, 0.0, 1.0 );
}

vec4 render( in vec3 ray_origin, in vec3 ray_direction)
{
    vec3 sky_color = vec3(0.1);
    vec4 cloud_color = raymarch(ray_origin, ray_direction);
    vec3 output_color;
    output_color += sky_color;
    output_color += cloud_color.xyz;
    return vec4(output_color, 1.);
}

// カメラ姿勢を決定
mat3 createCameraRotationMatrix( in vec3 ray_origin, in vec3 target)
{
    vec3 cw = normalize(target-ray_origin);
    vec3 cp = vec3(0.0, 1.0,0.0);
    vec3 cu = normalize( cross(cw,cp) );
    vec3 cv = normalize( cross(cu,cw) );
    return mat3(cu, cv, cw);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
    vec3 ray_origin = vec3(.0, 1.5, 5);
    vec3 target = vec3(0., -1., 0.);
    mat3 camera_rotation_matrix = createCameraRotationMatrix(ray_origin, target);
    vec2 uv = (2.0*fragCoord-iResolution.xy)/iResolution.y;
    vec3 ray_direction = camera_rotation_matrix * normalize(vec3(uv.xy,1.));
    fragColor = render(ray_origin, ray_direction);
}