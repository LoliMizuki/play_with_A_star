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
            _tilesMap.print()
            println("======")
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
    }



    // MARK: Private

    private var _tilesMap: TilesMap!

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
}
