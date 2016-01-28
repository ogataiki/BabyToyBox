import SpriteKit

class Toy: SKSpriteNode
{
    enum MODE: Int {
        case shot = 0
        case copy
        
        case max
    }
    static func getMode(val: Int) -> MODE {
        switch val {
        case 0: return MODE.shot;
        case 1: return MODE.copy;
        default: return MODE.shot;
        }
    }
    
    struct MODE_PROBABILITY
    {
        var probability: Int;
        var mode: MODE;
    }
    static func lotteryMode() -> MODE {
        
        let mode_probability: [MODE_PROBABILITY] = [
            MODE_PROBABILITY(probability: 100, mode:MODE.shot),
            MODE_PROBABILITY(probability: 40, mode:MODE.copy),
        ];

        var total: Int = 0;
        var total_base: Int = 0;
        for m in mode_probability {
            total_base += m.probability;
        }
        let tmp: Int = 1 + Int(arc4random()) % total_base;
        for p in mode_probability {
            total += p.probability;
            if(tmp <= total) {
                return p.mode;
            }
        }
        return MODE.shot;
    }
    
    var life_time: NSTimeInterval = 0.0;
    var create_date: NSDate = NSDate();
    var isMove: Bool = false;
    var stert_position = CGPointZero;
    var mode = MODE.shot;

    var sound: String = "";

}