//
//  GameScene.swift
//  Project16-18
//
//  Created by Gitko Denis on 26.07.2022.
//

import SpriteKit

class GameScene: SKScene {
    let defaults = UserDefaults.standard
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var bulletNode: SKSpriteNode!
    var bulletLabel: SKLabelNode!
    var bulletsCount = 6 {
        didSet {
            changeBulletsCount()
        }
    }
    
    var countdownCount: Int! {
        didSet {
            countdownLabel.text = "\(countdownCount!)"
        }
    }
    var countdownTimer: Timer!
    var countdownLabel: SKLabelNode!
    
    var reloadLabel: SKLabelNode!
    
    var targetNode: SKSpriteNode!
    
    var gameTimer: Timer!
    

    
    var barbedWireYPositions = [Int]()
    
    let allTargets = ["goodTarget", "goodTarget2", "goodTarget3", "goodTarget4", "badTarget"]

    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "backgroundWall")
        background.size = CGSize(width: frame.size.width, height: frame.size.height)
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.blendMode = .replace
        background.zPosition = -5
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.position = CGPoint(x: 40, y: frame.size.height - 60)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.zPosition = 1
        addChild(scoreLabel)

        
//        Creating barbed wires on the background
        for i in 0...1 {
            let barbedWire = SKSpriteNode(imageNamed: "barbedWire")
            barbedWire.size = CGSize(width: frame.size.width + 200, height: 300)
            barbedWire.position = CGPoint(x: Int(frame.size.width) / 2, y: Int(i * 130) + 150)
            
            barbedWireYPositions.append(Int(barbedWire.position.y))
            
            addChild(barbedWire)
        }
        
//       Adding targets to screen

        gameTimer = Timer.scheduledTimer(timeInterval: Double.random(in: 1...1.2), target: self, selector: #selector(createTarget), userInfo: nil, repeats: true)
        
        bulletNode = SKSpriteNode(imageNamed: "bullet")
        bulletNode.size = CGSize(width: 15, height: 40)
        bulletNode.position = CGPoint(x: 80, y: 75)
        bulletNode.zPosition = 5
        addChild(bulletNode)
        
        bulletLabel = SKLabelNode(fontNamed: "Chalkduster")
        bulletLabel.zPosition = 5
        bulletLabel.fontSize = 40
        bulletLabel.text = "6"
        bulletLabel.position = CGPoint(x: 120, y: 60)
        addChild(bulletLabel)
        
        reloadLabel = SKLabelNode(fontNamed: "Chalkduster")
        reloadLabel.fontColor = .red
        reloadLabel.zPosition = 5
        reloadLabel.fontSize = 60
        reloadLabel.position = CGPoint(x: CGFloat(frame.size.width) / 1.5, y: 60)
        reloadLabel.text = "RELOAD"
        reloadLabel.name = "reload"
        reloadLabel.isHidden = true
        addChild(reloadLabel)
        
        
        countdownLabel = SKLabelNode(fontNamed: "Chalkduster")
        countdownLabel.text = "Score: 0"
        countdownLabel.fontSize = 30
        countdownLabel.position = CGPoint(x: CGFloat(frame.size.width / 2 - 30), y: frame.size.height - 80)
        countdownLabel.horizontalAlignmentMode = .left
        countdownLabel.zPosition = 1
        addChild(countdownLabel)
        
        countdownCount = 59
        
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            if let nodeName = node.name {
                
                if nodeName.contains("good") || nodeName.contains("bad") {
                    if bulletsCount == 0 {
                        self.run(SKAction.playSoundFileNamed("emptyClip", waitForCompletion: false))
                    } else {
                        switch nodeName {
                       case "good": score += 1
                       case "good2": score += 2
                       case "good3": score += 3
                       case "good4": score += 4
                       case "bad": score -= 5
                       default: return
                        }
                        bulletsCount -= 1
                        self.run(SKAction.playSoundFileNamed("shootSound", waitForCompletion: false))
                        node.run(SKAction.fadeOut(withDuration: 0.5))
                    }
                }
                if nodeName == "reload" {
                    self.run(SKAction.playSoundFileNamed("reload", waitForCompletion: false))
                    bulletsCount = 6
                    reloadLabel.isHidden = true
                }
            }

        }
        
    }
    
    
    @objc func createTarget() {
        for line in barbedWireYPositions {
            guard let targetName = allTargets.randomElement() else { return }
            
            targetNode = SKSpriteNode(imageNamed: targetName)
            switch targetName {
            case "goodTarget": targetNode.name = "good"
            case "goodTarget2": targetNode.name = "good2"
            case "goodTarget3": targetNode.name = "good3"
            case "goodTarget4": targetNode.name = "good4"
            default: targetNode.name = "bad"
            }
            
            targetNode.zPosition = 5
            

// Targets have different size depending on their color, e.g. smaller targets give better score
            let size: CGFloat
            switch targetNode.name {
            case "good": size = 90
            case "good2": size = 70
            case "good3": size = 50
            case "good4": size = 30
            default: size = 110
            }
            
            targetNode.size = CGSize(width: size, height: size)
            
            targetNode.position.y = CGFloat(line)
                    
            
    //        If it's the upper or lower line, position the targets on the left side of the screen, if it's the middle line, position it on the right
            if targetNode.position.y == CGFloat(barbedWireYPositions[1]) {
                targetNode.position.x = -100.0
            } else {
                targetNode.position.x = CGFloat(frame.size.width + 100)
            }

            addChild(targetNode)
            
            moveTargets()
        }
    }
    
    func moveTargets() {
        //        Move the targets on x axis from start to end of the lines and off the screen
                if targetNode.position.x == -100.0 {
               
                    targetNode.run(SKAction.moveBy(x: CGFloat(frame.size.width + 200), y: 0, duration: 4))
                } else if targetNode.position.x == CGFloat(frame.size.width + 100) {
                    
                    targetNode.run(SKAction.moveBy(x: CGFloat(-frame.size.width - 200), y: 0, duration: 4))
            }
    }
    
    func changeBulletsCount() {
        bulletLabel.text = "\(bulletsCount)"
        
        if bulletsCount == 0 {
            reloadLabel.isHidden = false
            self.run(SKAction.playSoundFileNamed("emptyClip", waitForCompletion: false))
        }
    }
    
    @objc func updateCounter() {
        countdownCount -= 1
        if countdownCount == 0 {
            
            countdownTimer.invalidate()
            gameTimer.invalidate()
            
            for node in self.children {
                if node.name == "good" || node.name == "bad" {
                    node.removeFromParent()
                }
            }
            
            getFinalScore()
        }
    }
    
    
    func getFinalScore() {
        let bestScore = defaults.object(forKey: "bestScore") as? Int ?? 0
        let title: String
        
        
        if score > bestScore {
            defaults.set(score, forKey: "bestScore")
            title = "New high score!"
        } else {
            title = "Game over"
        }
        

        let ac = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
        view?.window?.rootViewController?.present(ac, animated: true)

        
    }
    
 
}
