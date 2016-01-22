import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate  {

    struct TOY_PROBABILITY
    {
        var probability: Int;
        var img_name: String;
    }
    var toy_probability: [TOY_PROBABILITY] = [
        TOY_PROBABILITY(probability: 100, img_name: "Toy1"),
        TOY_PROBABILITY(probability: 100, img_name: "Toy2"),
        TOY_PROBABILITY(probability: 100, img_name: "Toy3"),
        TOY_PROBABILITY(probability: 100, img_name: "Toy4"),
        TOY_PROBABILITY(probability: 100, img_name: "Toy5"),
        TOY_PROBABILITY(probability: 100, img_name: "Toy6"),
        TOY_PROBABILITY(probability: 100, img_name: "Toy7"),
        TOY_PROBABILITY(probability:  10, img_name: "Toy8"),
        TOY_PROBABILITY(probability: 100, img_name: "Toy9"),
        TOY_PROBABILITY(probability: 100, img_name: "Toy10"),
        TOY_PROBABILITY(probability: 100, img_name: "Toy11"),
        TOY_PROBABILITY(probability: 100, img_name: "Toy12"),
    ];
    var toy_probability_total: Int = 0;
    
    var gameFrame = CGRectZero;

    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor.clearColor();
        
        for p in toy_probability {
            toy_probability_total += p.probability;
        }
        
        self.physicsWorld.contactDelegate = self;
        
        gameFrame = self.frame;
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: gameFrame);
    }
    
    func toyLottery() -> String {
        var total: Int = 0;
        let tmp: Int = 1 + Int(arc4random()) % toy_probability_total;
        for p in toy_probability {
            total += p.probability;
            if(tmp <= total) {
                return p.img_name;
            }
        }
        return "Toy1"
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:toyLottery())
            sprite.position = location            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
