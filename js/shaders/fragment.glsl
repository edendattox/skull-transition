uniform float time;
uniform sampler2D noiseTexture;
uniform float progress;
uniform vec4 resolution;
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
varying vec2 vScreenSpace;
varying vec3 vViewDirection;


float PI = 3.141592653589793238;

float threshold(float edge0, float edge1, float x) {
        return clamp( (x - edge0) / (edge1 - edge0), 0.0, 1.0);
}

float hash(vec3 p) // replace this by something better
{
        p = fract( p*0.3183099+.1 );
        p *= 17.0;
        return fract( p.x*p.y*p.z*(p.x+p.y+p.z) );
}

float noise( in vec3 x )
{
        vec3 i = floor(x);
        vec3 f = fract(x);
        f = f*f*(3.0-2.0*f);

        return mix(mix (mix( hash(i+vec3 (0,0,0)),
                hash (i+vec3(1,0,0)), f.x),
                mix( hash(i+vec3(0,1,0)),
                hash (i+vec3(1,1,0)),f.x),f.y),
                mix (mix( hash(i+vec3(0,0,1)),
                hash (i+vec3(1,0,1)),f.x),
                mix( hash(i+vec3 (0,1,1)),
                hash (i+vec3(1,1,1)),f.x),f.y),f.z);
}

float rand (float n){return fract(sin(n) * 43758.5453123);}

float noise(float p) {
        float fl = floor(p);
        float fc = fract(p);
        return mix(rand (fl), rand(fl + 1.0), fc);
}



void main() {

  float light = dot(vNormal, normalize(vec3( 1.)));
  

  // noise 
  float ttt = texture2D(noiseTexture, 0.5*(vScreenSpace + 1.)).r;
  // strokes
 
  float stroke = cos((vScreenSpace.x - vScreenSpace.y)*800.);

  float smallnoise = noise(500.*vec3(vScreenSpace, 1.));
  float bignoise = noise(5.*vec3(vScreenSpace, 4.));
  float fresnel = 1. - dot(vNormal, -vViewDirection);
  fresnel = fresnel*fresnel*fresnel;


  stroke += (smallnoise*2. -1.) + (bignoise*2. - 1.) ;

  // light += (bignoise*2. - 1.);

  stroke = 1. - smoothstep(1. * light - 0.2, 1. * light + 0.2, stroke) - 0.5*fresnel;
  

  // changes the color of the object
  // smoothstep is to flawlessly animate
  float stroke1 = 1. - smoothstep(2. * light - 3., 2. * light + 3., stroke) ;
  
  float temp = progress;
  temp += (2.*ttt - 1.) * 0.2;


  // getting the distance form center from the object
  float distanceFromCenter = length(vScreenSpace);
  temp = smoothstep(temp - 0.005, temp, distanceFromCenter);

  gl_FragColor = vec4(vScreenSpace, 0., 1.);
  gl_FragColor = vec4(vNormal, 1.);
  float finalLook = mix(stroke1, stroke, temp);
  gl_FragColor = vec4(vec3(finalLook), 1.);
  // gl_FragColor = vec4(vec3(distanceFromCenter), 1.);
  // gl_FragColor = vec4(vec3(temp), 1.);
  // gl_FragColor = vec4(vec3(progress), 1.);
  // gl_FragColor = vec4(vec3(light), 1.);

}


// grey textures

/*
*  so if we change light in stroke smooth step we will be getting ther color between whtie grey
*/ 


  // float light = dot(vNormal, normalize(vec3(1.)));

  // // strokes
 
  // float stroke = cos((vScreenSpace.x - vScreenSpace.y)*500.);

  // float smallnoise = noise(500.*vec3(vScreenSpace, 1.));
  // float bignoise = noise(5.*vec3(vScreenSpace, 1.));

  // stroke += (smallnoise*2. -1.) + (bignoise*2. - 1.);

  // light += (bignoise*2. - 1.);

  // stroke = smoothstep(light - 1., light + 3. ,stroke);

  // gl_FragColor = vec4(vScreenSpace, 0., 1.);
  // gl_FragColor = vec4(vNormal, 1.);
  // // gl_FragColor = vec4(vec3(light), 1.);
  // gl_FragColor = vec4(vec3(stroke), 1.);

