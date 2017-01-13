//
//  MenuScene.swift

import SpriteKit
// GameState is in GameplayKit
// import GameplayKit

class MenuScene: SKScene {
    
    //  Implement didBegin(_:) to handle the collisions
    func didBegin(_ contact: SKPhysicsContact) {
        
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Enter label that touch the screen
        let transition:SKTransition = SKTransition.fade(withDuration: 1)
        var _:SKScene
        
        print("Touch Event!")
        for touch in touches {
            let location = (touch as UITouch).location(in: self)
            if let theName = self.atPoint(location).name {
                // Easter egg
                if theName == "n" {
                    GameState.sharedInstance.easter = 1
                    print(GameState.sharedInstance.easter)
                    if let scene = GameScene(fileNamed:"GameScene") {
                        self.view?.presentScene(scene, transition: transition)
                    }
                } else if theName == "newGame" {
                    if let scene = GameScene(fileNamed:"GameScene") {
                        self.view?.presentScene(scene, transition: transition)
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
}
