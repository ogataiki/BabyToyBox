import SpriteKit
import Darwin

class GameScene: SKScene, SKPhysicsContactDelegate  {

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
    var toys: [Toy] = [];
    var touchDic: [UITouch:Toy] = [:];
    
    var gameFrame = CGRectZero;

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
            toy = Toy(imageNamed:b.name!)
            toy.name = b.name;
            toy.life_time = b.life_time;
            toy.xScale = b.xScale;
            toy.yScale = b.yScale;
            toy.isMove = b.isMove;
        }
        else {
            toy = Toy(imageNamed:lottery.name)
            toy.name = lottery.name;
            toy.life_time = lottery.life;
        }
        
        toy.physicsBody = SKPhysicsBody(circleOfRadius: toy.size.width*0.5);
        toy.physicsBody?.dynamic = true;
        toy.physicsBody?.affectedByGravity = false;
        
        toy.physicsBody?.density = 0.1 + (CGFloat(arc4random() % 10) * 0.1);
        
        return toy;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            // 指に隠れないように指のちょっと上に出す。
            let toyPos = CGPointMake(location.x, location.y + 70);
            let toy = createToy();
            toy.position = toyPos;
            toy.stert_position = location;
            toy.mode = Toy.lotteryMode();

            self.addChild(toy);
            
            toys.append(toy);
            touchDic[touch] = toy;
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {

            let location = touch.locationInNode(self)
            let toyPos = CGPointMake(location.x, location.y + 70);

            let toy = touchDic[touch];
            
            switch toy!.mode {
            case .shot:
                
                toy!.isMove = true;

                toy!.position = toyPos;

            case .copy:
                
                if(0 == (Int(arc4random()) % 3)) {
                    let copy = createToy(toy);
                    copy.position = toyPos;
                    
                    self.addChild(copy);
                    toys.append(copy);
                }

            default: break;
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            let toy = touchDic[touch];
            
            switch toy!.mode {
            case .shot:
                
                toy!.isMove = false;
                
                let s = toy!.stert_position;
                let e = touch.locationInNode(self)
                
                let xdis = s.x-e.x;
                let ydis = s.y-e.y;
                
                toy!.physicsBody?.applyForce(CGVectorMake(xdis*3, ydis*3));
                
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
        
        let now = NSDate();

        for var i=toys.count-1; i>=0; i-- {
            
            let toy = toys[i];
            
            if toy.isMove == true {
                toy.xScale = toy.xScale+0.01;
                toy.yScale = toy.yScale+0.01;
            }
            else {

                let diff = toy.create_date.timeIntervalSinceDate(now);
                let hh = (diff / 3600);
                let mm = ((diff-hh) / 60);
                let ss = diff - (hh*3600+mm*60);
                if Int(ss) > 3 {
                    toy.removeFromParent();
                    toys.removeAtIndex(i);
                }
            }
        }
    }
}
