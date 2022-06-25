vec2 get_current_uv_using_offset(vec2 fragCoord, vec2 offset){
    vec2 pixel = 1.0/iResolution.xy;
   	vec2 uv = fragCoord.xy * pixel;
    return uv + pixel * offset;
}

float get_velocity_from_buffer_texture(vec2 uv){
    return texture(iChannel0, uv).y;
}

float get_height_from_buffer_texture(vec2 uv){
    return texture(iChannel0, uv).x;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
    fragColor = vec4(
        get_height_from_buffer_texture(
            get_current_uv_using_offset(fragCoord, vec2(0.0, 0.0))
        ),
        get_velocity_from_buffer_texture(
            get_current_uv_using_offset(fragCoord, vec2(0.0, 0.0))
        ),
        0.0,
        0.0
    );
}
