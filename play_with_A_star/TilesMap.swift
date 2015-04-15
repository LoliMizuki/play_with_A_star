import Foundation
import SpriteKit

public class TilesMap {

    public let maxCost = 2

    public private(set) var tiles = [[Tile]]()

    public private(set) var parentNode: SKNode

    init(
        mapCostData: [[Int]],
        parent: SKNode,
        parentSize: CGSize,
        suitForHeight: Bool = true
    ) {
        parentNode = parent

        _tileAtlas = SKTextureAtlas(named: "Tiles")

        _makeTilesInParnet(parent,
            mapCostData: mapCostData,
            size: parentSize.height/CGFloat(mapCostData.count + 1),
            center: CGPoint(x: parentSize.width/2, y: parentSize.height/2)
        )
    }

    public func textureWithCost(cost: Int) -> SKTexture {
        switch cost {
        case 0: return _tileAtlas.textureNamed("Ground")
        case 1: return _tileAtlas.textureNamed("Grass")
        case 2: return _tileAtlas.textureNamed("Rock")
        default: return _tileAtlas.textureNamed("Ground")
        }
    }

    public func print() {
        var data = [[Int]]()

        for tCol in tiles {
            var col = [Int]()
            for t in tCol { col.append(t.cost) }

            data.append(col)
        }

        for i in 0..<data.count {
            println(data[i])
        }
    }

    public func tileFromPoint(point: CGPoint) -> Tile? {
        for col in tiles {
            for tile in col {
                if tile.containsPoint(point) { return tile }
            }
        }

        return nil
    }



    // MARK: Private

    var _tileAtlas: SKTextureAtlas

    private func _makeTilesInParnet(
        parent: SKNode,
        mapCostData: [[Int]],
        size: CGFloat,
        center: CGPoint
    ) {
        let mapWidth = mapCostData[0].count
        let mapHeight = mapCostData.count

        let topLeftPosition = CGPoint(
            x: center.x - CGFloat(Int(mapWidth/2))*size,
            y: center.y + CGFloat(Int(mapHeight/2))*size
        )

        tiles.removeAll(keepCapacity: false)

        for ih in 0..<mapCostData.count {
            var tilesInCol = [Tile]()

            for iw in 0..<mapCostData[ih].count {
                let tile = Tile(tilesMap: self, cost: mapCostData[ih][iw])

                tile.tileNode!.position = CGPoint(
                    x: topLeftPosition.x + CGFloat(iw)*size,
                    y: topLeftPosition.y - CGFloat(ih)*size
                )

                // set scale should go to another place ...
                let scale = size / 32
                tile.tileNode!.setScale(scale)

                tilesInCol.append(tile)
            }

            tiles.append(tilesInCol)
        }
    }
}

public class Tile {

    static var globalID: Int = 1

    public var cost: Int {
        didSet {
            tileNode?.texture = _tilesMap!.textureWithCost(cost)
        }
    }

    public var tileNode: SKSpriteNode?

    public private(set) var id: Int

    init(tilesMap: TilesMap, cost: Int = 0) {
        self._tilesMap = tilesMap
        self.cost = cost

        tileNode = SKSpriteNode(texture: _tilesMap!.textureWithCost(cost))
        _tilesMap!.parentNode.addChild(tileNode!)

        self.id = Tile.globalID
        Tile.globalID++
    }

    public func containsPoint(point: CGPoint) -> Bool {
        return tileNode == nil ? false : tileNode!.containsPoint(point)
    }



    private var _tilesMap: TilesMap? = nil

    deinit {
        tileNode?.removeFromParent()
    }
}