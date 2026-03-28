import SpriteKit

/// Renders the building grid overlay — the visual template where pieces are placed
class GridNode: SKNode {
    let gridWidth: Int
    let gridHeight: Int
    let cellSize: CGFloat
    let origin: CGPoint

    private let gridColor = SKColor(red: 0.3, green: 0.35, blue: 0.4, alpha: 0.3)
    private let borderColor = SKColor(red: 0.4, green: 0.45, blue: 0.5, alpha: 0.5)

    init(gridWidth: Int, gridHeight: Int, cellSize: CGFloat, origin: CGPoint) {
        self.gridWidth = gridWidth
        self.gridHeight = gridHeight
        self.cellSize = cellSize
        self.origin = origin
        super.init()
        self.name = "grid"
        drawGrid()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    private func drawGrid() {
        let totalWidth = CGFloat(gridWidth) * cellSize
        let totalHeight = CGFloat(gridHeight) * cellSize

        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: totalWidth, height: totalHeight), cornerRadius: 8)
        bg.position = CGPoint(
            x: origin.x + totalWidth / 2,
            y: origin.y + totalHeight / 2
        )
        bg.fillColor = SKColor(red: 0.08, green: 0.09, blue: 0.11, alpha: 0.8)
        bg.strokeColor = borderColor
        bg.lineWidth = 2
        addChild(bg)

        // Grid lines
        for col in 0...gridWidth {
            let x = origin.x + CGFloat(col) * cellSize
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: origin.y))
            path.addLine(to: CGPoint(x: x, y: origin.y + totalHeight))
            let line = SKShapeNode(path: path)
            line.strokeColor = gridColor
            line.lineWidth = 1
            addChild(line)
        }

        for row in 0...gridHeight {
            let y = origin.y + CGFloat(row) * cellSize
            let path = CGMutablePath()
            path.move(to: CGPoint(x: origin.x, y: y))
            path.addLine(to: CGPoint(x: origin.x + totalWidth, y: y))
            let line = SKShapeNode(path: path)
            line.strokeColor = gridColor
            line.lineWidth = 1
            addChild(line)
        }
    }

    /// Convert a grid coordinate to a scene point (center of the cell)
    func scenePoint(forGridX x: Int, gridY y: Int, pieceWidth: Int = 1, pieceHeight: Int = 1) -> CGPoint {
        CGPoint(
            x: origin.x + CGFloat(x) * cellSize + CGFloat(pieceWidth) * cellSize / 2,
            y: origin.y + CGFloat(y) * cellSize + CGFloat(pieceHeight) * cellSize / 2
        )
    }

    /// Find the nearest grid coordinate for a scene point
    func gridCoordinate(for point: CGPoint) -> (x: Int, y: Int)? {
        let gx = Int((point.x - origin.x) / cellSize)
        let gy = Int((point.y - origin.y) / cellSize)
        guard gx >= 0, gx < gridWidth, gy >= 0, gy < gridHeight else { return nil }
        return (gx, gy)
    }
}
