import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";
import fragment from "./shaders/fragment";
import vertex from "./shaders/vertex";
import noiseTexture from "../img/noise.png";
import * as dat from "dat.gui";
import face from "../face.glb";

export default class sketch {
  constructor(options) {
    this.time = 0;
    this.scene = new THREE.Scene();
    this.container = options.dom;

    this.width = this.container.offsetWidth;
    this.height = this.container.offsetHeight;

    this.camera = new THREE.PerspectiveCamera(
      70,
      this.width / this.height,
      0.001,
      1000
    );

    this.loader = new GLTFLoader();

    this.camera.position.set(0, 0, 18);
    this.camera.updateProjectionMatrix();

    this.renderer = new THREE.WebGLRenderer({
      antialias: true,
    });
    this.renderer.setClearColor(0xffffff, 1);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.physicallyCorrectLights = true;
    this.renderer.outputEncoding = THREE.sRGBEncoding;
    this.container.appendChild(this.renderer.domElement);

    this.controls = new OrbitControls(this.camera, this.renderer.domElement);

    // this.time = 0;
    this.isPlaying = true;

    this.addObjects();
    this.resize();
    this.setupResize();
    this.render();
    this.settings();

    this.loader.load(face, (gltf) => {
      let model = gltf.scene.children[2];
      let s = 4;
      model.scale.set(s, s, s);
      model.position.set(0, 2, 0);
      console.log(model);
      this.scene.add(model);
      model.material = this.material;
    });
  }

  settings() {
    let that = this;
    this.settings = {
      progress: 0,
    };
    this.gui = new dat.GUI();
    this.gui.add(this.settings, "progress", 0, 1, 0.01);
  }

  setupResize() {
    window.addEventListener("resize", this.resize.bind(this));
  }

  settings() {
    let that = this;
    this.settings = {
      progress: 0,
    };
    this.gui = new dat.GUI();
    this.gui.add(this.settings, "progress", 0, 1, 0.001);
  }

  resize() {
    this.width = this.container.offsetWidth;
    this.height = this.container.offsetHeight;
    this.renderer.setSize(this.width, this.height);
    this.camera.aspect = this.width / this.height;
  }

  addObjects() {
    this.geometry = new THREE.SphereBufferGeometry(1, 10, 10);

    this.material = new THREE.MeshBasicMaterial({
      color: "red",
    });

    this.material = new THREE.ShaderMaterial({
      vertexShader: vertex,
      fragmentShader: fragment,
      uniforms: {
        time: { value: 0 },
        progress: { value: 0 },
        noiseTexture: { value: new THREE.TextureLoader().load(noiseTexture) },
        resolution: { value: new THREE.Vector4() },
      },
      side: THREE.DoubleSide,
      // wireframe: true,
    });

    this.mesh = new THREE.Mesh(this.geometry, this.material);
    // this.scene.add(this.mesh);
  }

  stop() {
    this.isPlaying = false;
  }

  play() {
    if (!this.isPlaying) {
      this.render();
      this.isPlaying = true;
    }
  }

  render() {
    if (!this.isPlaying) return;
    this.time += 0.01;
    this.mesh.rotation.x = this.time;
    this.mesh.rotation.y = this.time;

    this.material.uniforms.time.value = this.time;
    this.material.uniforms.progress.value = this.settings.progress;
    this.renderer.render(this.scene, this.camera);
    window.requestAnimationFrame(this.render.bind(this));
  }
}

new sketch({
  dom: document.getElementById("container"),
});
