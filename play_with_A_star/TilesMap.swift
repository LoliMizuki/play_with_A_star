import Foundation
import SpriteKit

public class TilesMap {

    public private(set) var tiles = [[Tile]]()

    init?(
        data: [[Tile.Property]],
        parent: SKNode,
        parentSize: CGSize,
        pathColor: SKColor = SKColor.whiteColor(),
        wallColor: SKColor = SKColor.grayColor(),
        suitForHeight: Bool = true
    ) {
        if data.count == 0 { return nil }

        Tile.pathColor = pathColor
        Tile.wallColor = wallColor

        _makeTilesInParnet(parent,
            data: data,
            size: parentSize.height/CGFloat(data.count + 1),
            center: CGPoint(x: parentSize.width/2, y: parentSize.height/2)
        )
    }

    public func print() {
        var data = [[UInt32]]()

        for tCol in tiles {
            var col = [UInt32]()
            for t in tCol { col.append(t.property.rawValue) }

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

    deinit {
        // remove tile from parent
    }

    private func _makeTilesInParnet(
        parent: SKNode,
        data: [[Tile.Property]],
        size: CGFloat,
        center: CGPoint
    ) {
        let mapWidth = data[0].count
        let mapHeight = data.count

        let topLeftPosition = CGPoint(
            x: center.x - CGFloat(Int(mapWidth/2))*size,
            y: center.y + CGFloat(Int(mapHeight/2))*size
        )

        func newTileNode() -> SKShapeNode {
            return SKShapeNode(rect: CGRect(origin: CGPoint.zeroPoint, size: CGSize(width: size, height: size)))
        }

        tiles.removeAll(keepCapacity: false)

        for ih in 0..<data.count {

            var tilesInCol = [Tile]()

            for iw in 0..<data[ih].count {
                let tileNode = newTileNode()
                tileNode.lineWidth = 4
                tileNode.strokeColor = SKColor.brownColor()
                tileNode.position = CGPoint(
                    x: topLeftPosition.x + CGFloat(iw)*size,
                    y: topLeftPosition.y - CGFloat(ih)*size
                )

                parent.addChild(tileNode)

                tilesInCol.append(Tile(tileNode: tileNode))
                tilesInCol.last!.property = data[ih][iw]
            }

            tiles.append(tilesInCol)
        }
    }
}

public class Tile {

    public enum Property: UInt32 {
        case Path = 0
        case Wall = 1

        public var desc: String {
            switch (self.rawValue) {
            case 0: return "Path"
            case 1: return "Wall"
            default: return "Unknow"
            }
        }

        public static func fromValue(value: UInt32) -> Property {
            switch (value) {
            case 0: return .Path
            case 1: return .Wall
            default: return .Path
            }
        }
    }

    static var pathColor: SKColor = SKColor.whiteColor()

    static var wallColor: SKColor = SKColor.grayColor()

    static var globalID: Int = 1

    public weak var tileNode: SKShapeNode?

    public var property : Property {
        didSet {
            tileNode?.fillColor = property == Property.Path ? Tile.pathColor : Tile.wallColor
        }
    }

    public private(set) var id: Int

    init(tileNode: SKShapeNode) {
        self.tileNode = tileNode
        self.property = Property.Path

        self.id = Tile.globalID
        Tile.globalID++
    }

    public func containsPoint(point: CGPoint) -> Bool {
        return tileNode == nil ? false : tileNode!.containsPoint(point)
    }
}