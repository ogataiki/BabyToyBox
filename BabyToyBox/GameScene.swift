import SpriteKit
import Darwin

class GameScene: SKScene, SKPhysicsContactDelegate  {

    // カテゴリを用意しておく。
    let wall_Category: UInt32 = 0x1 << 0
    let toy_Category: UInt32 = 0x1 << 1
    
    struct TOY_PROBABILITY
    {
        var probability: Int;
        var life_time: NSTimeInterval;
        var img_name: String;
    }
    var toy_probability: [TOY_PROBABILITY] = [
        TOY_PROBABILITY(probability: 100, life_time: 3.0, img_name: "Toy1"),
        TOY_PROBABILITY(probability: 100, life_time: 3.0, img_name: "Toy2"),
        TOY_PROBABILITY(probability: 100, life_time: 3.0, img_name: "Toy3"),
        TOY_PROBABILITY(probability: 100, life_time: 3.0, img_name: "Toy4"),
        TOY_PROBABILITY(probability: 100, life_time: 3.0, img_name: "Toy5"),
        TOY_PROBABILITY(probability: 100, life_time: 3.0, img_name: "Toy6"),
        TOY_PROBABILITY(probability: 100, life_time: 3.0, img_name: "Toy7"),
        TOY_PROBABILITY(probability:  30, life_time: 3.0, img_name: "Toy8"),
        TOY_PROBABILITY(probability: 100, life_time: 3.0, img_name: "Toy9"),
        TOY_PROBABILITY(probability: 100, life_time: 3.0, img_name: "Toy10"),
        TOY_PROBABILITY(probability: 100, life_time: 3.0, img_name: "Toy11"),
        TOY_PROBABILITY(probability: 100, life_time: 3.0, img_name: "Toy12"),
    ];
    var toy_probability_total: Int = 0;
    var toyCounter: Int = 0;
    var toys: [Int:Toy] = [:];
    var touchDic: [UITouch:Toy] = [:];
    
    var toy_sounds: [String] = [
        "dog",
        "cat",
        "chicken",
        "crow",
        "goat",
        "sheep",
        "uguis",
        "sealion"
    ]
    
    var gameFrame = CGRectZero;
    
    var updateFrame: UInt64 = 0;

    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor.clearColor();
        
        for p in toy_probability {
            toy_probability_total += p.probability;
        }
        
        self.physicsWorld.contactDelegate = self;
        
        let screenSize = UIScreen.mainScreen().bounds;
        let widthRatio = self.size.width / screenSize.size.width;
        let heightRatio = self.size.height / screenSize.size.height;
        print("widthRatio:\(widthRatio), heightRatio:\(heightRatio)");
        
        if heightRatio < widthRatio {
            // 縦がフィット
            gameFrame = CGRectMake(
                (self.size.width - (screenSize.width*heightRatio)) * 0.5,
                0,
                screenSize.width * heightRatio,
                self.size.height);
        }
        else {
            // 横がフィット
            gameFrame = CGRectMake(
                0,
                (self.size.height - (screenSize.height*widthRatio)) * 0.5,
                self.size.width,
                screenSize.height * widthRatio);
        }
        
        print("UIScreen.mainScreen().bounds:\(UIScreen.mainScreen().bounds)");
        print("bounds.size:\(view.bounds.size)");
        print("gameFrame:\(gameFrame)");
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: gameFrame);
        self.physicsBody?.categoryBitMask = wall_Category;
        self.physicsBody?.contactTestBitMask = toy_Category;
        
    }
    
    func toyLottery() -> (name: String, life: NSTimeInterval) {
        var total: Int = 0;
        let tmp: Int = 1 + Int(arc4random()) % toy_probability_total;
        for p in toy_probability {
            total += p.probability;
            if(tmp <= total) {
                return (p.img_name, p.life_time);
            }
        }
        return ("Toy1", 1.0);
    }
    
    func createToy(base: Toy? = nil) -> Toy {
        
        let lottery = toyLottery();
        
        let toy: Toy;
        if let b = base {
            toy = Toy(imageNamed:b.image_name)
            toy.image_name = b.image_name;
            toy.life_time = b.life_time;
            toy.xScale = b.xScale;
            toy.yScale = b.yScale;
            toy.isMove = b.isMove;
            toy.sound = b.sound;
        }
        else {
            toy = Toy(imageNamed:lottery.name)
            toy.image_name = lottery.name;
            toy.life_time = lottery.life;
            toy.sound = toy_sounds[Int(arc4random()) % toy_sounds.count];
        }
        toy.name = "toy";
        
        toy.physicsBody = SKPhysicsBody(circleOfRadius: toy.size.width*0.5);
        toy.physicsBody?.dynamic = true;
        toy.physicsBody?.affectedByGravity = false;
        
        toy.physicsBody?.density = 0.1 + (CGFloat(arc4random() % 10) * 0.1);
        
        toy.physicsBody?.categoryBitMask = toy_Category;
        toy.physicsBody?.contactTestBitMask = wall_Category | toy_Category;

        return toy;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let node = self.nodeAtPoint(location);
            if node.name == "toy" {
                let toy = node as! Toy;
                toyExplosion(toy.index);
                toy.removeFromParent();
                toys.removeValueForKey(toy.index);
                return;
            }
            
            // 指に隠れないように指のちょっと上に出す。
            let toyPos = CGPointMake(location.x, location.y + 70);
            let toy = createToy();
            toy.position = toyPos;
            toy.stert_position = location;
            toy.mode = Toy.lotteryMode();

            self.addChild(toy);
            
            toy.index = toyCounter;
            toys[toy.index] = toy;
            toyCounter++;
            touchDic[touch] = toy;
            
            let seAction = SKAction.playSoundFileNamed(toy.sound, waitForCompletion: false);
            self.runAction(seAction);
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {

            let location = touch.locationInNode(self)
            let toyPos = CGPointMake(location.x, location.y + 70);

            let toy = touchDic[touch];
            
            if toy == nil {
                touchDic.removeValueForKey(touch);
                return;
            }
            
            switch toy!.mode {
            case .shot:
                
                toy!.isMove = true;

                toy!.position = toyPos;

            case .copy:
                
                if 0 == updateFrame % 3 {
                    let copy = createToy(toy);
                    copy.position = toyPos;
                    
                    self.addChild(copy);
                    
                    copy.index = toyCounter;
                    toys[copy.index] = copy;
                    toyCounter++;
                    
                    let seAction = SKAction.playSoundFileNamed(copy.sound, waitForCompletion: false);
                    self.runAction(seAction);
                }

            default: break;
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            let toy = touchDic[touch];
            
            if toy == nil {
                touchDic.removeValueForKey(touch);
                return;
            }

            switch toy!.mode {
            case .shot:
                
                toy!.isMove = false;
                
                let s = toy!.stert_position;
                let e = touch.locationInNode(self)
                
                let xdis = s.x-e.x;
                let ydis = s.y-e.y;
                
                let amplify = 3.0 + CGFloat(arc4random() % 5);
                toy!.physicsBody?.applyForce(CGVectorMake(xdis*amplify, ydis*amplify));
                
                toy!.create_date = NSDate();
                
            default: break;
            }
            
            touchDic.removeValueForKey(touch);
            
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touchDic.removeAll();
        touchDic = [:];
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        updateFrame++;
        
        let now = NSDate();
        
        let keys = toys.keys;
        for key in keys {
            
            let toy = toys[key]!;
            
            if toy.isMove == true {
                toy.xScale = toy.xScale+0.01;
                toy.yScale = toy.yScale+0.01;
                
                if toy.xScale > 6.0 && toy.yScale > 6.0 {
                    toyExplosion(key);
                    
                    toy.removeFromParent();
                    toys.removeValueForKey(key);
                }
            }
            else {
                
                let diff = toy.create_date.timeIntervalSinceDate(now);
                let hh = (diff / 3600);
                let mm = ((diff-hh) / 60);
                let ss = diff - (hh*3600+mm*60);
                if Int(ss) > 3 {
                    toy.removeFromParent();
                    toys.removeValueForKey(key);
                }
            }
        }
    }
    
    func toyExplosion(index: Int) {
        
        let toy = toys[index]!;

        let sparkPath = NSBundle.mainBundle().pathForResource("ToyExplosion", ofType: "sks");
        let spark: SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(sparkPath!) as! SKEmitterNode;
        spark.position = toy.position;
        spark.xScale = 2.0;
        spark.yScale = spark.xScale;
        self.addChild(spark);
        
        let fadeout = SKAction.fadeAlphaTo(0, duration: 0.6);
        let remove = SKAction.removeFromParent();
        let sequence = SKAction.sequence([fadeout, remove]);
        spark.runAction(sequence);
        
        let seAction = SKAction.playSoundFileNamed("explosion", waitForCompletion: false);
        self.runAction(seAction);
    }
    
    // 衝突したとき。
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody, secondBody: SKPhysicsBody
        
        // firstを赤、secondを緑とする。
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // toy同士の接触
        if firstBody.categoryBitMask & toy_Category != 0 && secondBody.categoryBitMask & toy_Category != 0
        {
        }
        // 壁とtoyの接触
        else if (firstBody.categoryBitMask & wall_Category != 0 && secondBody.categoryBitMask & toy_Category != 0) ||
                (firstBody.categoryBitMask & toy_Category != 0 && secondBody.categoryBitMask & wall_Category != 0)
        {
        }
    }
}
