//
//  GameoverScene.swift
//  Ninja
//
//  Created by Aki Xu on Feb 2025.
//

import SpriteKit

class GameOverScene: SKScene {
    
    var timeSurvived: Int = 0
    var yokaisExorcised: Int = 0
    var mistakesMade: Int = 0
    var wonGame: Bool = false
    
    var replayIntroButton: SKSpriteNode!
    var cheatSheetButton: SKSpriteNode!
    var retrainButton: SKSpriteNode!
    var cheatSheetIsOpen: Bool = false

    override func didMove(to view: SKView) {
        if wonGame {
            setupSpecial()
        } else {
            setupScene()
        }
        
        setupButtons()
        setupMusic()
    }
    
    func setupMusic() {
        if let bgMusicUrl = Bundle.main.url(forResource: "music-gameover", withExtension: "mp3") {
            let backgroundMusic = SKAudioNode(url: bgMusicUrl)
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        }
    }
    
    func setupSpecial() {
        let background = SKSpriteNode(imageNamed: "bg-special")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = self.size
        background.zPosition = -1
        addChild(background)
    }
    
    func setupScene() {
        let background = SKSpriteNode(imageNamed: "bg-trainingresults")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = self.size
        background.zPosition = -1
        addChild(background)

        // sensei's message
        var senseiMessageText = ""

        switch yokaisExorcised {
        case 100...:
            senseiMessageText = "The path ahead is yours to walk. (PS Thank you for playing!)"
        case 75..<100:
            senseiMessageText = "I have taught you everything... Sensei is very proud!"
        case 50..<75:
            senseiMessageText =  "Excellent! A ninja is not measured by strength, but by perseverance!"
        case 30..<50:
            senseiMessageText = "Perhaps you are ready for your black belt! Greatness awaits you."
        case 15..<30:
            senseiMessageText = "Ho ho! You are on your path to becoming a great ninja master..."
        case 10..<15:
            senseiMessageText = "Continue your training! Every defeat is a lesson."
        default:
            senseiMessageText = "The journey of a ninja is long, but every step counts."
        }

        let senseiMessage = SKLabelNode(fontNamed: "Chalkduster")
        senseiMessage.text = "\"\(senseiMessageText)\""
        senseiMessage.fontSize = 24
        senseiMessage.position = CGPoint(x: size.width / 2, y: size.height * 0.63)
        senseiMessage.fontColor = .black
        addChild(senseiMessage)


        // show statistics
        
        let statsLabel = SKLabelNode(fontNamed: "Arial-Bold")
        statsLabel.text = "Time Alive: \(timeSurvived)    Yokais Exorcised: \(yokaisExorcised)"
        statsLabel.fontSize = 24
        statsLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        statsLabel.fontColor = .black
        addChild(statsLabel)
        
        let totalAttacks = yokaisExorcised + mistakesMade
        var accuracy: Int = 0

        if totalAttacks != 0 { // check to make sure no zero div error
            accuracy = Int((((Double(yokaisExorcised) / Double(totalAttacks))) * 100).rounded(.down))
        }

        let accuracyLabel = SKLabelNode(fontNamed: "Arial-Bold")
        accuracyLabel.text = "Attack Accuracy: \(yokaisExorcised)/\(totalAttacks) = \(accuracy)%"
        accuracyLabel.fontSize = 24
        accuracyLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.48)
        accuracyLabel.fontColor = .black
        addChild(accuracyLabel)
        
    }
    
    func setupButtons() {
        replayIntroButton = SKSpriteNode(imageNamed: "btn-replayintro")
        replayIntroButton.position = CGPoint(x: self.size.width - replayIntroButton.size.width / 2 + 20, y: self.size.height - replayIntroButton.size.height / 2)
        replayIntroButton.setScale(0.7)
        addChild(replayIntroButton)
        
        cheatSheetButton = SKSpriteNode(imageNamed: "btn-cheatsheet")
        cheatSheetButton.position = CGPoint(x: 0 + cheatSheetButton.size.width / 2 - 20, y: self.size.height - cheatSheetButton.size.height / 2)
        cheatSheetButton.setScale(0.7)
        addChild(cheatSheetButton)
        
        retrainButton = SKSpriteNode(imageNamed: "btn-continuetraining")
        retrainButton.position = CGPoint(x: self.size.width / 2, y: size.height * 0.38)
        retrainButton.setScale(0.7)
        addChild(retrainButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if replayIntroButton.contains(touches.first?.location(in: self) ?? CGPoint.zero) {
            replayIntro()
            run(SKAction.playSoundFileNamed("sfx-click.mp3", waitForCompletion: false))
        } else if cheatSheetButton.contains(touches.first?.location(in: self) ?? CGPoint.zero) {
            openCheatSheet()
        } else if retrainButton.contains(touches.self.first?.location(in: self) ?? CGPoint.zero) {
            restartGame()
            run(SKAction.playSoundFileNamed("sfx-click.mp3", waitForCompletion: false))
        } else {
            closeCheatSheet()
        }
    }

    func restartGame() {
        if cheatSheetIsOpen {
            closeCheatSheet()
            return
        } // bad implementation
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = self.scaleMode
        self.view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 0.5))
    }
    
    func replayIntro() {
        if cheatSheetIsOpen {
            closeCheatSheet()
            return
        } // bad implementation

        let introScene = IntroductionScene(size: self.size)
        introScene.scaleMode = self.scaleMode
        self.view?.presentScene(introScene, transition: SKTransition.fade(withDuration: 0.5))
    }
    
    
    func openCheatSheet() {
        if cheatSheetIsOpen {
            closeCheatSheet()
            return
        } // bad implementation
        run(SKAction.playSoundFileNamed("sfx-paper.mp3", waitForCompletion: false))
        
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: self.size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 10
        overlay.name = "cheatSheetOverlay"
        addChild(overlay)
        
        let cheatSheet = SKSpriteNode(imageNamed: "cheatsheet")
        cheatSheet.position = CGPoint(x: size.width / 2, y: size.height / 2)
        cheatSheet.zPosition = 11
        cheatSheet.setScale(0.7)
        cheatSheet.name = "cheatSheetImage"
        addChild(cheatSheet)
        
        let closeButton = SKSpriteNode(color: UIColor.clear, size: overlay.size)
        closeButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        closeButton.name = "closeButton"
        closeButton.zPosition = 12
        addChild(closeButton)
        
        cheatSheetIsOpen = true
    }
    
    func closeCheatSheet() {
        run(SKAction.playSoundFileNamed("sfx-paper.mp3", waitForCompletion: false))

        cheatSheetIsOpen = false
        if let overlay = childNode(withName: "cheatSheetOverlay") {
            overlay.removeFromParent()
        }
        if let cheatSheet = childNode(withName: "cheatSheetImage") {
            cheatSheet.removeFromParent()
        }
        if let closeButton = childNode(withName: "closeButton") {
            closeButton.removeFromParent()
        }
    }

}
