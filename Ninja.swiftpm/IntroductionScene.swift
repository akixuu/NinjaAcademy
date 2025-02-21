//
//  IntroductionScene.swift
//  Ninja
//
//  Created by Aki Xu on Feb 2025.
//

import SpriteKit

class IntroductionScene: SKScene {
    
    var sensei: SKSpriteNode!
    var ninja: SKSpriteNode!
    var dialogueBox: SKSpriteNode!
    var dialogueLabel: SKLabelNode!
    var tapToContinueLabel: SKLabelNode!
    var scrollImage: SKSpriteNode!
    var skipIntroButton: SKSpriteNode!
    
    var isAnimating = true
    
    let dialogueData: [(String, String)] = [
        ("I have flown down from the sky to remind you of your training!", "sensei-default"),
        ("I have already taught you how to throw the ninja star and how to camouflage...", "sensei-firedup"),
        ("But there is one last thing for me to teach you...", "sensei-wink"),
        ("Your final lesson to becoming a ninja master requires you to face the dangerous YOKAIs.", "sensei-cry"),
        ("These supernatural spirits... immune to ordinary attacks!", "sensei-smile"),
        ("The pesky YOKAIs come in 6 types - fire, water, earth, air, dark and light.", "sensei-bruh"),
        ("To defeat them, you must learn the hidden ninja technique of hand JUTSUs!", "sensei-thinking"),
        ("Passed from generation to generation, these ancient techniques are the only way to defeat the YOKAI...", "sensei-default"),
        ("Young warrior, I shall now pass this knowledge to you! Take this scroll of wisdom... Take a close look!", "sensei-firedup"),
        ("I hope you are deeply moved by this ancient knowledge.", "sensei-wink"),
        ("You’re asking me why it looks so... bad? This is a special version sensei made just for you!", "sensei-cry"),
        ("Now, try out the techniques for yourself! Remember, your technique must be exact for the JUTSU to work!", "sensei-smile"),
        ("Great. Now it is time for you to defeat the YOKAI.", "sensei-bruh"),
        ("Do not fret, sensei will come for you in case you get hit too much or you make too many mistakes.", "sensei-thinking"),
        ("Sensei is a little busy, but he will also throw you hearts which you can collect by doing the special heart JUTSU.", "sensei-default"),
        ("You will officially become a ninja master after exorcising 100 YOKAI! Are you ready, young warrior?", "sensei-firedup")
    ]
    
    var currentDialogueIndex = 0
    
    var walkingSound: SKAction?
    
    var ranScene = 0
    override func update(_ currentTime: TimeInterval) {
        
        if ranScene != currentDialogueIndex {
            switch currentDialogueIndex {
            case 1:
                break
            case 9:
                run(SKAction.playSoundFileNamed("sfx-paper.mp3", waitForCompletion: false))
                scrollImage.isHidden = false
            case 10:
                 run(SKAction.playSoundFileNamed("sfx-paper.mp3", waitForCompletion: false))
                scrollImage.isHidden = true
            case 12:
                AppModel.appModel.tutorialStarted = true
            case 13:
                AppModel.appModel.tutorialStarted = false
                break
            default:
                break
            }
            ranScene = currentDialogueIndex
        }
    }

    
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
                
        sensei = SKSpriteNode(imageNamed: "sensei-default")
        sensei.position = CGPoint(x: size.width * 0.2, y: size.height * 1.2)
        sensei.setScale(1.2)
        addChild(sensei)
        
        ninja = SKSpriteNode(imageNamed: "ninja-default")
        ninja.position = CGPoint(x: -100, y: size.height * 0.5)
        ninja.setScale(1.2)
        addChild(ninja)
        
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
        
        tapToContinueLabel = SKLabelNode(fontNamed: "Arial-Bold")
        tapToContinueLabel.fontSize = 18
        tapToContinueLabel.fontColor = .white
        tapToContinueLabel.text = "Tap to Continue"
        tapToContinueLabel.position = CGPoint(x: size.width / 2, y: 40)
        tapToContinueLabel.isHidden = true
        addChild(tapToContinueLabel)
        
        skipIntroButton = SKSpriteNode(imageNamed: "btn-skipintro")
        skipIntroButton.position = CGPoint(x: self.size.width - skipIntroButton.size.width / 2 + 20, y: self.size.height - skipIntroButton.size.height / 2)
        skipIntroButton.setScale(0.7)
        addChild(skipIntroButton)
        
        scrollImage = SKSpriteNode(imageNamed: "bg-dojo")
        scrollImage.position = CGPoint(x: size.width / 2, y: size.height / 2)
        scrollImage.zPosition = 2
        scrollImage.isHidden = true
        addChild(scrollImage)
    }
    
    func startCutscene() {
        // FIXME: how to make it wait until animations are done? currently, you can still tap on the screen when the animations are still playing...
        
        // player (ninja) comes walking in
        let walkInAction = SKAction.move(to: CGPoint(x: size.width * 0.8, y: size.height * 0.4), duration: 3)
        
        // FIXME: footsteps continually play
        let walkingSoundDuration = walkInAction.duration
        let walkingSound = SKAction.playSoundFileNamed("sfx-footsteps.mp3", waitForCompletion: false)
        let waitForSound = SKAction.wait(forDuration: walkingSoundDuration)
        let stopSoundAction = SKAction.run { self.run(SKAction.stop()) }
        let soundSequence = SKAction.sequence([walkingSound, waitForSound, stopSoundAction])
        ninja.run(soundSequence)
        
        // sensei comes flying in
        let dialogueAction = SKAction.run {
            self.dialogueLabel.text = "Hmm, I hear loud footsteps... Are you stomping around, young warrior?"
        }
        
        if let bgMusicUrl = Bundle.main.url(forResource: "music-base", withExtension: "mp3") {
            let backgroundMusic = SKAudioNode(url: bgMusicUrl)
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        }
        
        let delayActionForSensei = SKAction.wait(forDuration: 3.0)
        let flyInAction = SKAction.move(to: CGPoint(x: size.width * 0.2, y: size.height * 0.4), duration: 2)
        run(SKAction.sequence([delayActionForSensei, dialogueAction]))

        let sequence = SKAction.sequence([delayActionForSensei, flyInAction])
        sensei.run(sequence)
        
        
        tapToContinueLabel.isHidden = false
        isAnimating = false
    }
    
    func showNextDialogue() {
        
        if isAnimating { return } // dont let them skip while animating
        
        if currentDialogueIndex < dialogueData.count {
            let (dialogue, expression) = dialogueData[currentDialogueIndex]
            print(expression)

            self.sensei.texture = SKTexture(imageNamed: expression)
            dialogueLabel.text = "SENSEI: " + dialogue

            currentDialogueIndex += 1
        } else {
            startGame()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if skipIntroButton.contains(touches.first?.location(in: self) ?? CGPoint.zero) {
            startGame()
        } else {
            run(SKAction.playSoundFileNamed("sfx-click.mp3", waitForCompletion: false))
            showNextDialogue()
        }
    }
    
    func startGame() {
        let transition = SKTransition.fade(withDuration: 1)
        let gameScene = GameScene(size: self.size)
        AppModel.appModel.gameStarted = true
        self.view?.presentScene(gameScene, transition: transition)
    }
}
