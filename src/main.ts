import { vec3, vec4 } from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import { setGL } from './globals';
import ShaderProgram, { Shader } from './rendering/gl/ShaderProgram';
import Cube from './geometry/Cube';
import Drawable from './rendering/gl/Drawable';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.

const controls = {
  tesselations: 5,
  'Load Scene': loadScene, // A function pointer, essentially
  shape: 'icosphere',
  shader: 'custom',
  color: [1.0, 0.0, 0.0],
};

let icosphere: Icosphere;
let square: Square;
let cube: Cube;

let prevTesselations: number = 5;

// for nicer gui control
let currentShape: Drawable;
let currentShader: ShaderProgram;
let palette: any = null;
let lambert: ShaderProgram;
let custom: ShaderProgram;
let gui: any;

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();

  cube = new Cube((vec3.fromValues(0, 0, 0)));
  cube.create();

}

function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  function updateCurrShape() {
    switch (controls.shape) {
      case 'cube':
        currentShape = cube;
        break;
      case 'square':
        currentShape = square;
        break;
      case 'icosphere':
      default:
        currentShape = icosphere;
        break;
    }
  }

  function updateCurrShader() {
    switch (controls.shader) {
      case 'lambert':
        currentShader = lambert;
        break;
      case 'custom':
      default:
        currentShader = custom;
        break;
    }
  }

  function toggleColorOn() {
    if (palette) {
      gui.remove(palette);
      palette = null;
    }

    if (controls.shader === 'lambert') {
      palette = gui.addColor(controls, 'color');
    }
  }

  // Add controls to the gui
  gui = new DAT.GUI();
  gui.add(controls, 'tesselations', 0, 8).step(1);
  gui.add(controls, 'Load Scene');

  gui.add(controls, 'shape', ['cube', 'icosphere', 'square']).onChange(() => {
    updateCurrShape();
  });

  gui.add(controls, 'shader', ['lambert', 'custom']).onChange(() => {
    updateCurrShader();
    toggleColorOn();
  });

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement>document.getElementById('canvas');
  const gl = <WebGL2RenderingContext>canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);

  lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/lambert-frag.glsl')),
  ]);

  // custom shader
  custom = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/custom-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/custom-frag.glsl')),
  ]);

  updateCurrShape();
  updateCurrShader();
  toggleColorOn();

  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();

    if (controls.tesselations != prevTesselations) {
      prevTesselations = controls.tesselations;
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations);
      icosphere.create();
    }

    const time = (Date.now() * 0.001) % 1000.0;
    custom.setTime(time);

    let color = vec4.fromValues(
      controls.color[0] / 255.0,
      controls.color[1] / 255.0,
      controls.color[2] / 255.0,
      1.0
    );

    renderer.render(camera, currentShader, [currentShape], color);
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function () {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}

main();
