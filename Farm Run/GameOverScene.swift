import SpriteKit

class GameOverScene: SKScene {
    var difficulty: Difficulty = .easy
    var finalScore: Int = 0
    var elapsedTime = 0.0
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        createBackground();
        createTitle()
        createDifficultyDisplay()
        createScoreDisplay()
        createTimerDisplay()
        createButton(text: "Retry", position: CGPoint(x: frame.midX, y: frame.midY - 20))
        createButton(text: "Main Menu", position: CGPoint(x: frame.midX, y: frame.midY - 80))
    }
    
    func createBackground() {
        let background = SKSpriteNode(imageNamed: "menu_background")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.size
        background.zPosition = -10
        addChild(background)
    }

    func createTitle(){
        let title = SKLabelNode(fontNamed: "Chalkduster")
        title.text = "Game Over"
        title.fontSize = 40
        title.fontColor = .red
        title.position = CGPoint(x: frame.midX, y: frame.midY + 160)
        addChild(title)
    }
    
    func createDifficultyDisplay(){
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Difficulty: \(difficulty)"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY + 120)
        addChild(scoreLabel)
    }
    
    func createScoreDisplay(){
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: \(finalScore)"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY + 80)
        addChild(scoreLabel)
    }
    
    func createTimerDisplay(){
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = String(format: "Time: %.1f", elapsedTime)
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY + 40)
        addChild(scoreLabel)
    }
    
    private func createButton(text: String, position: CGPoint) {
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = text
        label.fontSize = 22
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.zPosition = 2
        label.name = text
        let padding: CGFloat = 25
        let buttonWidth = label.frame.width + padding
        let buttonHeight = label.frame.height + padding
        let bubble = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        bubble.fillColor = SKColor(red: 0/255, green: 100/255, blue: 0/255, alpha: 0.4)
        bubble.strokeColor = .clear
        bubble.position = position
        bubble.name = text
        bubble.zPosition = 1
        bubble.userData = ["normalColor": bubble.fillColor]
        label.position = CGPoint.zero
        bubble.addChild(label)
        addChild(bubble)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNode = atPoint(location)
        if let name = tappedNode.name {
            switch name {
            case "Retry":
                if let scene = GameScene(fileNamed: "GameScene") {
                   scene.difficulty = difficulty
                   scene.scaleMode = .aspectFill
                   view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
               }
            case "Main Menu":
                let scene = MenuScene(size: self.size)
                scene.scaleMode = .aspectFill
                view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
            default: break
            }
        }
    }
}
