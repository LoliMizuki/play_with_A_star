import Foundation

public class BreadthFirstSearch {

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

        _froniter.append(Node(location: from))

        return _findPath()
    }



    // MARK: Private

    private var _visited = [Node]()

    private var _froniter = [Node]()

    private func _findPath() -> [ArrayIndex]? {
        while !_froniter.isEmpty {

            var current = _froniter.first!

            if current.isEqualLocation(x: to.x, y: to.y) {
                return generatePathToNode(current)
            }

            _froniter.removeAtIndex(0)
            _visited.append(current)

            let neighbors = _allValidNeighborsWithNode(current, map: self.map)

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
                for visitedNode in self!._visited {
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

    private func generatePathToNode(node: Node) -> [ArrayIndex]? {
        if node.parent == nil { return nil }

        var path = [ArrayIndex]()

        var current: Node? = node

        while current != nil {
            path.append((x: current!.location.x, y: current!.location.y))
            current = current!.parent
        }

        return path.reverse()
    }



    class Node: Equatable {

        var location: ArrayIndex

        var parent: Node? = nil

        var desc: String {
            return "(\(location.x), \(location.y))"
        }

        init(location: ArrayIndex, parent: Node? = nil) {
            self.location = location
            self.parent = parent
        }

        func isEqualLocation(#x: Int, y: Int) -> Bool {
            return location.x == x && location.y == y
        }

        func isEqualLocation(another: Node) -> Bool {
            return location.x == another.location.x && location.y == another.location.y
        }

        func isEqual(another: Node) -> Bool {
            return
                isEqualLocation(another) &&
                ((parent == nil && another.parent == nil) || (parent!.isEqual(another.parent!)))
        }
    }
}

func ==(lhs: BreadthFirstSearch.Node, rhs: BreadthFirstSearch.Node) -> Bool {
    return lhs.isEqual(rhs)
}