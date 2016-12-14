config = Config.get()

# config.toggleDebug()
config.toggleStats()
config.fillWindow()
# config.transparentBackground = true

engine = new Engine3D()

class GameScene extends BaseScene
  init: ->
    @common()

    postavarul = SaveObjectManager.get().items['poiana.converted']
    minAlt = undefined
    for point in postavarul
      minAlt = point.alt if point.alt < minAlt || !minAlt?

    dotMaterial = new (THREE.PointsMaterial)(size: 1, color: 'white')
    dotGeometry = new (THREE.Geometry)

    for point in postavarul
      point.alt -= minAlt

      dotGeometry.vertices.push new (THREE.Vector3)(point.lat, point.alt, point.lon)

    dot = new (THREE.Points)(dotGeometry, dotMaterial)
    @scene.add dot

    box = new THREE.Box3().setFromObject(dot)
    dot.position.x = - box.max.x / 2
    dot.position.z = - box.max.z / 2

    i = 0
    last_lat = postavarul[0].lon
    items_per_row = 0
    for point in postavarul
      if last_lat != point.lon
        items_per_row = i
        break
      i += 1
    console.log postavarul.size()
    console.log items_per_row
    console.log postavarul.size() / items_per_row

    geometry = new (THREE.PlaneBufferGeometry)(box.max.x, box.max.z, 384, 396)
    vertices = geometry.attributes.position.array
    i = -1
    j = 0
    while i < vertices.length
      vertices[i] = postavarul[j].alt - minAlt
      i += 3
      j += 1
    geometry.computeVertexNormals()
    geometry.applyMatrix (new (THREE.Matrix4)).makeRotationX(-Math.PI / 2)
    material = new (THREE.MeshPhongMaterial)(color: 0x009900)
    texture = TextureManager.get().items['cloud']
    texture.wrapS = texture.wrapT = THREE.RepeatWrapping
    texture.repeat.set( 10, 10 )
    material = new (THREE.MeshPhongMaterial)(map: texture)
    ground = new (THREE.Mesh)(geometry, material)
    ground.position.y = -1000
    @scene.add ground

  common: ->
    engine.camera.position.set 0, 2500, 5000
    Helper.orbitControls(engine)

    # @scene.add Helper.ambientLight()
    # @scene.add Helper.ambientLight()
    @scene.add Helper.light()
    @scene.add Helper.ambientLight()

  tick: (tpf) ->

  doMouseEvent: (event, raycaster) ->

  doKeyboardEvent: (event) ->

gameScene = new GameScene()

loadingScene = new LoadingScene([
  'poiana.converted.save.json'
  'assets/cloud.png'
], () ->
  engine.initScene(gameScene)
)
engine.addScene(loadingScene)
engine.initScene(loadingScene)

engine.render()
