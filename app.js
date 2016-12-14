// Generated by CoffeeScript 1.11.1
var GameScene, config, engine, gameScene, loadingScene,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

config = Config.get();

config.toggleStats();

config.fillWindow();

engine = new Engine3D();

GameScene = (function(superClass) {
  extend(GameScene, superClass);

  function GameScene() {
    return GameScene.__super__.constructor.apply(this, arguments);
  }

  GameScene.prototype.init = function() {
    var box, dot, dotGeometry, dotMaterial, geometry, ground, i, items_per_row, j, k, l, last_lat, len, len1, len2, m, material, minAlt, point, postavarul, texture, vertices;
    this.common();
    postavarul = SaveObjectManager.get().items['poiana.converted'];
    minAlt = void 0;
    for (k = 0, len = postavarul.length; k < len; k++) {
      point = postavarul[k];
      if (point.alt < minAlt || (minAlt == null)) {
        minAlt = point.alt;
      }
    }
    dotMaterial = new THREE.PointsMaterial({
      size: 1,
      color: 'white'
    });
    dotGeometry = new THREE.Geometry;
    for (l = 0, len1 = postavarul.length; l < len1; l++) {
      point = postavarul[l];
      point.alt -= minAlt;
      dotGeometry.vertices.push(new THREE.Vector3(point.lat, point.alt, point.lon));
    }
    dot = new THREE.Points(dotGeometry, dotMaterial);
    this.scene.add(dot);
    box = new THREE.Box3().setFromObject(dot);
    dot.position.x = -box.max.x / 2;
    dot.position.z = -box.max.z / 2;
    i = 0;
    last_lat = postavarul[0].lon;
    items_per_row = 0;
    for (m = 0, len2 = postavarul.length; m < len2; m++) {
      point = postavarul[m];
      if (last_lat !== point.lon) {
        items_per_row = i;
        break;
      }
      i += 1;
    }
    console.log(postavarul.size());
    console.log(items_per_row);
    console.log(postavarul.size() / items_per_row);
    geometry = new THREE.PlaneBufferGeometry(box.max.x, box.max.z, 384, 396);
    vertices = geometry.attributes.position.array;
    i = -1;
    j = 0;
    while (i < vertices.length) {
      vertices[i] = postavarul[j].alt - minAlt;
      i += 3;
      j += 1;
    }
    geometry.computeVertexNormals();
    geometry.applyMatrix((new THREE.Matrix4).makeRotationX(-Math.PI / 2));
    material = new THREE.MeshPhongMaterial({
      color: 0x009900
    });
    texture = TextureManager.get().items['cloud'];
    texture.wrapS = texture.wrapT = THREE.RepeatWrapping;
    texture.repeat.set(10, 10);
    material = new THREE.MeshPhongMaterial({
      map: texture
    });
    ground = new THREE.Mesh(geometry, material);
    ground.position.y = -1000;
    return this.scene.add(ground);
  };

  GameScene.prototype.common = function() {
    engine.camera.position.set(0, 2500, 5000);
    Helper.orbitControls(engine);
    this.scene.add(Helper.light());
    return this.scene.add(Helper.ambientLight());
  };

  GameScene.prototype.tick = function(tpf) {};

  GameScene.prototype.doMouseEvent = function(event, raycaster) {};

  GameScene.prototype.doKeyboardEvent = function(event) {};

  return GameScene;

})(BaseScene);

gameScene = new GameScene();

loadingScene = new LoadingScene(['poiana.converted.save.json', 'assets/cloud.png'], function() {
  return engine.initScene(gameScene);
});

engine.addScene(loadingScene);

engine.initScene(loadingScene);

engine.render();
