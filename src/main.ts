import { vec3, vec4, mat4} from 'gl-matrix';
import Stats from 'stats.js';
import * as dat from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import { setGL } from './globals';
import ShaderProgram, { Shader } from './rendering/gl/ShaderProgram';
import Cube from './geometry/Cube';
import Drawable from './rendering/gl/Drawable';
import OBJ from './geometry/OBJObject';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.

const controls = {
  shape: 'icosphere',
  shader: 'fireball',
  color: [131, 24, 24],
  flameIntensity: 6.0,
  flameLength: 0.6,
  speed: 3.0,
};

let icosphere: Icosphere;
let icosphere1: Icosphere;
let icosphere2: Icosphere;

let square: Square;
let cube: Cube;

// for nicer gui control
let currentShape: Drawable;
let currentShader: ShaderProgram;
let palette: any = null;
let lambert: ShaderProgram;
let custom: ShaderProgram;

let dragonStar: OBJ;
let fireball: ShaderProgram; //icosphere
let effect: ShaderProgram; // icosphere1
let star: ShaderProgram; // icosphere2
let bgShader: ShaderProgram;
let gui: any;

async function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, 5); // star
  icosphere.create();

  icosphere1 = new Icosphere(vec3.fromValues(0, 0, 0), 1, 5); // fireball
  icosphere1.create();

  icosphere2 = new Icosphere(vec3.fromValues(0, -0.5, 0), 1, 5); // effect
  icosphere2.create();

  square = new Square(vec3.fromValues(0, 0, 0)); // for bg
  square.create();

  dragonStar = new OBJ(vec3.fromValues(0, 0, 0));
  await dragonStar.loadFromOBJ("./dragon_star.obj");
  dragonStar.create();

}

function main() {
  // Initial display for framerate
  const stats = new Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

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
  gui = new dat.GUI();

  gui.add(controls, 'flameIntensity', 6.0, 12.0).step(0.1).name('Flame Intensity');
  gui.add(controls, 'flameLength', 0.6, 2.0).step(0.1).name('Flame Length');
  gui.add(controls, 'speed', 1.0, 10.0).step(0.1).name("Star Speed!");

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
  // changed to navy bg
  renderer.setClearColor(0.02, 0.05, 0.15, 1);
  gl.enable(gl.DEPTH_TEST);

  gl.enable(gl.BLEND);
  gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

  lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/lambert-frag.glsl')),
  ]);

  // custom shader
  custom = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/custom-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/custom-frag.glsl')),
  ]);

  fireball = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/fireball-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/fireball-frag.glsl')),
  ]);

  effect = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/effect-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/effect-frag.glsl')),
  ]);

  star = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/star-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/star-frag.glsl')),
  ]);

  bgShader = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/bg-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/bg-frag.glsl')),
  ]);

  toggleColorOn();

  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();

    const time = (Date.now() * 0.001) % 1000.0;
    custom.setTime(time);
    fireball.setTime(time);
    effect.setTime(time);
    star.setTime(time);
    bgShader.setTime(time);
    fireball.setFlameIntensity(controls.flameIntensity);
    fireball.setFlameLength(controls.flameLength);
    star.setSpeed(controls.speed);

    let color = vec4.fromValues(
      controls.color[0] / 255.0,
      controls.color[1] / 255.0,
      controls.color[2] / 255.0,
      1.0
    );

    // disabling stuff temporarily

    //bg stuff
    gl.disable(gl.DEPTH_TEST); //disable temp
    bgShader.use();
    bgShader.setModelMatrix(mat4.create());
    bgShader.setViewProjMatrix(mat4.create());
    bgShader.draw(square);
    gl.enable(gl.DEPTH_TEST); // emable again

    // scene
    let tempColor = vec4.fromValues(0.0, 255.0, 255.0, 1.0);
    // renderer.render(camera, star, [icosphere], tempColor);

    renderer.render(camera, star, [dragonStar], tempColor);
    renderer.render(camera, fireball, [icosphere1], tempColor);
    renderer.render(camera, effect, [icosphere2], tempColor);

    // renderer.render(camera, currentShader, [currentShape], color);

    if (controls.shape !== 'icosphere') {
      // This is the color that will actually be used by the lambert/custom shader
      let activeColor = vec4.fromValues(
        controls.color[0] / 255.0,
        controls.color[1] / 255.0,
        controls.color[2] / 255.0,
        1.0
      );
      renderer.render(camera, currentShader, [currentShape], activeColor);
    }

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
