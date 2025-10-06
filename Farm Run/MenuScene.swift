import UIKit
import SpriteKit
import GameplayKit

class MenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        createBackground()
        createTitle()
        createButton(text: "Easy", position: CGPoint(x: frame.midX, y: frame.midY + 50))
        createButton(text: "Medium", position: CGPoint(x: frame.midX, y: frame.midY))
        createButton(text: "Hard", position: CGPoint(x: frame.midX, y: frame.midY - 50))
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
        title.text = "Farm Run"
        title.fontSize = 40
        title.fontColor = SKColor(red: 0/255, green: 100/255, blue: 0/255, alpha: 1.0)
        title.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        addChild(title)
    }
    
    private func createButton(text: String, position: CGPoint) {
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = text
        label.fontSize = 22
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.zPosition = 2
        label.name = text
        let padding: CGFloat = 20
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)
        if let bubble = node as? SKShapeNode {
            bubble.fillColor = bubble.fillColor.withAlphaComponent(0.7)
        } else if let label = node as? SKLabelNode,
                  let bubble = label.parent as? SKShapeNode {
            bubble.fillColor = bubble.fillColor.withAlphaComponent(0.7)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNode = atPoint(location)
        
        if let name = tappedNode.name {
            switch name {
            case "Easy": startGame(difficulty: .easy)
            case "Medium": startGame(difficulty: .medium)
            case "Hard": startGame(difficulty: .hard)
            default: break
            }
        }
    }
    
    private func startGame(difficulty: Difficulty) {
        if let scene = GameScene(fileNamed: "GameScene") {
           scene.difficulty = difficulty
           scene.scaleMode = .aspectFill
           view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
       }
    }
}
