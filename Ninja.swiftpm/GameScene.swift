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
    var mistakes: Int = 0
    var lives: Int = 5
    var horizonLevelOffset: CGFloat = -200
    var lastSpawnedEnemyType: String = ""
    var lastHeartSpawnedAt: Int = -30

    var scoreLabel: SKLabelNode!
    var timeLabel: SKLabelNode!
    var livesLabel: SKLabelNode!
    var dialogueLabel: SKLabelNode!
    
    var developerToggle: SKSpriteNode!
    var mlModeOn: Bool = false
    
    var enemySpeedBase: CGFloat = 7.0
    var spawnTimeIntervalBase: TimeInterval = 7.0

    var difficultyToggle: SKSpriteNode!
    var currentDifficulty: String = "normal"
    var spawnTimeIntervalMultiplier: CGFloat = 1.0
    var spawnTimeMinimum: TimeInterval = 3.0
    var enemySpeedMultiplier: CGFloat = 1.0
    
    var elementButtons: [SKSpriteNode] = []
    
    var isGameOver: Bool = false
    
    var currentJutsuPose: NinjaMoves = .unknown
    
    override func update(_ currentTime: TimeInterval) {
        
        // update labels
        scoreLabel.text = "Yokais Defeated: \(enemiesKilled)"
        
        if lives < 0 { lives = 0 }
        livesLabel.text = String(repeating: "❤️", count: lives)
        
        // collisions
        for enemy in enemies {
            
            // player has been hit
            if enemy.frame.intersects(ninja.frame) {
                
                let enemyType = enemy.userData?["type"] as? String ?? ""
                
                if enemyType == "heart" {
                    // hearts don't hurt but you lose it sooo
                    showDialogue(text: "Oh no! You missed the heart...")
                } else {
                    
                    lives -= 1
                    
                    if lives == 0 {
                        gameOver(win: false)
                    } else {
                        let dialogue = ["Are you alright, young warrior?", "Careful, young warrior!", "Watch out, young warrior!"].randomElement() ?? ""
                        showDialogue(text: dialogue)
                        
                        // ninja gets hurt, run animation
                        ninja.texture = SKTexture(imageNamed: "ninja-hurt")
                        
                        let moveBackAction = SKAction.moveBy(x: -15, y: 0, duration: 0.2)
                        
                        let revertTextureAction = SKAction.sequence([
                            moveBackAction,
                            SKAction.wait(forDuration: 1.0),
                            SKAction.run {
                                self.ninja.texture = SKTexture(imageNamed: "ninja-default")
                            },
                            SKAction.moveBy(x: 15, y: 0, duration: 0.2)
                        ])
                        
                        ninja.run(revertTextureAction)
                        
                        run(SKAction.playSoundFileNamed("sfx-oof.mp3", waitForCompletion: false))
                    }
                    
                    enemy.removeFromParent()
                    enemies.removeAll { $0 == enemy }
                }
            }
            
            // attack is hitting enemy
            for attack in attacks {
                if attack.frame.intersects(enemy.frame) {
                    if let attackType = attack.userData?["type"] as? String,
                       let enemyType = enemy.userData?["type"] as? String {
                        
                        // successful attack
                        if attackType == enemyType {
                            
                            enemy.removeFromParent()
                            enemies.removeAll { $0 == enemy }
                            
                            attack.removeFromParent()
                            attacks.removeAll { $0 == attack }
                            
                            playAttackAnimation(at: enemy.position, texture: SKTexture(imageNamed: "\(enemyType)-particle"))
                            
                            
                            if (enemyType == "heart") {
                                lives += 1
                                
                                run(SKAction.playSoundFileNamed("sfx-heart.mp3", waitForCompletion: false))
                                
                                let dialogue = ["A heart! Wonderful!", "Stay safe, young warrior!"].randomElement() ?? ""
                                showDialogue(text: dialogue)
                            } else {
                                enemiesKilled += 1
                                run(SKAction.playSoundFileNamed("sfx-hit.mp3", waitForCompletion: false))
                                
                                if enemiesKilled >= 100 {
                                    gameOver(win: true)
                                }
                                
                                
                                if enemiesKilled % 11 == 0 && enemiesKilled != 0 {
                                    var dialogue: String?
                                    
                                    if timeAlive>85 { // two pools of messages based on time for variety
                                        dialogue  = ["You are the pride of our clan!", "You are on fire!", "Remember your training!", "Watch out, they get faster!", "Victory comes at a 100 exorcisms...", "Sensei is thrilled!", "Sensei is getting nostalgic... Ho ho ho!", "You are doing better than when I first started! Ho ho!"].randomElement()
                                    } else {
                                        dialogue = ["Beware, they slowly increase in variety!", "Ho ho... You are learning quite fast...", "Sensei is right here, he is merely camouflaged!", "Don't worry, sensei will pick you up if you get too hurt."].randomElement()
                                    }
                                    
                                    showDialogue(text: dialogue ?? "")
                                }
                                if enemiesKilled % 25 == 0 && enemiesKilled != 0 {
                                    let dialogue = "Thats \(enemiesKilled)! Sensei is proud!"
                                    showDialogue(text: dialogue)
                                }
                            }
                            
                            print("enemy type \(attackType) destroyed")
                            
                        // case where attack type and monster don't match (failed attack)
                        } else {
                            // removing a life is too harsh, but it will be evaluated
                            // lives -= 1
                            mistakes += 1 // counted for final accuracy rating
                            
                            attack.removeFromParent()
                            attacks.removeAll { $0 == attack }
                            
                            let failedAttackAnimation = SKEmitterNode(fileNamed: "X.sks")
                            failedAttackAnimation?.position = attack.position
                            failedAttackAnimation!.particleTexture = SKTexture(imageNamed: "x")
                            addChild(failedAttackAnimation!)
                            
                            let removeAction = SKAction.sequence([SKAction.wait(forDuration: 0.2), SKAction.removeFromParent()])
                            failedAttackAnimation!.run(removeAction)
                            
                            run(SKAction.playSoundFileNamed("sfx-wrong.mp3", waitForCompletion: false))
                            
                            print("failed attack")
                        }
                    }
                }
            }
        }
        
        processJutsuMove()
    }

    
    override func didMove(to view: SKView) {
        AppModel.appModel.gameStarted = true
        
        // set bg
        self.backgroundColor = SKColor.black
        let background = SKSpriteNode(imageNamed: "bg-dojo")
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        
        background.size = CGSize(width: self.size.width, height: self.size.height)
        
        background.zPosition = -1
        addChild(background)
        
        // ninja
        ninja = SKSpriteNode(imageNamed: "ninja-default")
        ninja.position = CGPoint(x: 150, y: self.size.height / 2 + horizonLevelOffset)
        ninja.zPosition = 1
        addChild(ninja)
        
        // score/stat labels
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
        livesLabel.position = CGPoint(x: self.size.width - 25, y: self.size.height - 160)
        livesLabel.fontSize = 40
        livesLabel.fontColor = .white
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.fontName = "Arial-Bold"
        addChild(livesLabel)
        
        // dialogue label
        dialogueLabel = SKLabelNode(text: "")
        dialogueLabel.fontSize = 24
        dialogueLabel.fontColor = .white
        dialogueLabel.fontName = "Chalkduster"
        dialogueLabel.position = CGPoint(x: ninja.position.x, y: ninja.position.y + 100)
        dialogueLabel.alpha = 0 // init hidden
        addChild(dialogueLabel)
        
        // developer toggle
        developerToggle = SKSpriteNode(imageNamed: "btn-btnmode")
        developerToggle.position = CGPoint(x: 0 + developerToggle.size.width / 2 - 20, y: developerToggle.size.height / 2)
        developerToggle.setScale(0.7)
        addChild(developerToggle)
        
        // difficulty toggle
        difficultyToggle = SKSpriteNode(imageNamed: "btn-difficulty-normal")
        difficultyToggle.position = CGPoint(x: self.size.width - difficultyToggle.size.width / 2 + 20, y: developerToggle.size.height / 2 + 20)
        difficultyToggle.setScale(0.7)
        addChild(difficultyToggle)
        
        // time counter
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 1),
            SKAction.run { [weak self] in
                self?.timeAlive += 1
                self?.updateTimeLabel()
            }
        ])), withKey: "timeAliveCounter")
        
        // play bg music
        if let bgMusicUrl = Bundle.main.url(forResource: "music-game", withExtension: "mp3") {
            let backgroundMusic = SKAudioNode(url: bgMusicUrl)
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        }
        
        spawnEnemy()
        
        showDialogue(text: "It's time for some ninjutsu!")
    }
    
    func playAttackAnimation(at position: CGPoint, texture: SKTexture) {
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

    func spawnEnemy() {
        if isGameOver { return }
        
        let availableEnemyTypes = ["fire", "water", "earth", "air", "dark", "light"]
        let enemy: SKSpriteNode
        
        // player needs help
        if lives < 5 && (enemiesKilled % 8 == 0) && enemiesKilled != 0 && lastHeartSpawnedAt != enemiesKilled {
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
        enemy.size = CGSize(width: 100, height: 100)
        
        addChild(enemy)
        enemies.append(enemy)
        
        // enemy speed starts at 125%, but slowly reduces to base
        let enemySpeedAdjusted = enemySpeedBase * enemySpeedMultiplier
        let speed = max(enemySpeedAdjusted, enemySpeedAdjusted * 1.25 - (timeAlive / 20))
        let moveAction = SKAction.moveTo(x: -enemy.size.width - self.size.width, duration: TimeInterval(speed))
        let removeAction = SKAction.removeFromParent()
        let moveSequence = SKAction.sequence([moveAction, removeAction])
        
        enemy.run(moveSequence)
        
        // spawn time intervals start from 150% of base, reducing to normal 100%
        let spawnTimeIntervalAdjusted = spawnTimeIntervalBase * spawnTimeIntervalMultiplier
        let intervalFactor = max(spawnTimeIntervalAdjusted, spawnTimeIntervalAdjusted * 1.50 - (timeAlive / 10))
        let randomInterval = TimeInterval(.random(in: spawnTimeMinimum...intervalFactor))
            
        run(SKAction.wait(forDuration: randomInterval), completion: spawnEnemy)
    }

    func updateTimeLabel() {
        timeLabel.text = "Time Alive: \(Int(timeAlive))"
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver { return }
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if developerToggle.contains(location) {
                toggleDeveloperMode()
            } else if difficultyToggle.contains(location) {
                adjustDifficulty()
            }
            
            for button in elementButtons {
                if button.contains(location) {
                    attackWithElement(element: button.name ?? "")
                }
            }
        }
    }
    
    func toggleDeveloperMode() {
        run(SKAction.playSoundFileNamed("sfx-click.mp3", waitForCompletion: false))

        if mlModeOn {
            developerToggle.texture = SKTexture(imageNamed: "btn-mlmode")
            AppModel.appModel.gameStarted = false
            createElementButtons()
            mlModeOn = false
        } else {
            developerToggle.texture = SKTexture(imageNamed: "btn-btnmode")
            AppModel.appModel.gameStarted = true
            removeElementButtons()
            mlModeOn = true
        }
    }

    func attackWithElement(element: String) {
        run(SKAction.playSoundFileNamed("sfx-swish.mp3", waitForCompletion: false))
        
        let attack = SKSpriteNode(imageNamed: "\(element)")
        attack.size = CGSize(width: 50, height: 50)
        
        attack.position = ninja.position
        attack.userData = ["type": element]

        addChild(attack)
        attacks.append(attack)
        
        let moveAction = SKAction.moveTo(x: self.size.width + attack.size.width, duration: 2.0)
        let removeAction = SKAction.removeFromParent()

        if element == "heart" {
            // dont spin the hearts
            
            attack.run(SKAction.sequence([moveAction, removeAction]))

        } else {
            let spinAction = SKAction.repeatForever(SKAction.rotate(byAngle: .pi * -2, duration: 0.5))
            attack.run(SKAction.sequence([SKAction.group([moveAction, spinAction]), removeAction]))
        }
        
    }
    
    
    func gameOver(win: Bool) {
        
        isGameOver = true
        AppModel.appModel.gameStarted = false
        
        print("Game Over")
        
        // cleanup
        for attack in attacks { attack.removeFromParent() }
        for enemy in enemies { enemy.removeFromParent() }
        attacks.removeAll()
        enemies.removeAll()
        
        removeAction(forKey: "timeAliveCounter")
        
        let gameOverScene = GameOverScene(size: self.size)
        gameOverScene.timeSurvived = Int(timeAlive)
        gameOverScene.yokaisExorcised = enemiesKilled
        gameOverScene.mistakesMade = mistakes
        gameOverScene.wonGame = win

        if let view = self.view {
            let transition = SKTransition.fade(withDuration: 1.0)
            view.presentScene(gameOverScene, transition: transition)
        }
    }

    func createElementButtons() {
        let buttonWidth: CGFloat = 50
        let buttonHeight: CGFloat = 50
        let buttonSpacing: CGFloat = 25
        let buttonNames = ["fire", "water", "earth", "air", "dark", "light", "heart"]

        for (index, name) in buttonNames.enumerated() {
            let button = SKSpriteNode(imageNamed: "\(name)")
            button.size = CGSize(width: 50, height: 50)
            button.name = name
            button.position = CGPoint(x: developerToggle.size.width + buttonSpacing * 2 + CGFloat(index) * (buttonWidth + buttonSpacing) + buttonWidth / 2, y: buttonHeight)
            addChild(button)
            elementButtons.append(button)
        }
    }
    
    func removeElementButtons() {
        elementButtons.forEach { $0.removeFromParent() }
        elementButtons.removeAll()
    }
    
    func processJutsuMove() {
        if isGameOver { return }
        let jutsuMove = AppModel.appModel.prediction
        // print(jutsuMove.rawValue)
        if jutsuMove.rawValue != "unknown" && jutsuMove != currentJutsuPose && jutsuMove.rawValue != "default" { // the logic here might be a bit weird cz what if the user fails on the first and needs to do a double of the same type cz they made a mistake?
            currentJutsuPose = jutsuMove
            if currentJutsuPose != .unknown {
                attackWithElement(element: currentJutsuPose.rawValue)
            }
        }
    }
    
    func adjustDifficulty() {
        run(SKAction.playSoundFileNamed("sfx-click.mp3", waitForCompletion: false))

        // for speed multiplier, the higher the number, the more time the monsters will take to travel
        // for the spawn time interval, the smaller the number, the shorter the intervals, the more spawns
        // some of these calculations may cause an error cz i didn't check yet
        switch currentDifficulty {
        case "easy":
            spawnTimeIntervalMultiplier = 1.0
            enemySpeedMultiplier = 1.0
            spawnTimeMinimum = 3.0
            difficultyToggle.texture = SKTexture(imageNamed: "btn-difficulty-normal")
            currentDifficulty = "normal"
        case "normal":
            spawnTimeIntervalMultiplier = 0.7
            enemySpeedMultiplier = 0.8
            spawnTimeMinimum = 1.5
            difficultyToggle.texture = SKTexture(imageNamed: "btn-difficulty-hard")
            currentDifficulty = "hard"
        case "hard":
            spawnTimeIntervalMultiplier = 0.3
            enemySpeedMultiplier = 0.5
            spawnTimeMinimum = 0.1
            difficultyToggle.texture = SKTexture(imageNamed: "btn-difficulty-extreme")
            currentDifficulty = "extreme"
        case "extreme":
            spawnTimeIntervalMultiplier = 1.2
            enemySpeedMultiplier = 1.2
            spawnTimeMinimum = 4.0
            difficultyToggle.texture = SKTexture(imageNamed: "btn-difficulty-easy")
            currentDifficulty = "easy"
        default:
            break
        }
    }
}
