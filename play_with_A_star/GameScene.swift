import SpriteKit

class GameScene: SKScene {

    let tileSize: (width: UInt32, height: UInt32) = (3, 3)

    override func didMoveToView(view: SKView) {
        _createLayers()
        _createMap()
//        _createMarks()
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

    // rende layers

    private var _tileLayer: SKNode!

    private var _spritesLayer: SKNode!

    private var _pathDisplayLayer: SKNode!

    // marks

    private var _fromMarsk: SKSpriteNode!

    private var _toMarsk: SKSpriteNode!

    // map

    private var _tilesMap: TilesMap!

    // path find algorithm

    private var _bfs: BreadthFirstSearch!

    private var _astar: AStar!

    private func _createLayers() {
        _tileLayer = SKNode()
        _tileLayer.zPosition = 0
        _tileLayer.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(_tileLayer)

        _spritesLayer = SKNode()
        _spritesLayer.zPosition = 1
        self.addChild(_spritesLayer)

        _pathDisplayLayer = SKNode()
        _pathDisplayLayer.zPosition = 2
        _pathDisplayLayer.position = _tileLayer.position
        self.addChild(_pathDisplayLayer)
    }

    private func _createMarks() {
        _fromMarsk = SKSpriteNode(imageNamed: "fairy-walk-down-001")
        _toMarsk = SKSpriteNode(imageNamed: "dest_flag")

        _spritesLayer.addChild(_fromMarsk)
        _spritesLayer.addChild(_toMarsk)
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
        let to = (x: costMapData[0].count - 1, y: 0)

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
