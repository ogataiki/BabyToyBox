import UIKit
import SpriteKit

class GameViewController: UIViewController {

    @IBOutlet weak var BackImageView: UIImageView!
    @IBOutlet weak var GameView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed:"GameScene") {
            
            BackImageView.image = UIImage(named: "Bg\(1 + arc4random() % 9)");

            // Configure the view.
            let skView = GameView as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            skView.backgroundColor = UIColor.clearColor();
            skView.allowsTransparency = true;
            
            skView.multipleTouchEnabled = true;

            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            scene.size = skView.frame.size;
            
            skView.presentScene(scene)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
