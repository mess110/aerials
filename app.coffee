config = Config.get()

# config.toggleDebug()
config.toggleStats()
config.fillWindow()
config.transparentBackground = true

engine = new Engine3D()

class GameScene extends BaseScene
  init: ->
    @common()

    postavarul = SaveObjectManager.get().items['poiana.converted']

    for point in postavarul
      minAlt = point.alt if point.alt < minAlt || !minAlt?

    dotMaterial = new (THREE.PointsMaterial)(size: 2, color: 'green')
    dotGeometry = new (THREE.Geometry)

    for point in postavarul
      point.alt -= minAlt

      dotGeometry.vertices.push new (THREE.Vector3)(point.lat, point.alt, point.lon)

    dot = new (THREE.Points)(dotGeometry, dotMaterial)
    @scene.add dot

    box = new THREE.Box3().setFromObject(dot)
    dot.position.x = - box.max.x / 2
    dot.position.z = - box.max.z / 2

  common: ->
    engine.camera.position.set 0, 2500, 5000
    Helper.orbitControls(engine)

    @scene.add Helper.ambientLight()
    @scene.add Helper.ambientLight()
    @scene.add Helper.ambientLight()

  tick: (tpf) ->

  doMouseEvent: (event, raycaster) ->

  doKeyboardEvent: (event) ->

gameScene = new GameScene()

loadingScene = new LoadingScene([
  'poiana.converted.save.json'
], () ->
  engine.initScene(gameScene)
)
engine.addScene(loadingScene)
engine.initScene(loadingScene)

engine.render()
