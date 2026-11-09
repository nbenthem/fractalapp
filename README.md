# Fractal Sound App

A small fractal explorer that runs in your browser. Pick a fractal, move your pointer and see how the shape changes. You can also zoom in, follow an orbit or hold down on the image to add sound.

## Getting started

Open [fractalapp.html](./fractalapp.html) in a browser. That's it: there's nothing to install, and you don't need a server or an internet connection.

Try moving your pointer over the image, then choose another fractal or palette from the menus. To hear the sound, hold down on the image and move around; release to stop it.


You'll need a modern browser with JavaScript, WebGL, Canvas 2D and Web Audio. If the escape-time fractals don't appear and you see a WebGL warning, check your browser's graphics settings or try another browser. The constructed shapes use Canvas 2D and can still be displayed without WebGL.

## How to use

- **Fractal and palette:** choose from ten fractals and three palettes: Neon, Fire and Ocean. Selecting a different fractal takes you back to its starting view and parameters. Escape-time interiors stay dark; the Koch snowflake has a colored interior.
- **Pointer:** move it over the image to change the shape. The transition follows the pointer smoothly; it doesn't drag the view.
- **Coordinates:** the axes and information panel show where you are in the current view. Coordinates follow the pointer and are read-only; the zoom value is relative to the fractal's starting view.
- **Orbit:** for Mandelbrot, Burning Ship and Tricorn, use the switch beside the menus to show or hide the orbit under the pointer. Your choice stays in effect if you switch fractals during the same session.
- **Information:** the panel shows the fractal's name, attribution, equation or construction rule, current values and a short explanation. Use **−** to collapse the details; the name and coordinates stay visible.
- **Help and language:** select **i** for a quick guide; press Escape to close it. The language button switches between Spanish and English when the information panel is open.
- **Sound:** hold down on the image to play, and release to fade out. Use the round sound button to mute or unmute it.

The app starts in Spanish, with sound and the orbit switch enabled. Settings and the view aren't saved when you reload. There is currently no automated test suite.

### Navigation controls

- **Arrow buttons / arrow keys:** pan. Hold a movement button or key to continue moving.
- **+ / − buttons or keyboard keys:** zoom in / out. Holding continues zooming.
- **Home button or `0`:** reset the camera to the selected fractal's initial view.
- **Mouse wheel:** zoom around the pointer.
- **Double-click the image:** reset the camera.
- **Round movement-pad toggle:** hide or show the pad without moving the toggle.

The navigation controls change which part of the plane you see. Moving the pointer changes the fractal itself.

You can still interact with the image through the non-button parts of the information panel. When the panel itself has keyboard focus, the up and down arrows scroll its contents instead of panning.

## Fractals and pointer behavior

In the escape-time fractals, `z` and `c` are complex numbers. Their real and imaginary parts are represented on the x and y axes; `z` isn't a third spatial axis.

| Fractal | Rule | Pointer effect |
| --- | --- | --- |
| Julia | `z(n+1) = z(n)² + c` | Each pixel is an initial `z₀`; the pointer changes `c` for the whole image. |
| Mandelbrot | `z(n+1) = z(n)² + c` | Each pixel is a value of `c`; the pointer changes the shared initial `z₀`. |
| Burning Ship | `z(n+1) = (\|Re(z(n))\| − i\|Im(z(n))\|)² + c` | Each pixel is `c`; the pointer changes the shared `z₀`. The app uses this reflected convention consistently. |
| Tricorn | `z(n+1) = conjugate(z(n))² + c` | Each pixel is `c`; the pointer changes the shared `z₀`. |
| Multibrot | `z(n+1) = z(n)^d + c` | Horizontal position changes exponent `d`; vertical position changes the imaginary part of `z₀`. Non-integer powers use the principal complex branch. |
| Julia z³ | `z(n+1) = z(n)³ + c` | Each pixel is `z₀`; the pointer changes `c`. |
| Sierpiński triangle | Three smaller triangles are generated at each step. | Horizontal position changes their scale; vertical position rotates each subdivision. |
| Koch snowflake | Each side is replaced by four segments forming a peak. | Horizontal position grows the next level of detail; vertical position changes the peak angle. |
| Dragon curve | A line follows a paper-folding pattern of left and right turns. | Horizontal position changes the turning angle; vertical position rotates the shape. |
| Fractal tree | Each branch produces two shorter branches. | Horizontal position changes the branching angle; vertical position changes the length ratio. |

One detail worth knowing: for Mandelbrot, Burning Ship and Tricorn, moving away from the screen center changes `z₀`. That gives you variations of the parameter-space image, not always the classical set. To return to the classical starting value, put the pointer at the center and let the movement settle: `z₀` will be zero.

### Orbit

For Mandelbrot, Burning Ship and Tricorn, the point under the pointer sets `c`. The circle marks the starting value `z₀`. From there, each point shows what happens when the equation is applied again, keeping `c` fixed.

You'll see up to 12 steps, or fewer if the sequence escapes. The panel shows `c` and, when available, the first result `z₁`. The orbit uses the same scale as the image, but its points are `z` values; the image underneath represents `c` values.

### Colors and accuracy

In escape-time fractals, colors show how quickly a sequence crosses the rendering threshold. A dark point hasn't escaped within the steps calculated—it isn't proof that it belongs to the infinite set. The app uses more steps as you zoom, up to 900, but GPU precision and the finite calculation limit the detail you can see.

The constructed shapes also use a finite number of steps. As you move the pointer, some become variations or intermediate stages rather than their classical forms.

## Sound

The sound follows the pointer's **screen position**. Move up or down to change the note; move left or right to change its brightness. Each fractal has its own pitch and harmony profile, and the notes come from a pentatonic scale.

These profiles are musical choices, not sounds calculated from the fractal's equation or orbit. Under the hood, sine oscillators, a low-pass filter and smooth transitions create the sound. It starts enabled on each page load, but the browser only starts audio after an interaction.

## Technical details

- **Implementation:** one standalone HTML file containing styles, markup, JavaScript and GLSL; no external libraries or assets.
- **Rendering:** WebGL fragment shader for escape-time fractals; a Canvas 2D overlay for constructed fractals, axes, pointer marker and orbit. The render loop uses `requestAnimationFrame`.
- **Resolution:** the WebGL canvas caps device-pixel ratio at 1.5; the overlay caps it at 2. This balances detail and performance and can appear softer than native resolution on high-density screens.
- **Zoom limits:** escape-time scale is clamped to `0.00005–4`; constructed-fractal scale to `0.15–4`. The camera center is clamped to `[-3, 3]` on each axis.
- **Startup selection:** a recognized URL fragment can choose a fractal, for example `fractalapp.html#tricorn`. Valid IDs are `julia`, `mandelbrot`, `ship`, `tricorn`, `multibrot`, `julia3`, `sierpinski`, `koch`, `dragon` and `tree`. Without a valid fragment, Julia is selected. Choosing from the menu does not update the URL.
- **Localization:** Spanish and English strings are maintained in the `TEXT` object in the HTML file.
- **Privacy and storage:** the app has no configured network requests, account system or persistent storage. It runs locally in the browser.

### Troubleshooting

- **No sound:** hold the image, check the sound button and system volume, and ensure the browser allows audio. Moving the pointer alone does not play sound.
- **No escape-time image:** check the WebGL warning, browser graphics settings and developer console. The app has no CPU rendering fallback for these fractals.
- **Coordinates are missing:** move the pointer over the image; values clear when it leaves.
- **Orbit switch is missing:** it is only offered for Mandelbrot, Burning Ship and Tricorn.
- **View is unfamiliar:** press `0`, use the home button, or double-click the image to reset the camera.
- **Slow or pixelated rendering:** reduce browser window size or zoom out. Performance and precision depend on the browser and graphics hardware.
