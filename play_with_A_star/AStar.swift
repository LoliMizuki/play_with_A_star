import Foundation

public class AStar {

    public typealias ArrayIndex = (x: Int, y: Int)

    public var costMapData: [[Int]]

    public var from: ArrayIndex

    public var to: ArrayIndex

    init(costMapData: [[Int]], from: ArrayIndex, to: ArrayIndex) {
        self.costMapData = costMapData
        self.from = from
        self.to = to
    }

    public func path() -> [ArrayIndex]? {
        if costMapData.count == 0 || costMapData[0].count == 0 { return nil }

        _fromNode = Node(location: from)
        _fromNode.cost = 0
        _fromNode.priority = 0
        _froniter.push(_fromNode)

        _costToNode[_fromNode] = _fromNode.cost

        return _findPath()
    }



    // MARK: Private

    private var _froniter = PriorityQueue<Node>({ (n1, n2) in n1.priority < n2.priority })

    private var _cameFrom = [Node:Node]()

    private var _costToNode = [Node:Int]()

    private var _fromNode: Node!

    private func _findPath() -> [ArrayIndex]? {
        while !_froniter.isEmpty {

            var current = _froniter.pop()!

            if current.isEqualLocation(x: to.x, y: to.y) {
                return _generatePath(from: _fromNode, to: current)
            }

            let neighbors = _allValidNeighborsWithNode(current, map: self.costMapData)

            for next in neighbors {
                let newCost = _costToNode[current]! + next.cost

                if _costToNode[next] == nil || newCost < _costToNode[next]! {
                    _costToNode[next] = newCost

                    next.priority = newCost
                    _froniter.push(next)

                    _cameFrom[next] = current
                }
            }
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

                if map[n.y][n.x] > 99 {
                    return false
                }

                return true
                }()

            if isNodeValid {
                neighbors.append(Node(location: (x: n.x, y: n.y), cost: map[n.y][n.x]))
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

        var cost: Int = 0

        var priority: Int = 0

        var data = [String:AnyObject]()

        var desc: String {
            return "(\(location.x), \(location.y))"
        }

        init(location: ArrayIndex, cost: Int = 0) {
            self.location = location
            self.cost = cost
        }

        var hashValue: Int { return location.x*10 + location.y }

        var neighbors = [Node]()

        func isEqualLocation(#x: Int, y: Int) -> Bool {
            return location.x == x && location.y == y
        }

        func isEqualLocation(another: Node) -> Bool {
            return location.x == another.location.x && location.y == another.location.y
        }
    }
}

func ==(lhs: AStar.Node, rhs: AStar.Node) -> Bool {
    return lhs.isEqualLocation(rhs)
}