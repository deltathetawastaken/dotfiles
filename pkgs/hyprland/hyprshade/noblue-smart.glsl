precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform bool makeWarmer; // Uniform to control whether to apply warm effect

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);

    // Check if the pixel is blue-ish but not white
    if (pixColor.b > 0.1 && pixColor.r < 0.7 && pixColor.g < 0.7) {
        // Remove more blue from blue-ish colors
        pixColor.b *= 0.1;
    } else {
        // Apply your original transformations to non-blue colors
        pixColor.r *= 1.2;
        pixColor.g *= 0.9;
        // Note: We don't multiply pixColor.b here since we only want to affect blue
        // components in blue-ish colors, not overall.
    }

    // Apply the warm effect if makeWarmer is true
    if (false) {
        pixColor.r *= 1.2;
        pixColor.g *= 0.8;
        // You can adjust these factors to control the warmth effect
    }

    gl_FragColor = pixColor;
}
