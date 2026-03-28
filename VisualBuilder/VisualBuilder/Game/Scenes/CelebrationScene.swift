import SpriteKit

/// Full-screen celebration particle scene shown on level completion
class CelebrationScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = .clear

        // Firework bursts at random positions
        let burstCount = 5
        for i in 0..<burstCount {
            let delay = Double(i) * 0.4
            let x = CGFloat.random(in: size.width * 0.2...size.width * 0.8)
            let y = CGFloat.random(in: size.height * 0.3...size.height * 0.8)

            run(SKAction.wait(forDuration: delay)) { [weak self] in
                self?.createFireworkBurst(at: CGPoint(x: x, y: y))
            }
        }

        // Confetti rain from top
        createConfettiRain()

        // "Complete!" text
        let completeLabel = SKLabelNode(text: "Complete!")
        completeLabel.fontName = "AvenirNext-Bold"
        completeLabel.fontSize = 64
        completeLabel.fontColor = .white
        completeLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        completeLabel.zPosition = 50
        completeLabel.setScale(0)
        addChild(completeLabel)

        let popIn = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.scale(to: 1.2, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.15)
        ])
        completeLabel.run(popIn)
    }

    private func createFireworkBurst(at position: CGPoint) {
        let colors: [SKColor] = [
            SKColor(red: 0.95, green: 0.8, blue: 0.2, alpha: 1),   // Gold
            SKColor(red: 0.31, green: 0.76, blue: 0.97, alpha: 1), // Blue
            SKColor(red: 0.25, green: 0.72, blue: 0.31, alpha: 1), // Green
            SKColor(red: 0.97, green: 0.32, blue: 0.29, alpha: 1), // Red
            SKColor(red: 0.74, green: 0.55, blue: 1.0, alpha: 1),  // Purple
        ]

        let particleCount = 30
        let color = colors.randomElement() ?? .white

        for _ in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...6))
            particle.fillColor = color
            particle.strokeColor = .clear
            particle.position = position
            particle.zPosition = 40
            addChild(particle)

            let angle = CGFloat.random(in: 0...(.pi * 2))
            let distance = CGFloat.random(in: 80...200)
            let dest = CGPoint(
                x: position.x + cos(angle) * distance,
                y: position.y + sin(angle) * distance
            )

            let move = SKAction.move(to: dest, duration: Double.random(in: 0.4...0.8))
            move.timingMode = .easeOut
            let fade = SKAction.fadeOut(withDuration: 0.6)
            let remove = SKAction.removeFromParent()

            particle.run(SKAction.sequence([
                SKAction.group([move, fade]),
                remove
            ]))
        }
    }

    private func createConfettiRain() {
        let colors: [SKColor] = [.red, .blue, .green, .yellow, .orange, .purple, .cyan, .magenta]

        for _ in 0..<60 {
            let confetti = SKShapeNode(rectOf: CGSize(width: 8, height: 12), cornerRadius: 2)
            confetti.fillColor = colors.randomElement() ?? .white
            confetti.strokeColor = .clear
            confetti.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: size.height + 20
            )
            confetti.zPosition = 30
            confetti.zRotation = CGFloat.random(in: 0...(.pi * 2))
            addChild(confetti)

            let delay = Double.random(in: 0...2.0)
            let duration = Double.random(in: 2.0...4.0)
            let targetY = CGFloat.random(in: -50...size.height * 0.2)
            let swayX = CGFloat.random(in: -60...60)

            let fall = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    SKAction.moveTo(y: targetY, duration: duration),
                    SKAction.moveBy(x: swayX, y: 0, duration: duration),
                    SKAction.rotate(byAngle: CGFloat.random(in: -4...4), duration: duration),
                    SKAction.sequence([
                        SKAction.wait(forDuration: duration * 0.7),
                        SKAction.fadeOut(withDuration: duration * 0.3)
                    ])
                ]),
                SKAction.removeFromParent()
            ])
            confetti.run(fall)
        }
    }
}
