
/*

Vector field visualization script.


(relative btw)
Red channel indicates divergence at each point

Blue channel indicates curl at each point

Green channel indicates magnitude of each vector


*/

uniform float dscale;
uniform float doffset;

uniform float cscale;
uniform float coffset;

uniform float mscale;
uniform float moffset;



uniform float sx;
uniform float sy;
uniform float w;
uniform float h;

uniform float CAP;


float F(float x, float y){   return y*y - x;   }
float G(float x, float y){   return x*x - y;  }

float df_dx(float x, float y){  return -1;  }
float df_dy(float x, float y){  return 2*y;  }

float dg_dx(float x, float y){  return 2*x;  }
float dg_dy(float x, float y){  return -1;  }



float magnitude(float x, float y){
    vec2 mag;
    mag.x = F(x,y);
    mag.y = G(x,y);
    return (length(mag)-moffset)/mscale;
}


float curl(float x, float y){
    return ((dg_dx(x,y) - df_dy(x,y))-coffset)/cscale;
}

float divergence(float x, float y){
    return ((df_dx(x,y) + dg_dy(x,y))-doffset)/dscale;
}



vec2 plotCords(float X, float Y, float sx, float sy, float w, float h){
    Y = CAP - Y;//invert, because in love2d, y=0 is at top
    vec2 ret = vec2(0.0,0.0);
    ret[0] = w * (X / CAP) + sx;
    ret[1] = h * (Y / CAP) + sy;

    return ret; 
}



vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec2 vc;

    vc = plotCords(screen_coords.x, screen_coords.y, sx, sy, w, h);

    vec4 mod;

    mod.x = 0.5-(divergence(vc.x, vc.y)); // r   For some reason this is -inf :/
    mod.y = 0.5-(curl(vc.x,vc.y)); // b               NVM fixed
    mod.z = 0.5-(magnitude(vc.x, vc.y)); // g

    mod.w = 1;

    vec4 tc;
    tc = Texel(tex, texture_coords);
    
    return mod * color * tc;
}


