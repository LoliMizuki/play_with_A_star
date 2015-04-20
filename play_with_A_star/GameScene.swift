import SpriteKit

class GameScene: SKScene {

    let tileSize: (width: UInt32, height: UInt32) = (10, 10)

    override func didMoveToView(view: SKView) {
        _createLayers()
        _createMap()
        _createFlags()

        _initSetting()

        _findAndDisplayPath()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch

        if _pickupFlagWithTouch(touch) { return }
        _tileMapWithTouch(touch)
    }

    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        _currentPickupFlag?.position = touch.locationInNode(_spritesLayer)
    }
   
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        _currentPickupFlag = nil
    }

    override func update(currentTime: NSTimeInterval) {
    }



    // MARK: Private

    // Rende Layers

    private var _tileLayer: SKNode!

    private var _spritesLayer: SKNode!

    private var _pathDisplayLayer: SKNode!

    // Flags

    private var _fromFlag: SKSpriteNode!

    private var _toFlag: SKSpriteNode!

    // Map

    private var _tilesMap: TilesMap!

    // Path Find Algorithm

    private var _bfs: BreadthFirstSearch!

    private var _astar: AStar!

    // States

    private var _currentPickupFlag: SKSpriteNode? = nil

    // functions

    private var _fromPosition: (x: Int, y: Int)! {
        didSet {
            let p = _fromPosition
            if let tile = _tilesMap.tileAt(x: p.x, y: p.y) {
                _fromFlag.position = tile.tileNode!.parent!.convertPoint(tile.tileNode!.position, toNode: self)
            }
        }
    }

    private var _toPosition: (x: Int, y: Int)! {
        didSet {
            let p = _toPosition
            if let tile = _tilesMap.tileAt(x: p.x, y: p.y) {
                _toFlag.position = tile.tileNode!.parent!.convertPoint(tile.tileNode!.position, toNode: self)
            }
        }
    }

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

    private func _createFlags() {
        let tileSize = _tilesMap.tiles[0][0].tileNode!.texture!.size()
        let tileEdgeSize = max(tileSize.width, tileSize.height)

        func findEdgeSizeInSprite(s: SKSpriteNode) -> CGFloat {
            let size = s.texture!.size()
            return max(size.width, size.height)
        }

        func setScale(s: SKSpriteNode) {
            let size = findEdgeSizeInSprite(s)
            s.setScale(tileEdgeSize/size)
        }

        _fromFlag = SKSpriteNode(imageNamed: "fairy-walk-down-001")
        _toFlag = SKSpriteNode(imageNamed: "dest_flag")

        setScale(_fromFlag)
        setScale(_toFlag)

        _spritesLayer.addChild(_fromFlag)
        _spritesLayer.addChild(_toFlag)
    }

    private func _findAndDisplayPath() {
        _clearPathLines()
        _drawPath(_findPath())
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

//        _bfs = BreadthFirstSearch(map: bfsMap, from: (x: 0, y: 0), to: (x: 9, y: 0))
//        return _bfs.path()

        _astar = AStar(costMapData: costMapData, from: _fromPosition, to: _toPosition)
        return _astar.path()
    }

    private func _initSetting() {
        _fromPosition = (x: 0, y: 0)
        _toPosition = (x: self._tilesMap.tiles[0].count - 1, y: 0)
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
        pathNode.strokeColor = SKColor.purpleColor()
        pathNode.lineWidth = 3

        _pathDisplayLayer.addChild(pathNode)
    }

    // MARK: Control & Interactive

    private func _pickupFlagWithTouch(touch: UITouch) -> Bool {
        let point = touch.locationInNode(_spritesLayer)

        if _fromFlag.containsPoint(point) { _currentPickupFlag = _fromFlag; return true }
        if _toFlag.containsPoint(point)   { _currentPickupFlag = _toFlag;   return true }

        return false
    }

    private func _tileMapWithTouch(touch: UITouch) {
        let point = touch.locationInNode(_tileLayer)

        if let t = _tilesMap.tileFromPoint(point) {
            t.cost = (t.cost + 1) % (_tilesMap.maxCost + 1)
            _findAndDisplayPath()
        }
    }
}
