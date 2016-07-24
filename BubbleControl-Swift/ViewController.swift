//
//  ViewController.swift
///  Bubble-Swift
//
//  Created by Adam on 7/05/16.
//

import UIKit

class ViewController: UIViewController {
    
    var bubble: BubbleControl!
    var gravity: UIGravityBehavior!
    var animator: UIDynamicAnimator!
    var collision: UICollisionBehavior!
    var itemBehaviour: UIDynamicItemBehavior!
    var panGesture: UIPanGestureRecognizer?
    var tapGesture: UITapGestureRecognizer?
    var outsideGesture: UITapGestureRecognizer?
    var push: UIPushBehavior?
    let textLayer = CATextLayer()
    let fontName: CFStringRef = "HelveticaNeue-Light"
    let fontSize: CGFloat = 19.0
    var snap: UISnapBehavior!
    var ph = true // если просходит пуш//
    
    
    @IBAction func outsidetouch(sender: UITapGestureRecognizer) {
        
        push!.pushDirection = CGVectorMake(randomBetweenNumbers(-3.5, secondNum: 3.5), randomBetweenNumbers(-3.5, secondNum: 3.5))
        push!.active = true
        animator.addBehavior(push!)
        collision.addBoundaryWithIdentifier("barrier", fromPoint: CGPointMake(self.view.frame.origin.x, 62), toPoint: CGPointMake(self.view.frame.origin.x + self.view.frame.width, 62))
        animator.addBehavior(collision)
        itemBehaviour.addAngularVelocity(0.7, forItem: bubble)
        animator.addBehavior(itemBehaviour)
        ph = true
        
        if ( snap != nil){
        animator.removeBehavior(snap!)
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBubble()
        textLayer.frame = bubble.bounds
        textLayer.string = "\nComplete\na task!"
        textLayer.font = CTFontCreateWithName(fontName, fontSize, nil)
        textLayer.fontSize = fontSize
        textLayer.foregroundColor = UIColor.whiteColor().CGColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.mainScreen().scale
        bubble.layer.addSublayer(textLayer)
        /* включил границу объекта шар, что бы разобраться с этим багом */
       // self.bubble.layer.borderWidth = 1.0
       // self.bubble.layer.borderColor = UIColor.blueColor().CGColor
       // self.bubble.layer.cornerRadius = 1.0
       // bubble.layer.cornerRadius = 1.0
        view.addSubview(bubble)
        
        
    
        animator = UIDynamicAnimator(referenceView: view)
        gravity = UIGravityBehavior(items: [bubble])
        gravity.gravityDirection = CGVector(dx: 0.0, dy: 0.0)
        animator.addBehavior(gravity)
        
        
        collision = UICollisionBehavior(items: [bubble])
        collision.translatesReferenceBoundsIntoBoundary = true
         collision.addBoundaryWithIdentifier("barrier", fromPoint: CGPointMake(self.view.frame.origin.x, 62), toPoint: CGPointMake(self.view.frame.origin.x + self.view.frame.width, 62))
        animator.addBehavior(collision)
        
        itemBehaviour = UIDynamicItemBehavior(items: [bubble])
        itemBehaviour.elasticity = 1.0
        itemBehaviour.resistance = 0.0
        itemBehaviour.addAngularVelocity(0.7, forItem: bubble)
        animator.addBehavior(itemBehaviour)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.onTap(_:)))
        bubble!.addGestureRecognizer(tapGesture!)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.panning(_:)))
        bubble!.addGestureRecognizer(panGesture!)
        
        
        push = UIPushBehavior(items: [bubble], mode: .Instantaneous)
        push!.magnitude = 0.4
        push!.pushDirection = CGVectorMake(randomBetweenNumbers(-3.5, secondNum: 3.5), randomBetweenNumbers(-3.5, secondNum: 3.5))
        push!.active = true
        animator.addBehavior(push!)
    
        
        
    }
    
    
    // MARK: Bubble
        func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
            return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func setupBubble () {
        let win = APPDELEGATE.window!
        
        bubble = BubbleControl (size: CGSizeMake(90, 90))
        bubble.image = UIImage (named: "basket.png")
        bubble.center.x = win.w/2
        bubble.center.y = win.h/2
        
      //  bubble.layer.contents = UIImage(named: "basket.png")?.CGImage
      //  bubble.layer.contentsGravity = kCAGravityCenter
    
      //  bubble.clipsToBounds = true
        
        bubble.didNavigationBarButtonPressed = {
            print("pressed in nav bar")
            self.bubble!.popFromNavBar()
        }
        
        bubble.setOpenAnimation = { content, background in
            self.bubble.contentView!.bottom = win.bottom
            if (self.bubble.center.x > win.center.x) {
                self.bubble.contentView!.left = win.right
                self.bubble.contentView!.spring({ () -> Void in
                    self.bubble.contentView!.right = win.right
                }, completion: nil)
            } else {
                self.bubble.contentView!.right = win.left
                self.bubble.contentView!.spring({ () -> Void in
                    self.bubble.contentView!.left = win.left
                }, completion: nil)
            }
        }
        
       
        
        
        /*       let min: CGFloat = 50
        let max: CGFloat = win.h-20
        let randH = min + CGFloat(random()%Int(max-min))
        
        let v = UIView (frame: CGRect (x: 20, y: 0, width: win.w, height: max))
        v.backgroundColor = UIColor.greenColor()
        
        let label = UILabel (frame: CGRect (x: 10, y: 10, width: v.w, height: 20))
        label.text = "приветик"
        v.addSubview(label)
        
        bubble.contentView = v */
        
        
    }
        
    func panning(pan: UIPanGestureRecognizer) {
        
        let location = pan.locationInView(view)
      //  let touchLocation = pan.locationInView(bubble);
        
        if pan.state == UIGestureRecognizerState.Began {
            // Do some initial setup here
            
            //Removes all the behaviors attached to the animators for now
            animator!.removeAllBehaviors()
            
            // Will set the box's center to the location value stored above
            bubble!.center = location;
            
        }else if pan.state == UIGestureRecognizerState.Changed {
            bubble!.center = location;
        }else if pan.state == UIGestureRecognizerState.Ended {
            // Handles what should happen when the box is released...
            animator!.addBehavior(gravity)
            animator!.addBehavior(collision)
            
        }
        
    }
    
    func onTap(tap: UITapGestureRecognizer) {
        let tapPoint = tap.locationInView(view)
        animator!.removeAllBehaviors()
        if (ph == true){
            snap = UISnapBehavior(item: bubble, snapToPoint: tapPoint)
            animator.addBehavior(snap)
            ph = false
        } else{
            bubble.setScale(sn)
        }
        
    }
    
    
  
    
    // MARK: Animation
    
       var animateIcon: Bool = false {
        didSet {
            if animateIcon {
                bubble.didToggle = { on in
                    if (self.bubble.imageView?.layer.sublayers?[0] as? CAShapeLayer) != nil {
                        
                    }
                    else {
                        self.bubble.imageView?.image = nil
                        
                        let shapeLayer = CAShapeLayer ()
                        shapeLayer.lineWidth = 0.25
                        shapeLayer.strokeColor = UIColor.blackColor().CGColor
                        shapeLayer.fillMode = kCAFillModeForwards
                        
                        self.bubble.imageView?.layer.addSublayer(shapeLayer)
                     
                    }
                }
            } else {
                bubble.didToggle = nil
                bubble.imageView?.layer.sublayers = nil
                bubble.imageView?.image = bubble.image!
            }
        }
    }
    
    
      }



