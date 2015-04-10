import SpriteKit

class GameScene: SKScene {

    let tileSize: (width: UInt32, height: UInt32) = (10, 5)

    override func didMoveToView(view: SKView) {
        _createMap()
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
    }



    // MARK: Private

    private var _tilesMap: TilesMap!

    private var _bfs: BreadthFirstSearch!

    private var _pathNode: SKShapeNode?

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

        _bfs = BreadthFirstSearch(map: bfsMap, from: (x: 0, y: 0), to: (x: 9, y: 0))
        return _bfs.path()
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
}
