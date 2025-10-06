import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let none: UInt32   = 0
    static let player: UInt32 = 0x1 << 0
    static let ground: UInt32 = 0x1 << 1
    static let coin: UInt32   = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode!
    var cameraNode = SKCameraNode()
    var moveLeft = false
    var moveRight = false
    var onGround = false
    var activeTouches = [UITouch: String]()
    var scoreLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    var difficultyLabel: SKLabelNode!
    var score: Int = 0
    var startTime: TimeInterval?
    var isTimerRunning = false
    var platforms: [SKSpriteNode] = []
    var difficulty: Difficulty = .easy
    var elapsed: CGFloat = 0.0
    var lastXcoord: CGFloat = 0.0
    var lastYcoord: CGFloat = 0.0
    let playerSpeed: CGFloat = 180.0
    let jumpImpulse: CGFloat = 500.0

    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: -24)
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        createBackground()
        createDifficultyDisplay()
        createScoreLabel()
        createTimer()
        setupCamera()
        createGround()
        createPlayer()
        createControls()
        createQuitButton()
        launchGame()
    }
    
    func launchGame(){
        switch difficulty {
            case .easy:
                spawnRandomPlatforms(
                    count: 25,
                    minGap: 40,
                    maxGap: 110,
                    minYOffset: -40,
                    maxYOffset: 60
                )
            case .medium:
                spawnRandomPlatforms(
                    count: 50,
                    minGap: 60,
                    maxGap: 130,
                    minYOffset: -50,
                    maxYOffset: 70
                )
            case .hard:
                spawnRandomPlatforms(
                    count: 100,
                    minGap: 80,
                    maxGap: 150,
                    minYOffset: -50,
                    maxYOffset: 70
                )
        }
        spawnEnding()
    }
    
    func createPlayer() {
        let tex = SKTexture(imageNamed: "player_idle")
        player = SKSpriteNode(texture: tex)
        player.position = CGPoint(x: 120, y: 300)
        player.zPosition = 10
        player.setScale(1.0)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0.0
        player.physicsBody?.friction = 0.2
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.coin | PhysicsCategory.ground
        player.physicsBody?.collisionBitMask = PhysicsCategory.ground
        addChild(player)
    }
    
    func createGround() {
        let ground = SKSpriteNode(imageNamed: "hay")
        ground.size = CGSize(width: 300, height: 30)
        ground.position = CGPoint(x: 200, y: 80)
        ground.zPosition = 1
        ground.name = "ground"
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        addChild(ground)
    }
    
    func createScoreLabel(){
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = .black
        scoreLabel.zPosition = 100
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(
            x: frame.maxX - 130,
            y: frame.maxY - 180
        )
        scoreLabel.text = "Score: 0"
        cameraNode.addChild(scoreLabel)
    }
    func createTimer(){
        timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        timerLabel.fontSize = 30
        timerLabel.fontColor = .black
        timerLabel.zPosition = 100
        timerLabel.horizontalAlignmentMode = .right
        timerLabel.position = CGPoint(
            x: frame.maxX - 100,
            y: frame.maxY - 220
        )
        timerLabel.text = "Time: 0.0"
        cameraNode.addChild(timerLabel)
    }
    
    func createDifficultyDisplay(){
        difficultyLabel = SKLabelNode(fontNamed: "Chalkduster")
        difficultyLabel.fontSize = 24
        difficultyLabel.fontColor = .black
        difficultyLabel.zPosition = 100
        difficultyLabel.verticalAlignmentMode = .center
        difficultyLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 120)
        difficultyLabel.text = "Difficulty: \(difficulty)"
        cameraNode.addChild(difficultyLabel)
    }
    
    func createBackground() {
        let bg = SKSpriteNode(imageNamed: "background")
        bg.position = CGPoint.zero
        bg.zPosition = -10
        bg.size = self.size
        cameraNode.addChild(bg)
    }

    func setupCamera() {
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(cameraNode)
        camera = cameraNode
    }
    
    func createControls() {
        let zoneHeight = size.height * 0.75
        let zoneWidth = size.width / 2
        let left = SKSpriteNode(color: .clear,
                                size: CGSize(width: zoneWidth, height: zoneHeight))
        left.name = "left"
        left.position = CGPoint(x: -size.width/4, y: -size.height/2 + zoneHeight/2)
        left.zPosition = 50
        cameraNode.addChild(left)
        let right = SKSpriteNode(color: .clear,
                                 size: CGSize(width: zoneWidth, height: zoneHeight))
        right.name = "right"
        right.position = CGPoint(x: size.width/4, y: -size.height/2 + zoneHeight/2)
        right.zPosition = 50
        cameraNode.addChild(right)
    }

    func createQuitButton() {
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "End Game"
        label.fontSize = 22
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.zPosition = 100
        label.name = "end"
        let padding: CGFloat = 25
        let buttonWidth = label.frame.width + padding
        let buttonHeight = label.frame.height + padding
        let bubble = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        bubble.fillColor = SKColor(red: 0/255, green: 100/255, blue: 0/255, alpha: 0.4)
        bubble.strokeColor = .clear
        bubble.name = "end"
        bubble.zPosition = 100
        bubble.userData = ["normalColor": bubble.fillColor]
        bubble.position = CGPoint(
            x: frame.minX + 170,
            y: frame.maxY - 180
        )
        label.position = CGPoint.zero
        bubble.addChild(label)
        cameraNode.addChild(bubble)
    }

    func spawnRandomPlatforms(
        count: Int,
        startX: CGFloat = 150,
        minWidth: CGFloat = 150,
        maxWidth: CGFloat = 300,
        platformHeight: CGFloat = 30,
        yBase: CGFloat = 100,
        yMin: CGFloat = 100,   // hard floor
        minGap: Int = 0,       // X-axis gap minimum
        maxGap: Int = 80,      // X-axis gap maximum
        minYOffset: Int = -40, // Y-axis offset minimum (drop)
        maxYOffset: Int = 40   // Y-axis offset maximum (climb)
    ) {
        var lastX = startX
        var lastY = yBase
        var lastGap: Int? = nil
        for _ in 0..<count {
            let randomWidth = CGFloat.random(in: minWidth...maxWidth)
            var gap: Int
            repeat {
                gap = Int.random(in: minGap...maxGap)
            } while gap == lastGap
            lastGap = gap
            let xGap = CGFloat(gap)
            lastX += randomWidth / 2 + xGap
            let yOffset = CGFloat(Int.random(in: minYOffset...maxYOffset))
            var newY = lastY + yOffset
            if newY < yMin { newY = yMin }
            if newY > 1000 { newY = 1000 }
            lastY = newY
            let size = CGSize(width: randomWidth, height: platformHeight)
            let plat = SKSpriteNode(imageNamed: "hay")
            plat.size = size
            plat.name = "platform"
            plat.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            plat.position = CGPoint(x: lastX, y: newY)
            plat.zPosition = 2
            plat.physicsBody = SKPhysicsBody(rectangleOf: plat.size)
            plat.physicsBody?.isDynamic = false
            plat.physicsBody?.categoryBitMask = PhysicsCategory.ground
            addChild(plat)
            lastX += randomWidth / 2
            platforms.append(plat)
        }
        lastXcoord = lastX
        lastYcoord = lastY
    }
    
    func spawnEnding(){
        let trophy = SKSpriteNode(imageNamed: "trophy")
        trophy.position = CGPoint(x: lastXcoord - 40, y: lastYcoord + 60)
        trophy.setScale(0.25)
        trophy.zPosition = 1
        addChild(trophy)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let loc = t.location(in: cameraNode)
            let nodes = cameraNode.nodes(at: loc)
            if let node = nodes.first(where: { $0.name == "left" || $0.name == "right" || $0.name == "end" }),
               let name = node.name {
                activeTouches[t] = name
                switch name {
                case "left":
                    moveLeft = true
                    startRunningAnimation()
                    if onGround {
                        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
                        onGround = false
                    }
                case "right":
                    moveRight = true
                    startRunningAnimation()
                    if onGround {
                        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))
                        onGround = false
                    }
                case "end":
                    gameOver()
                default: break
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            guard let name = activeTouches[t] else { continue }
            if name == "left" { moveLeft = false }
            else if name == "right" { moveRight = false }
            activeTouches.removeValue(forKey: t)
        }
        if !moveLeft && !moveRight { stopRunningAnimation() }
    }

    func startRunningAnimation() {
        if player.action(forKey: "runAnim") != nil { return }
        let atlas = SKTextureAtlas(named: "Player")
        if atlas.textureNames.count > 0 {
            var frames: [SKTexture] = []
            let sortedNames = atlas.textureNames.sorted() // ensure order
            for name in sortedNames {
                frames.append(atlas.textureNamed(name))
            }
            let anim = SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 0.08))
            player.run(anim, withKey: "runAnim")
        }
    }

    func stopRunningAnimation() {
        player.removeAction(forKey: "runAnim")
        player.texture = SKTexture(imageNamed: "player_idle")
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let body = player.physicsBody else { return }
        let playerDied: Bool = player.position.y < -800
        //this making sure they did not fall off the screen (died in game)
        if playerDied {
            print("player y position.", player.position.y)
            print("player x position.", player.position.x)
            gameOver()
        }
        else {
            let winningPosition = lastXcoord - 100
            let playerWon: Bool = player.position.x >= winningPosition
            if playerWon {
                print("player WON", player.position.y)
                showWinningScreen()
            }
            else{
                if let cam = camera {
                    let targetX = player.position.x
                    cam.position = CGPoint(x: targetX, y: size.height/2)
                }
                setTimerLabel(currentTime: currentTime)
                checkPlatformPassing(playerX: player.position.x)
                var vx: CGFloat = 0
                if moveLeft {
                    vx -= playerSpeed
                }
                if moveRight {
                    vx += playerSpeed
                }
                body.velocity = CGVector(dx: vx, dy: body.velocity.dy)
                if moveLeft {
                    player.xScale = -1
                } else if moveRight {
                    player.xScale = 1
                }
            }
        }
    }
    
    func showWinningScreen(){
        if let view = self.view {
            let gameWonScene = GameWonScene(size: view.bounds.size)
            gameWonScene.difficulty = difficulty
            gameWonScene.finalScore = score
            gameWonScene.elapsedTime = elapsed
            gameWonScene.scaleMode = .aspectFill
            view.presentScene(gameWonScene, transition: SKTransition.fade(withDuration: 1.0))
        }
    }
    
    func setTimerLabel(currentTime: TimeInterval){
        if player.position.x >= 150 {
            if !isTimerRunning {
                isTimerRunning = true
                startTime = currentTime
            }
            if let start = startTime {
                elapsed = currentTime - start
                timerLabel?.text = String(format: "Time: %.1f", elapsed)
            }
        } else {
            isTimerRunning = false
            startTime = nil
            timerLabel?.text = "Time: 0.0"
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA
        let b = contact.bodyB
        var playerBody: SKPhysicsBody?
        var otherBody: SKPhysicsBody?
        if a.categoryBitMask == PhysicsCategory.player {
            playerBody = a; otherBody = b
        } else if b.categoryBitMask == PhysicsCategory.player {
            playerBody = b; otherBody = a
        } else {
            return
        }
        guard let p = playerBody, let o = otherBody else { return }

        if o.categoryBitMask == PhysicsCategory.ground {
            onGround = true
        }
    }
    
    func checkPlatformPassing(playerX: CGFloat) {
        for platform in platforms {
            let alreadyPassed = platform.userData?["passed"] as? Bool ?? false
            let platformStart = platform.position.x - 30
            if !alreadyPassed && playerX > platformStart{
                if platform.userData == nil { platform.userData = NSMutableDictionary() }
                platform.userData?["passed"] = true
                score += 1
                scoreLabel.text = "Score: \(score)"
            }
        }
    }
    
    func gameOver() {
        if let view = self.view {
            let gameOverScene = GameOverScene(size: view.bounds.size)
            gameOverScene.difficulty = difficulty
            gameOverScene.finalScore = score
            gameOverScene.elapsedTime = elapsed
            gameOverScene.scaleMode = .aspectFill
            view.presentScene(gameOverScene, transition: SKTransition.fade(withDuration: 1.0))
        }
    }
}
