//
//  IntroductionScene.swift
//  Ninja
//
//  Created by Aki Xu on Feb 2025.
//

import SpriteKit

class IntroductionScene: SKScene {
    
    var sensei: SKSpriteNode!
    var player: SKSpriteNode!
    var dialogueBox: SKSpriteNode!
    var dialogueLabel: SKLabelNode!
    var tapToContinueLabel: SKLabelNode!
    var scrollImage: SKSpriteNode!
    
    // TODO: for each sensei dialogue, change his picture too
    let senseiExpressions = [
        "sensei_default",
        "sensei_firedup",
        "sensei_wink",
        "sensei_cry",
        "sensei_smile",
        "sensei_bruh",
        "sensei_thinking"
    ]
    
    let dialogueLines = [
        "I have flown down from the sky to remind you of your training!",
        "I have already taught you how to throw the ninja star and how to camouflage...",
        "But there is one last thing for me to teach you...",
        "Your final lesson to becoming a ninja master requires you to face the dangerous YOKAIs.",
        "These supernatural spirits... immune to ordinary attacks!",
        "The pesky YOKAIs come in 6 types - fire, water, earth, air, dark and light.",
        "To defeat them, you must learn the hidden ninja technique of hand JUTSUs!",
        "Passed from generation to generation, these ancient techniques are the only way to defeat the YOKAI...",
        "Young warrior, I shall now pass this knowledge to you! Take this scroll of wisdom... Take a close look!",
        "I hope you are deeply moved by this ancient knowledge.",
        "You’re asking me why it looks so... bad? This is a special version sensei made just for you!",
        "Now, try out the techniques for yourself! Remember, your technique must be exact for the JUTSU to work!",
        "Great. Now it is time for you to defeat the YOKAI.",
        "Do not fret, sensei will come for you in case you get hit too much or you make too many mistakes.",
        "Sensei is a little busy, but he will also throw you hearts which you can collect by doing the special heart JUTSU.",
        "You will officially become a ninja master after exorcising 100 YOKAI! Are you ready, young warrior?"
    ]
    
    var currentDialogueIndex = 0
    
    var walkingSound: SKAction?
    var footstepSoundPlayed = false
    
    override func didMove(to view: SKView) {
        setupScene()
        startCutscene()
    }
    
    func setupScene() {
        self.backgroundColor = .black
//        TODO: let background = SKSpriteNode(imageNamed: "bg")
//        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
//        background.zPosition = -1
//        addChild(background)
        
        // TODO: skip intro button
        
        sensei = SKSpriteNode(imageNamed: senseiExpressions[0])
        sensei.position = CGPoint(x: size.width * 0.5, y: size.height * 1.2)
        sensei.setScale(1.2)
        addChild(sensei)
        
        player = SKSpriteNode(imageNamed: "ninja-default")
        player.position = CGPoint(x: -100, y: size.height * 0.5)
        player.setScale(1.2)
        addChild(player)
        
        dialogueBox = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: CGSize(width: size.width * 0.8, height: 150))
        dialogueBox.position = CGPoint(x: size.width / 2, y: 100)
        dialogueBox.zPosition = 1
        addChild(dialogueBox)
        
        dialogueLabel = SKLabelNode(fontNamed: "Chalkduster")
        dialogueLabel.fontSize = 20
        dialogueLabel.fontColor = .white
        dialogueLabel.position = CGPoint(x: 0, y: -10)
        dialogueLabel.numberOfLines = 3
        dialogueLabel.preferredMaxLayoutWidth = dialogueBox.size.width - 20
        dialogueBox.addChild(dialogueLabel)
        
        tapToContinueLabel = SKLabelNode(fontNamed: "Chalkduster")
        tapToContinueLabel.fontSize = 18
        tapToContinueLabel.fontColor = .white
        tapToContinueLabel.text = "Tap to Continue"
        tapToContinueLabel.position = CGPoint(x: size.width / 2, y: 40)
        addChild(tapToContinueLabel)
        
        scrollImage = SKSpriteNode(imageNamed: "dojo")
        scrollImage.position = CGPoint(x: size.width / 2, y: size.height / 2)
        scrollImage.zPosition = 2
        scrollImage.isHidden = true
        addChild(scrollImage)
        
        if let bgMusicUrl = Bundle.main.url(forResource: "music-base", withExtension: "mp3") {
            let backgroundMusic = SKAudioNode(url: bgMusicUrl)
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        }
    }
    
    func startCutscene() {
        // FIXME: how to make it wait until animations are done? currently, you can still tap on the screen when the animations are still playing...
        
        let walkInAction = SKAction.move(to: CGPoint(x: size.width * 0.8, y: size.height * 0.5), duration: 3)
        player.run(walkInAction)

        walkingSound = SKAction.playSoundFileNamed("sfx-footsteps.mp3", waitForCompletion: false)
        let soundAction = SKAction.repeat(walkingSound!, count: 3)
        player.run(soundAction)

        let delayActionForSensei = SKAction.wait(forDuration: 2.0)
        let flyInAction = SKAction.move(to: CGPoint(x: size.width * 0.2, y: size.height * 0.5), duration: 2)

        let stopSoundAction = SKAction.run {
            self.run(SKAction.stop())
        }

        let sequence = SKAction.sequence([delayActionForSensei, flyInAction])
        sensei.run(sequence)

        let stopSoundSequence = SKAction.sequence([SKAction.wait(forDuration: 2.0), stopSoundAction])
        run(stopSoundSequence)

        let dialogueAction = SKAction.run {
            self.dialogueLabel.text = "Hmm, I hear loud footsteps... Are you stomping around, young warrior?"
        }

        let dialogueSequence = SKAction.sequence([delayActionForSensei, dialogueAction])
        run(dialogueSequence)
    }
    
    func showNextDialogue() {
        
        switch currentDialogueIndex {
        case 1:
            sensei.texture = SKTexture(imageNamed: senseiExpressions[1])
        case 3:
            sensei.texture = SKTexture(imageNamed: senseiExpressions[2])
        case 9:
            run(SKAction.playSoundFileNamed("sfx-paper.mp3", waitForCompletion: false))
            scrollImage.isHidden = false // TODO: update with proper scroll iamge
        case 10:
             run(SKAction.playSoundFileNamed("sfx-paper.mp3", waitForCompletion: false))
            scrollImage.isHidden = true
        case 12:
            // TODO: a lil tryout box should happen here, with a preview camera, and a label that says what jutsu the user is doing
            break
        default:
            sensei.texture = SKTexture(imageNamed: senseiExpressions[0])
        }
        
        if currentDialogueIndex < dialogueLines.count {
            dialogueLabel.text = "Sensei: " + dialogueLines[currentDialogueIndex]
            currentDialogueIndex += 1
        } else {
            startGame()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(SKAction.playSoundFileNamed("sfx-click.mp3", waitForCompletion: false))
        showNextDialogue()
    }
    
    func startGame() {
        let transition = SKTransition.fade(withDuration: 1)
        let gameScene = GameScene(size: self.size)
        AppModel.appModel.gameStarted = true
        self.view?.presentScene(gameScene, transition: transition)
    }
}
