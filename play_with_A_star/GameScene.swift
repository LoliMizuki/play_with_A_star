import SpriteKit

class GameScene: SKScene {

    let tileSize: (width: UInt32, height: UInt32) = (10, 5)

    override func didMoveToView(view: SKView) {
        _createLayers()
        _createMap()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let point = touch.locationInNode(_tileLayer)

        if let t = _tilesMap.tileFromPoint(point) {
            t.cost = (t.cost + 1) % (_tilesMap.maxCost + 1)

            _clearPathLines()
            _drawPath(_findPath())
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
    }



    // MARK: Private

    private var _tileLayer: SKNode!

    private var _pathDisplayLayer: SKNode!

    private var _tilesMap: TilesMap!

    private var _bfs: BreadthFirstSearch!

    private var _astar: AStar!

    private var _springTester: SKSpriteNode!

    private var _progress: CGFloat = 0

    private var _velocity: CGFloat = 0

    private var _preTime: CFTimeInterval?

    private func _createLayers() {
        _tileLayer = SKNode()
        _tileLayer.zPosition = 0
        _tileLayer.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(_tileLayer)

        _pathDisplayLayer = SKNode()
        _pathDisplayLayer.zPosition = 1
        _pathDisplayLayer.position = _tileLayer.position
        self.addChild(_pathDisplayLayer)
    }

    private func _createMap() {
        func randomCost() -> Int { return Int(arc4random_uniform(3)) }

        var mapCostData = [[Int]]()

        for ih in Range(start: 0, end: tileSize.height) {
            var col = [Int]()
            for iw in Range(start: 0, end: tileSize.width) {
                col.append(randomCost())
            }
            mapCostData.append(col)
        }

        _tilesMap = TilesMap(mapCostData: mapCostData, parent: _tileLayer, parentSize: self.size)
    }

    private func _findPath() -> [(x: Int, y: Int)]? {
        var costMapData = [[Int]]()

        for tilesInRow in _tilesMap.tiles {
            var row = [Int]()
            for t in tilesInRow {
                row.append(t.cost)
            }

            costMapData.append(row)
        }

        let from = (x: 0, y: 0)
        let to = (x: 9, y: 0)

//        _bfs = BreadthFirstSearch(map: bfsMap, from: (x: 0, y: 0), to: (x: 9, y: 0))
//        return _bfs.path()

        _astar = AStar(costMapData: costMapData, from: from, to: to)
        return _astar.path()
    }

    private func _clearPathLines() {
        _pathDisplayLayer.removeAllChildren()
    }

    private func _drawPath(path: [(x: Int, y: Int)]?) {
        if path == nil { return }

        var pathPoints = [CGPoint]()
        for p in path! {
            pathPoints.append(_tilesMap.tiles[p.y][p.x].tileNode!.position)
        }

        let drawPath = CGPathCreateMutable()
        CGPathAddLines(drawPath, nil, pathPoints, pathPoints.count)

        var pathNode = SKShapeNode(path: drawPath)
        pathNode.strokeColor = SKColor.redColor()
        pathNode.lineWidth = 3

        _pathDisplayLayer.addChild(pathNode)
    }
}
