precision highp float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);

    // Apply night-shift effect by reducing blue and enhancing red/orange
    // red
    pixColor[0] *= 1.1;
    // green
    pixColor[1] *= 0.9;
    // blue
    pixColor[2] *= 0.7;

    gl_FragColor = pixColor;
}

