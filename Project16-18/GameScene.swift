//
//  GameScene.swift
//  Project16-18
//
//  Created by Gitko Denis on 26.07.2022.
//

import SpriteKit

class GameScene: SKScene {
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }
    
    var bulletNode: SKSpriteNode!
    var bulletLabel: SKLabelNode!
    var bulletsCount = 6 {
        didSet {
            changeBulletsCount()
        }
    }
    
    var reloadLabel: SKLabelNode!
    
    var targetNode: SKSpriteNode!
    
    var gameTimer: Timer!
    
    var barbedWireYPositions = [Int]()
    
    let allTargets = ["goodTarget", "goodTargetAlt", "badTarget", "badTargetAlt"]

    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "backgroundWall")
        background.size = CGSize(width: frame.size.width, height: frame.size.height)
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.blendMode = .replace
        background.zPosition = -5
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.position = CGPoint(x: 30, y: frame.size.height - 80)
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
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {

            if node.name == "good" || node.name == "bad" {
                if bulletsCount == 0 {
                    self.run(SKAction.playSoundFileNamed("emptyClip", waitForCompletion: false))
                } else {
                    node.removeFromParent()
                    self.run(SKAction.playSoundFileNamed("shootSound.wav", waitForCompletion: false))
                    bulletsCount -= 1
                }
 
            }
            else if node.name == "good" {
                print("good tapped")
            } else if node.name == "bad" {
                print("bad tapped")
            } else if node.name == "reload" {
                bulletsCount = 6
                reloadLabel.isHidden = true
                self.run(SKAction.playSoundFileNamed("reload.wav", waitForCompletion: false))
            }
        }
 
        
    }
    
    
    @objc func createTarget() {
        for line in barbedWireYPositions {
            guard let targetName = allTargets.randomElement() else { return }
            
            targetNode = SKSpriteNode(imageNamed: targetName)
            if targetName == "goodTarget" || targetName == "goodTargetAlt" {
                targetNode.name = "good"
            } else {
                targetNode.name = "bad"
            }
            
            targetNode.zPosition = 5
            
            let size = CGFloat.random(in: 30...100)
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
            print("empty")
        }
    }
    
 
}
