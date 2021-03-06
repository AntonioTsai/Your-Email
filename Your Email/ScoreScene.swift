//
//  ScoreScene.swift

import SpriteKit
// GameState is in GameplayKit
// import GameplayKit

class ScoreScene: SKScene {
    
    //  Implement didBegin(_:) to handle the collisions
    func didBegin(_ contact: SKPhysicsContact) {
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
//        print("%d", GameState.sharedInstance.score)
//        print("%d", GameState.sharedInstance.highScore)
        
        // Label to Display Score
        let lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblScore.fontSize = 60
        lblScore.fontColor = SKColor.white
        lblScore.position = CGPoint(x: 0, y: 0)
        lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        lblScore.text = String(format: "%d", GameState.sharedInstance.score)
        addChild(lblScore)
        
        // Label to Display High Score
        let lblHighScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblHighScore.fontSize = 30
        lblHighScore.fontColor = SKColor.cyan
        lblHighScore.position = CGPoint(x: 0, y: -150)
        lblHighScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        lblHighScore.text = String(format: "High Score: %d", GameState.sharedInstance.highScore)
        addChild(lblHighScore)
        
        // "Try again" Label
        let lblTryAgain = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblTryAgain.fontSize = 30
        lblTryAgain.fontColor = SKColor.white
        lblTryAgain.position = CGPoint(x: 0, y: -200)
        lblTryAgain.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        lblTryAgain.text = "Tap To Try Again"
        addChild(lblTryAgain)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Enter label that touch the screen
        let transition:SKTransition = SKTransition.fade(withDuration: 1)
        var _:SKScene
        
        print("Touch Event!")
        if let scene = MenuScene(fileNamed:"MenuScene") {
            self.scene?.view?.presentScene(scene, transition: transition)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
}
