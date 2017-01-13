//
//  GameScene.swift
//  Bamboo Breakout
/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */ 

import SpriteKit
// GameState is in GameplayKit
import GameplayKit

let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "block"
let GameMessageName = "gameMessage"
let ScoreMessageName = "score"

// Define bitMask for Contact.
let BallCategory   : UInt32 = 0x1 << 0
let BottomCategory : UInt32 = 0x1 << 1
let BlockCategory  : UInt32 = 0x1 << 2
let PaddleCategory : UInt32 = 0x1 << 3
let BorderCategory : UInt32 = 0x1 << 4

class GameScene: SKScene, SKPhysicsContactDelegate {
    // For HUD
    //----------------------------------------
    var hudNode: SKNode!
    
    // Labels for score and stars
    var lblScore: SKLabelNode!
    var lblStars: SKLabelNode!
    //----------------------------------------
    
    var isFingerOnPaddle = false

    // Create state machine
    // The array in GKStateMachine is the state we need
    lazy var gameState: GKStateMachine = GKStateMachine(states: [WaitingForTap(scene: self), Playing(scene: self), GameOver(scene: self)])
    
    var gameWin : Bool = false {
        didSet {
            let gameOver = childNode(withName: GameMessageName) as! SKSpriteNode
            let textureName = gameWin ? "YouWon" : "GameOver"
            let texture = SKTexture(imageNamed: textureName)
            let actionSequence = SKAction.sequence([SKAction.setTexture(texture), SKAction.scale(to: 1.0, duration: 0.25)])
            
            gameOver.run(actionSequence)
        }
    }

    //  Implement didBegin(_:) to handle the collisions
    func didBegin(_ contact: SKPhysicsContact) {
        if gameState.currentState is Playing {
            var firstBody: SKPhysicsBody
            var secondBody: SKPhysicsBody

            // Sort collisions item in order
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }

            if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {
                // Change State because ball hit bottom
                gameState.enter(GameOver.self)
                gameWin = false
            }

            if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory {
                breakBlock(node: secondBody.node!)

                // change score
//                let score = childNode(withName: ScoreMessageName) as! SKLabelNode
//                let s = Int(score.text!)
//                score.text = String(s! + 1)
                // For HUD
                //----------------------------------------
                GameState.sharedInstance.score += 1
                lblScore.text = String(format: "%d", GameState.sharedInstance.score)
                //----------------------------------------
                // Check if the game has been win
                if isGameWin() {
                    // Change State because no block on the screen
                    gameState.enter(GameOver.self)
                    gameWin = true
                }
            }
        }
    }
  
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    
    // For HUD
    //----------------------------------------
    hudNode = SKNode()
    hudNode.zPosition = 10
    addChild(hudNode)
    
    // Build the HUD
    
    // Label "BEST"
    // 1
    let best = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
    best.fontSize = 30
    best.fontColor = SKColor.white
    best.position = CGPoint(x: 40, y: self.size.height-40)
    best.text = "BEST"
    hudNode.addChild(best)
    
    // 2
    lblStars = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
    lblStars.fontSize = 30
    lblStars.fontColor = SKColor.white
    lblStars.position = CGPoint(x: 80, y: self.size.height-40)
    lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
    lblStars.text = String(format: "%d", GameState.sharedInstance.highScore)
    hudNode.addChild(lblStars)
    
    // Score
    // 4
    lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
    lblScore.fontSize = 30
    lblScore.fontColor = SKColor.white
    lblScore.position = CGPoint(x: self.size.width-20, y: self.size.height-40)
    lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
    
    // 5
    lblScore.text = "0"
    hudNode.addChild(lblScore)
    //----------------------------------------

    // Set BG
    let bg = SKSpriteNode(imageNamed: "bg")
    bg.size.height = self.size.height
    bg.size.width = self.size.width
    bg.position = CGPoint(x: self.frame.midX, y: self.frame.midY)

    // Add edges to each side of screen
    let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    borderBody.allowsRotation = false
    borderBody.friction = 0
    //borderBody.restitution = 1
    borderBody.isDynamic = false
    self.physicsBody = borderBody

    // Remove gravity
    physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
    physicsWorld.contactDelegate = self

    let ball = childNode(withName: BallCategoryName) as! SKSpriteNode
    // Set the initial position of ball to center
    ball.position = CGPoint(x: self.frame.midX, y: self.frame.maxY * 0.5)

    // Add bottom edge to detect gameover
    let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
    let bottom = SKNode()
    bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
    addChild(bottom)

    // Setup masks
    let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode

    // Set bitMask to each object
    bottom.physicsBody!.categoryBitMask = BottomCategory
    ball.physicsBody!.categoryBitMask = BallCategory
    paddle.physicsBody!.categoryBitMask = PaddleCategory
    borderBody.categoryBitMask = BorderCategory

    // Will be notified when ball contact with bottom or block
    ball.physicsBody!.contactTestBitMask = BottomCategory | BlockCategory

    // Add blocks
    let numberOfBlocks = 28
    let blockWidth = SKSpriteNode(imageNamed: "block").size.width
    let blockHeight = SKSpriteNode(imageNamed: "block").size.height

    // xOffset will be used to place the block center
    let xOffset = (frame.width - blockWidth * 7) / 2
    var yOffset : CGFloat = 0

    if GameState.sharedInstance.easter == 1 {
        var arr = [Bool]()
        for _ in 0..<56 {
            arr.append(true)
        }
        // Random
        var randomNum:UInt32
        var i = 28
        while i > 0 {
            i -= 1
            randomNum = arc4random_uniform(56)
            if arr[Int(randomNum)] == true {
                arr[Int(randomNum)] = false
            } else {
                i += 1
            }
        }
        var x = 0, y = 0
        for i in 0..<56 {
            if arr[i] {
                x += 1
            } else {
                y += 1
            }
        }
        print("x ", x, "y ", y)
        // Place brick
        for i in 0..<56 {
            // Next Line
            if(i != 0 && i % 7 == 0) {
                yOffset = yOffset + blockHeight
                print("yOffset", yOffset, "i", i)
            }
            if arr[i] {
                let block = SKSpriteNode(imageNamed: "block.png")
                block.position = CGPoint(x: xOffset + CGFloat(CGFloat(i % 7) + 0.5) * blockWidth, y: frame.height - yOffset)
            
                block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                block.physicsBody!.allowsRotation = false
                block.physicsBody!.friction = 0.0
                block.physicsBody!.affectedByGravity = false
                block.physicsBody!.isDynamic = false
                block.name = BlockCategoryName
                block.physicsBody!.categoryBitMask = BlockCategory
                block.zPosition = 2
                addChild(block)
            }
        }
    } else {
        for i in 0..<numberOfBlocks {
            let block = SKSpriteNode(imageNamed: "block.png")
            
            // Next Line
            if(i != 0 && i % 7 == 0) {
                yOffset += blockHeight
            }
            block.position = CGPoint(x: xOffset + CGFloat(CGFloat(i % 7) + 0.5) * blockWidth, y: frame.height * 0.8 - yOffset)
            
            block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
            block.physicsBody!.allowsRotation = false
            block.physicsBody!.friction = 0.0
            block.physicsBody!.affectedByGravity = false
            block.physicsBody!.isDynamic = false
            block.name = BlockCategoryName
            block.physicsBody!.categoryBitMask = BlockCategory
            block.zPosition = 2
            addChild(block)
        }
    }

    // WaitingForTap State
    let gameMessage = SKSpriteNode(imageNamed: "TapToPlay")
    gameMessage.name = GameMessageName
    gameMessage.position = CGPoint(x: frame.midX, y: frame.midY)
    gameMessage.zPosition = 4
    gameMessage.setScale(0.0)
    addChild(gameMessage)

    gameState.enter(WaitingForTap.self)
  }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Enter when touch the screen
        switch gameState.currentState {
        case is WaitingForTap:
            // Start game if touched
            gameState.enter(Playing.self)
            isFingerOnPaddle = true
        case is Playing:
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            
            // Touch on the paddle
            if let body = physicsWorld.body(at: touchLocation) {
                if body.node!.name == PaddleCategoryName {
                    print("Began touch on paddle")
                    isFingerOnPaddle = true
                }
            }
        case is GameOver:
            // Touch to create a new scene, then enter state WaitingForTap
            let newScene = GameScene(fileNamed: "GameScene")
            newScene!.scaleMode = .aspectFit
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(newScene!, transition: reveal)
        default:
            break
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check whether the player is touching on the paddle
        if isFingerOnPaddle {
            // Get touch locations
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            let previousLocation = touch!.previousLocation(in: self)
            
            // Get SKSpriteNode of paddle
            let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
            
            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x);
            
            paddleX = max(paddleX, paddle.size.width/2)
            paddleX = min(paddleX, self.size.width - paddle.size.width/2)
            
            paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
        }
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnPaddle = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        gameState.update(deltaTime: currentTime)
    }

    // Show special effect when ball hit block
    func breakBlock(node: SKNode) {
        let particles = SKEmitterNode(fileNamed: "BrokenPlatform")!
        particles.position = node.position
        particles.zPosition = 3
        addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.removeFromParent()]))
        node.removeFromParent()
    }
    
    func randomFloat(from: CGFloat, to: CGFloat) -> CGFloat {
        let rand: CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return (rand) * (to - from) + from
    }
    
    // Check if there is any block
    func isGameWin() -> Bool {
        var numberOfBricks = 0
        self.enumerateChildNodes(withName: BlockCategoryName) {
            node, stop in
            numberOfBricks = numberOfBricks + 1
        }
        return numberOfBricks == 0
    }
}
