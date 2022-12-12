import Foundation

public struct Point: Hashable, CustomStringConvertible, Comparable, Equatable {
    static let zero = Point(x: 0, y: 0)
    static let up = Point(x: 0, y: -1)
    static let down = Point(x: 0, y: 1)
    static let left = Point(x: -1, y: 0)
    static let right = Point(x: 1, y: 0)
    
    static let adjacentDirections: [Point] = [.up, .left, .down, .right]
    static let allDirections: [Point] = [.up, .up + .left, .up + .right, .left, .right, .down, .down + .left, .down + .right]
    
    static func distance(between to: Point, and from: Point) -> Int {
        abs(to.x - from.x) + abs(to.y + from.y)
    }
    
    public static func < (lhs: Point, rhs: Point) -> Bool {
        if lhs.y == rhs.y {
            return lhs.x < rhs.x
        } else {
            return lhs.y < rhs.y
        }
    }
    
    public static func += (left: inout Point, right: Point) {
        left = left + right
    }
    
    public static func + (left: Point, right: Point) -> Point {
        Point(x: left.x + right.x, y: left.y + right.y)
    }
    
    public static func -= (left: inout Point, right: Point) {
        left = left - right
    }
    public static func - (left: Point, right: Point) -> Point {
        Point(x: left.x - right.x, y: left.y - right.y)
    }
    
    public static func *= (left: inout Point, right: Int) {
        left = left * right
    }
    
    public static func * (left: Point, right: Int) -> Point {
        Point(x: left.x * right, y: left.y * right)
    }
    
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    public let x, y: Int
    
    public var description: String {
        "(x: \(x), y: \(y))"
    }
    
    var adjacent: [Point] {
        Point.adjacentDirections.map { $0 + self }
    }
    
    var neighbours: [Point] {
        Point.allDirections.map { $0 + self }
    }
    
    var normalized: Point {
        Point(x: x.clamped(to: -1 ... 1), y: y.clamped(to: -1 ... 1))
    }
    
    func value<T>(in array: [[T]]) -> T? {
        guard y < array.endIndex && y >= array.startIndex else { return nil }
        guard x < array[y].endIndex && x >= array.startIndex else { return nil }
        return array[y][x]
    }
    
    func set<T>(value: T, in array: inout [[T]]) {
        array[y][x] = value
    }
    
    func distance(to: Point) -> Int {
        abs(x - to.x) + abs(y - to.y)
    }
}

extension Set where Element == Point {
    func printPoints(current: Point? = nil, path: [Point] = []) {
        var string = ""
        for y in map({ $0.y }).min()! - 1 ... map({ $0.y }).max()! + 1 {
            for x in map({ $0.x }).min()! - 1 ... map({ $0.x }).max()! + 1 {
                let point = Point(x: x, y: y)
                if contains(point) {
                    string += "#"
                } else if let index = path.firstIndex(of: point) {
                    string += "\(index % 10)"
                } else if let current = current, point == current {
                    string += "D"
                } else {
                    string += "."
                }
            }
            string += "\n"
        }
        
        print(string)
    }
    
    func removeDeadEnds(keeping: Set<Point>, warps: [Point: Point]) -> Set<Point> {
        var mutable = self
        while true {
            let deadEnds = mutable.flatMap { $0.adjacent }
                .filter { !mutable.contains($0) && !keeping.contains($0) }
                .filter { $0.adjacent.map { warps[$0] ?? $0 }.filter { mutable.contains($0) }.count == 3 }
            if deadEnds.isEmpty {
                return mutable
            }
            mutable.formUnion(deadEnds)
        }
    }
}
