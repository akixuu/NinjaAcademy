//
//  GameScene.swift
//  Ninja
//
//  Created by Aki Xu on Feb 2025.
//

import SpriteKit

class GameScene: SKScene {
    
    static private var _scene: SKScene!
    static var scene: SKScene {
        if _scene == nil {
            _scene = SKScene(fileNamed: "GameScene")
        }
        return _scene
    }

    var ninja: SKSpriteNode!
    var enemies: [SKSpriteNode] = []
    var attacks: [SKSpriteNode] = []
    var timeAlive: TimeInterval = 0
    var enemiesKilled: Int = 0
    var lives: Int = 5
    var horizonLevelOffset: CGFloat = -200
    var lastSpawnedEnemyType: String = ""
    var lastHeartSpawnedAt: Int = -30

    var scoreLabel: SKLabelNode!
    var timeLabel: SKLabelNode!
    var livesLabel: SKLabelNode!
    var dialogueLabel: SKLabelNode!
    
    var elementButtons: [SKSpriteNode] = []
    
    var isGameOver: Bool = false
    
    var currentJutsuPose: NinjaMoves = .unknown
    
    override func update(_ currentTime: TimeInterval) {
        
        // update labels
        scoreLabel.text = "Yokais Excorcised: \(enemiesKilled)"
        
        if lives < 0 { lives = 0 }
        livesLabel.text = String(repeating: "❤️", count: lives)
        
        // collisions
        for enemy in enemies {
            
            if enemy.frame.intersects(ninja.frame) {
                
                let enemyType = enemy.userData?["type"] as? String ?? ""
                
                if enemyType == "heart" {
                    // hearts don't hurt but you lose it sooo
                    // TODO: play cool animation?
                    showDialogue(text: "Oh no! You missed it...")
                } else {
                    
                    lives -= 1
                    
                    if lives == 0 {
                        gameOver()
                        // TODO: ninja is dead, add appropriate frame
                    } else {
                        let dialogue = ["Are you alright, young warrior?", "Careful, young warrior!", "Watch out, young warrior!"].randomElement() ?? ""
                        showDialogue(text: dialogue)
                        // TODO: play ninja oof sound + appropriate frame , if possible
                    }
                    
                    enemy.removeFromParent()
                    enemies.removeAll { $0 == enemy }
                }
            }
            
            for attack in attacks {
                if attack.frame.intersects(enemy.frame) {
                    if let attackType = attack.userData?["type"] as? String,
                       let enemyType = enemy.userData?["type"] as? String {
                        if attackType == enemyType {
                            enemy.removeFromParent()
                            enemies.removeAll { $0 == enemy }
                            
                            attack.removeFromParent()
                            attacks.removeAll { $0 == attack }
                            
                            playAttackAnimation(at: enemy.position, texture: enemy.texture!)
                            
                            
                            if (enemyType == "heart") {
                                lives += 1
                                // TODO: heart restoration sound
                                showDialogue(text: "A heart! Wonderful!")
                            } else {
                                enemiesKilled += 1
                                if enemiesKilled % 11 == 0 && enemiesKilled != 0 {
                                    var dialogue: String?
                                    // TODO: change dialog boxes after a certain amt of time
                                    if timeAlive>45 {
                                        dialogue  = ["You are the pride of our clan!", "You are on fire!", "Remember your training!", "Watch out, they get faster!", "Victory comes at a 100 exorcisms...", "Sensei is thrilled!", "Sensei is getting nostalgic... Ho ho ho!"].randomElement()
                                    } else {
                                        dialogue = ["You are a worthy opponent!", "You are on fire!", "Remember your training!", "Watch out, they get faster!", "Victory comes at a 100 exorcisms...", "Sensei is thrilled!", "Sensei is getting nostalgic... Ho ho ho!"].randomElement()
                                    }
                                    
                                    showDialogue(text: dialogue ?? "")
                                }
                                if enemiesKilled % 25 == 0 && enemiesKilled != 0 {
                                    let dialogue = "Thats \(enemiesKilled)! Sensei is proud!"
                                    showDialogue(text: dialogue)
                                }
                                // TODO: attack sound
                            }
                            
                            print("enemy type \(attackType) destroyed")
                            
                        // case where attack type and monster don't match (failed attack)
                        } else {
                            lives -= 1
                            
                            attack.removeFromParent()
                            attacks.removeAll { $0 == attack }
                            
                            if attackType == "heart" { // hearts are delicate
                                enemy.removeFromParent()
                                enemies.removeAll { $0 == enemy }
                                playAttackAnimation(at: enemy.position, texture: enemy.texture!)
                            }
                            
                            
                            let failedAttackAnimation = SKEmitterNode(fileNamed: "X.sks")
                            failedAttackAnimation?.position = attack.position
                            failedAttackAnimation!.particleTexture = SKTexture(imageNamed: "x")
                            addChild(failedAttackAnimation!)

                            let removeAction = SKAction.sequence([SKAction.wait(forDuration: 0.2), SKAction.removeFromParent()])
                            failedAttackAnimation!.run(removeAction)
                            print("failed attack")
                        }
                    }
                }
            }
        }
        
        processJutsuMove()
    }

    
    override func didMove(to view: SKView) {
        // reset before start -- is this necessary
        lives = 5
        enemiesKilled = 0
        timeAlive = 0
        
        setBackground()
        addNinja()
        addLabels()
        spawnEnemy()
        startCounter()
        createElementButtons()
        playBackgroundMusic()
        showDialogue(text: "Ready for some exorcism!")
    }
    
    func playAttackAnimation(at position: CGPoint, texture: SKTexture) { // FIXME: arg = texture?
        // TODO: customized particle effects for each element type?
        if let attackEffect = SKEmitterNode(fileNamed: "Explode.sks") {
            attackEffect.position.x = position.x
            attackEffect.position.y = position.y
            attackEffect.particleTexture = texture
            addChild(attackEffect)

            let fadeAction = SKAction.fadeOut(withDuration: 0.2)
            let removeAction = SKAction.sequence([fadeAction, SKAction.removeFromParent()])
            attackEffect.run(removeAction)

        }
    }


    func setBackground() {
        self.backgroundColor = SKColor.black
//        let background = SKSpriteNode(imageNamed: "dojo")
//        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
//        
//        background.size = CGSize(width: self.size.width, height: self.size.height)
//        
//        background.zPosition = -1
//        addChild(background)
    }

    func addNinja() {
        ninja = SKSpriteNode(imageNamed: "ninja")
        ninja.position = CGPoint(x: 150, y: self.size.height / 2 + horizonLevelOffset)
        ninja.zPosition = 1
        addChild(ninja)
    }

    func addLabels() {
        scoreLabel = SKLabelNode(text: "Enemies Killed: 0")
        scoreLabel.position = CGPoint(x: self.size.width - 25, y: self.size.height - 50)
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.fontName = "Arial-Bold"
        addChild(scoreLabel)
        
        timeLabel = SKLabelNode(text: "Time Alive: 0")
        timeLabel.position = CGPoint(x: self.size.width - 25, y: self.size.height - 100)
        timeLabel.fontSize = 24
        timeLabel.fontColor = .white
        timeLabel.horizontalAlignmentMode = .right
        timeLabel.fontName = "Arial-Bold"
        addChild(timeLabel)
        
        livesLabel = SKLabelNode(text: "❤️❤️❤️❤️❤️")
        livesLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height - 60)
        livesLabel.fontSize = 40
        livesLabel.fontColor = .white
        livesLabel.horizontalAlignmentMode = .center
        livesLabel.fontName = "Arial-Bold"
        addChild(livesLabel)
        
        dialogueLabel = SKLabelNode(text: "")
        dialogueLabel.fontSize = 24
        dialogueLabel.fontColor = .white
        dialogueLabel.fontName = "Chalkduster"
        dialogueLabel.position = CGPoint(x: ninja.position.x, y: ninja.position.y + 100)
        dialogueLabel.alpha = 0 // init hidden
        addChild(dialogueLabel)
    }
    
    func showDialogue(text: String) {
        dialogueLabel.text = "Sensei: " + text
        dialogueLabel.removeAllActions()
        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        let wait = SKAction.wait(forDuration: 3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        dialogueLabel.horizontalAlignmentMode = .left
        dialogueLabel.verticalAlignmentMode = .bottom
        dialogueLabel.run(SKAction.sequence([fadeIn, wait, fadeOut]))
    }

    
    func playBackgroundMusic() {
        // FIXME: add bg music, stop when game over and play appropriate music
        let backgroundMusic = SKAudioNode(fileNamed: "music-game.mp3")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
    }

    func spawnEnemy() {
        if isGameOver { return }
        
        let availableEnemyTypes = ["fire", "water", "earth", "air", "dark", "light"]
        let enemy: SKSpriteNode
        
        if lives < 3 && (enemiesKilled % 10 == 0) && enemiesKilled != 0 && lastHeartSpawnedAt != enemiesKilled {
            showDialogue(text: "Sensei has sent you a recovery heart!")
            enemy = SKSpriteNode(imageNamed: "heart")
            enemy.userData = ["type": "heart"]
            lastHeartSpawnedAt = enemiesKilled
        } else {
            var enemyType: String
            repeat {
                // adding more variety based off time, with a base of two
                enemyType = availableEnemyTypes[Int.random(in: 0..<min(availableEnemyTypes.count, Int(timeAlive / 15) + 2))]
            } while enemyType == lastSpawnedEnemyType // never let two of the same types spawn consecutively

            enemy = SKSpriteNode(imageNamed: "\(enemyType)-monster")
            print("spawned enemy type \(enemyType)")
            enemy.userData = ["type": enemyType]
            lastSpawnedEnemyType = enemyType
        }
        
        enemy.position = CGPoint(x: self.size.width + 50, y: self.size.height / 2 + horizonLevelOffset)
        addChild(enemy)
        enemies.append(enemy)
        
        let speed = max(5, 15 - (timeAlive / 10))
        let moveAction = SKAction.moveTo(x: -enemy.size.width - self.size.width, duration: TimeInterval(speed))
        let removeAction = SKAction.removeFromParent()
        let moveSequence = SKAction.sequence([moveAction, removeAction])
        
        enemy.run(moveSequence)
        
        let intervalFactor = max(2.0, 7.0 - (timeAlive / 20))
        let randomInterval = TimeInterval(.random(in: 1...intervalFactor))
            
        run(SKAction.wait(forDuration: randomInterval), completion: spawnEnemy)
    }

    func startCounter() {
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 1),
            SKAction.run { [weak self] in
                self?.timeAlive += 1
                self?.updateTimeLabel()
            }
        ])), withKey: "timeAliveCounter")
    }

    func updateTimeLabel() {
        timeLabel.text = "Time Alive: \(Int(timeAlive))"
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver { return }
        
        for touch in touches {
            let location = touch.location(in: self)
            
            for button in elementButtons {
                if button.contains(location) {
                    attackWithElement(element: button.name ?? "")
                }
            }
        }
    }

    func attackWithElement(element: String) {
        let attack = SKSpriteNode(imageNamed: "\(element)")
        attack.position = ninja.position
        attack.userData = ["type": element]
        print("spawned attack type \(element)")

        addChild(attack)
        attacks.append(attack)
        
        let moveAction = SKAction.moveTo(x: self.size.width + attack.size.width, duration: 2.0) // attack time
        let removeAction = SKAction.removeFromParent()
        attack.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    
    func gameOver() {
        
        isGameOver = true
        
        switch enemiesKilled {
        case 100...:
            showDialogue(text: "This is a special ending :) - Thank you for playing this game!")
        case 75..<100:
            showDialogue(text: "I have taught you everything... Sensei is proud.")
        case 50..<75:
            showDialogue(text: "Excellent! You are on your way to a ninja LEGEND!")
        case 30..<50:
            showDialogue(text: "Amazing! Perhaps you are ready for your black belt!")
        case 15..<30:
            showDialogue(text: "Not bad! You are on your path to becoming a great ninja master...")
        case 10..<15:
            showDialogue(text: "Continue training! You will get better...")
        default:
            showDialogue(text: "Keep going! Every fight makes you stronger...")
        }
        
        print("Game Over")
        
        // cleanup
        for attack in attacks { attack.removeFromParent() }
        for enemy in enemies { enemy.removeFromParent() }
        attacks.removeAll()
        enemies.removeAll()
        
        removeAction(forKey: "timeAliveCounter")
        
        
        let gameOverLabel = SKLabelNode(text: "Game Over! Survival Time: \(Int(timeAlive)) Yokais Exorcised: \(enemiesKilled)")
        gameOverLabel.fontName = "Arial-Bold"
        gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        gameOverLabel.fontColor = .red
        gameOverLabel.zPosition = 2
        addChild(gameOverLabel)
    }

    // TODO: this is just for testing before getting the ml model
    func createElementButtons() {
        let buttonWidth: CGFloat = 30
        let buttonHeight: CGFloat = 30
        let buttonSpacing: CGFloat = 20
        let buttonNames = ["fire", "water", "earth", "air", "dark", "light"]

        for (index, name) in buttonNames.enumerated() {
            let button = SKSpriteNode(imageNamed: "\(name)")
            button.name = name
            button.position = CGPoint(x: 525 + CGFloat(index) * (buttonWidth + buttonSpacing) + buttonWidth / 2, y: buttonHeight + 100)
            button.setScale(0.5)
            addChild(button)
            elementButtons.append(button)
        }
    }
    
    func processJutsuMove() {
        let jutsuMove = AppModel.appModel.prediction
        if jutsuMove != currentJutsuPose {
            currentJutsuPose = jutsuMove
            if currentJutsuPose != .unknown {
                attackWithElement(element: currentJutsuPose.rawValue)
            }
        }
    }
}
