import SpriteKit

class GameScene: SKScene {

    let tileSize: (width: UInt32, height: UInt32) = (10, 5)

    override func didMoveToView(view: SKView) {
        _createMap()

//        _springTester = SKSpriteNode(imageNamed: "fairy-walk-down-001")
//        self.addChild(_springTester)
//
//        _springTester.position = CGPoint(x: 100, y: 100)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let p = touch.locationInNode(self)

        if let t = _tilesMap.tileFromPoint(p) {
            t.property = t.property == Tile.Property.Path ? Tile.Property.Wall : Tile.Property.Path
        }

        _clearPathLines()

        let path = _findBFSPath()
        if path == nil { return }
        _drawPath(path!)
    }
   
    override func update(currentTime: CFTimeInterval) {
//        if _preTime == nil {
//            _preTime = currentTime
//            return
//        }
//
//        let timeStep = currentTime - _preTime!
//        _preTime = currentTime
//
//        _springWithProgress(&_progress,
//            velocity: &_velocity,
//            targetProgress: 1,
//            dampingRatio: 0.4,
//            angularFrequency: CGFloat(M_PI),
//            h: CGFloat(timeStep)
//        )
//
//
//        let tarPosX: CGFloat = self.size.width / 2
//        let startPosX: CGFloat = 100.0
//        let distance = tarPosX - startPosX
//
//        _springTester.position.x = startPosX + distance*_progress
    }



    // MARK: Private

    private var _tilesMap: TilesMap!

    private var _bfs: BreadthFirstSearch!

    private var _astar: AStar!

    private var _pathNode: SKShapeNode?

    private var _springTester: SKSpriteNode!

    private var _progress: CGFloat = 0

    private var _velocity: CGFloat = 0

    private var _preTime: CFTimeInterval?

    private func _createMap() {
        func randomTileProperty() -> Tile.Property { return Tile.Property.fromValue(arc4random_uniform(2)) }

        var mapData = Array<Array<Tile.Property>>()

        for ih in Range(start: 0, end: tileSize.height) {
            var colArray = Array<Tile.Property>()
            for iw in Range(start: 0, end: tileSize.width) {
                colArray.append(randomTileProperty())
            }
            mapData.append(colArray)
        }

        _tilesMap = TilesMap(data: mapData, parent: self, parentSize: self.size)
    }

    private func _findBFSPath() -> [(x: Int, y: Int)]? {
        var bfsMap = [[Int]]()

        for tilesInRow in _tilesMap.tiles {
            var mapInRow = [Int]()
            for t in tilesInRow {
                if t.property == Tile.Property.Path {
                    mapInRow.append(0)
                } else {
                    mapInRow.append(1)
                }
            }

            bfsMap.append(mapInRow)
        }

//        _bfs = BreadthFirstSearch(map: bfsMap, from: (x: 0, y: 0), to: (x: 9, y: 0))
//        return _bfs.path()

        _astar = AStar(map: bfsMap, from: (x: 0, y: 0), to: (x: 9, y: 0))
        return _astar.path()
    }

    private func _clearPathLines() {
        if _pathNode != nil { _pathNode!.removeFromParent(); _pathNode = nil }
    }

    private func _drawPath(path: [(x: Int, y: Int)]) {
        _clearPathLines()

        var pathPoints = [CGPoint]()
        for p in path {
            pathPoints.append(_tilesMap.tiles[p.y][p.x].tileNode!.position)
        }

        let drawPath = CGPathCreateMutable()
        CGPathAddLines(drawPath, nil, pathPoints, pathPoints.count)

        _pathNode = SKShapeNode(path: drawPath)
        _pathNode!.strokeColor = SKColor.redColor()
        _pathNode!.lineWidth = 3
        self.addChild(_pathNode!)
        _pathNode!.position = CGPoint(x: 62.5/2, y: 62.5/2)
    }


    // test spring
    // zeta - damping ratio     (input) 0 ~ 1
    // omega - angular frequency (input) 0 ~ 2*PI ???
    // h     - time step         (input)

    private func _springWithProgress(inout progress: CGFloat,
        inout velocity: CGFloat,
        targetProgress: CGFloat,
        dampingRatio: CGFloat,
        angularFrequency: CGFloat,
        h: CGFloat
    ) {
        let x = progress
        let v = velocity
        let xt = targetProgress

        let f = 1.0 + 2.0 * h * dampingRatio * angularFrequency
        let oo = angularFrequency * angularFrequency
        let hoo = h * oo
        let hhoo = h * hoo
        let detInv = 1.0 / (f + hhoo)
        let detX = f * x + h * v + hhoo * xt
        let detV = v + hoo * (xt - x)
        progress = detX * detInv
        velocity = detV * detInv
    }
}
