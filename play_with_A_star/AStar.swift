import Foundation

public class AStar {

    public typealias ArrayIndex = (x: Int, y: Int)

    public var map: [[Int]]

    public var from: ArrayIndex

    public var to: ArrayIndex

    init(map: [[Int]], from: ArrayIndex, to: ArrayIndex) {
        self.map = map
        self.from = from
        self.to = to
    }

    public func path() -> [ArrayIndex]? {
        if map.count == 0 || map[0].count == 0 { return nil }
        if map[from.y][from.x] == 1 { return nil }
        if map[to.y][to.x] == 1 { return nil }

        _fromNode = Node(location: from)
        _froniter.append(_fromNode)

        return _findPath()
    }



    // MARK: Private

    private var _cameFrom = [Node:Node]()

    private var _froniter = [Node]()

    private var _fromNode: Node!

    private func _findPath() -> [ArrayIndex]? {
        while !_froniter.isEmpty {

            var current = _froniter.first!

            if current.isEqualLocation(x: to.x, y: to.y) {
                return _generatePath(from: _fromNode, to: current)
            }

            _froniter.removeAtIndex(0)

            let neighbors = _allValidNeighborsWithNode(current, map: self.map)

            for n in neighbors {
                _cameFrom[n] = current
            }

            _froniter += neighbors
        }

        return nil
    }

    private func _allValidNeighborsWithNode(node: Node, map: [[Int]]) -> [Node] {
        var neighbors = [Node]()

        let loc = node.location

        let up = (x: loc.x, y: loc.y - 1)
        let down = (x: loc.x, y: loc.y + 1)
        let left = (x: loc.x - 1, y: loc.y)
        let right = (x: loc.x + 1, y: loc.y)

        let list = [up, down, left, right]

        let mapWidth = map[0].count
        let mapHeight = map.count

        for n in list {
            if (n.x < 0 || n.x >= mapWidth) || (n.y < 0 || n.y >= mapHeight) { continue }

            let isNodeValid = {
                [weak self] () -> Bool in
                for visitedNode in self!._cameFrom.values {
                    if visitedNode.location.x == n.x && visitedNode.location.y == n.y { return false }
                }

                if map[n.y][n.x] == 1 {
                    return false
                }

                return true
                }()

            if isNodeValid {
                neighbors.append(Node(location: (x: n.x, y: n.y), parent: node))
            }
        }

        return neighbors
    }

    private func _generatePath(#from: Node, to: Node) -> [ArrayIndex]? {
        var curr = to

        var path = [curr.location]

        while curr != from {
            curr = _cameFrom[curr]!
            path.append(curr.location)
        }

        return path.reverse()
    }



    // MARK: Node

    class Node: Equatable, Hashable {

        var location: ArrayIndex

        var desc: String {
            return "(\(location.x), \(location.y))"
        }

        init(location: ArrayIndex, parent: Node? = nil) {
            self.location = location
        }

        var hashValue: Int { return location.x*10 + location.y }

        func isEqualLocation(#x: Int, y: Int) -> Bool {
            return location.x == x && location.y == y
        }

        func isEqualLocation(another: Node) -> Bool {
            return location.x == another.location.x && location.y == another.location.y
        }
    }
}

// can remove?
func ==(lhs: AStar.Node, rhs: AStar.Node) -> Bool {
    return lhs.isEqualLocation(rhs)
}