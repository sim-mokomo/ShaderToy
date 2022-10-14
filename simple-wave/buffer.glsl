float get_height_from_buffer_texture(vec2 uv){
    return texture(iChannel0, uv).x;
}

float get_velocity_from_buffer_texture(vec2 uv){
    return texture(iChannel0, uv).y;
}

vec2 get_current_uv_using_offset(vec2 fragCoord, vec2 offset){
    vec2 pixel = 1.0/iResolution.xy;
   	vec2 uv = fragCoord.xy * pixel;
    return uv + pixel * offset;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // note: x,y地点における波の高さの二回微分を行う事で、波の加速度を求めることができる。
    // xの加速度: (u(x + 1, y) - u(x, y)) - (u(x, y) - u(x - 1, y)) = u(x + 1, y) + (x -1 , y) - 2u(x , y)
    // yの加速度: (u(x, y + 1) - u(x, y)) - (u(x, y) - u(x, y - 1)) = u(x, y + 1) + (x , y - 1) - 2u(x , y)
    // 波の加速度 = xの加速度 + yの加速度 = u(x + 1, y) + (x -1 , y) + u(x, y + 1) + (x , y - 1) - 4u(x , y)
    float accel =
        get_height_from_buffer_texture(get_current_uv_using_offset(fragCoord, vec2(1.0, 0.0))) +
        get_height_from_buffer_texture(get_current_uv_using_offset(fragCoord, vec2(-1.0, 0.0))) +
        get_height_from_buffer_texture(get_current_uv_using_offset(fragCoord, vec2(0.0, 1.0))) +
        get_height_from_buffer_texture(get_current_uv_using_offset(fragCoord, vec2(0.0, -1.0))) +
        get_height_from_buffer_texture(get_current_uv_using_offset(fragCoord, vec2(0.0, 0.0))) * -4.0;

    float wave_speed = 0.5;
    accel *= wave_speed;
    float attenuation_rate = 0.98;
    float current_uv_velocity = get_velocity_from_buffer_texture(get_current_uv_using_offset(fragCoord, vec2(0.0, 0.0)));
    float updated_velocity = (current_uv_velocity + accel) * attenuation_rate;

    // note: 波を手動で生み出す
    bool is_mouse_clicked = iMouse.z > 0.0;
    if (is_mouse_clicked) {
        bool is_in_wave_generator = length(fragCoord - iMouse.xy) < 10.0;
        if (is_in_wave_generator) {
            updated_velocity += 1.0;
        }
    }

    // note: 波の伝播速度から波の高さを更新
    float current_uv_height = get_height_from_buffer_texture(get_current_uv_using_offset(fragCoord, vec2(0.0, 0.0)));
    float updated_height = (current_uv_height * attenuation_rate) + updated_velocity;
    fragColor = vec4(updated_height, updated_velocity, 0.0, 0.0);
}

