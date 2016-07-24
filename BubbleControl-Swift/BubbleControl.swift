//
//  BubbleControl.swift
//  BubbleControl-Swift
//
//  Created by Cem Olcay on 11/12/14.
//  Copyright (c) 2014 Cem Olcay. All rights reserved.
//

import UIKit

let APPDELEGATE: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate



// MARK: - Animation Constants

private let BubbleControlMoveAnimationDuration: NSTimeInterval = 0.5
private let BubbleControlSpringDamping: CGFloat = 0.6
private let BubbleControlSpringVelocity: CGFloat = 0.6


// Sizes
var sn: CGFloat = 1
var numberOfTapsRequired: Int = 2
// MARK: - UIView Extension

extension UIView {
    
    
    // MARK: Frame Extensions
    
    var x: CGFloat {
        get {
            return self.frame.origin.x
        } set (value) {
            self.frame = CGRect (x: value, y: self.y, width: self.w, height: self.h)
        }
    }
    
    var y: CGFloat {
        get {
            return self.frame.origin.y
        } set (value) {
            self.frame = CGRect (x: self.x, y: value, width: self.w, height: self.h)
        }
    }
    
    var w: CGFloat {
        get {
            return self.frame.size.width
        } set (value) {
            self.frame = CGRect (x: self.x, y: self.y, width: value, height: self.h)
        }
    }
    
    var h: CGFloat {
        get {
            return self.frame.size.height
        } set (value) {
            self.frame = CGRect (x: self.x, y: self.y, width: self.w, height: value)
        }
    }
    
    
    var position: CGPoint {
        get {
            return self.frame.origin
        } set (value) {
            self.frame = CGRect (origin: value, size: self.frame.size)
        }
    }
    
    var size: CGSize {
        get {
            return self.frame.size
        } set (value) {
            self.frame = CGRect (origin: self.frame.origin, size: size)
        }
    }
    
    
    var left: CGFloat {
        get {
            return self.x
        } set (value) {
            self.x = value
        }
    }
    
    var right: CGFloat {
        get {
            return self.x + self.w
        } set (value) {
            self.x = value - self.w
        }
    }
    
    var top: CGFloat {
        get {
            return self.y + 50
        } set (value) {
            self.y = value
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.y - 50  + self.h
        } set (value) {
            self.y = value - self.h
        }
    }
    
    
    
    func leftWithOffset (offset: CGFloat) -> CGFloat {
        return self.left - offset
    }
    
    func rightWithOffset (offset: CGFloat) -> CGFloat {
        return self.right + offset
    }
    
    func topWithOffset (offset: CGFloat) -> CGFloat {
        return self.top - offset
    }
    
    func botttomWithOffset (offset: CGFloat) -> CGFloat {
        return self.bottom + offset
    }
    
    
    
    func spring (animations: ()->Void, completion:((Bool)->Void)?) {
        UIView.animateWithDuration(BubbleControlMoveAnimationDuration,
            delay: 0,
            usingSpringWithDamping: BubbleControlSpringDamping,
            initialSpringVelocity: BubbleControlSpringVelocity,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: animations,
            completion: completion)
    }
    
    
    func moveY (y: CGFloat) {
        var moveRect = self.frame
        moveRect.origin.y = y
        
        spring({ () -> Void in
            self.frame = moveRect
            }, completion: nil)
    }
    
    func moveX (x: CGFloat) {
        var moveRect = self.frame
        moveRect.origin.x = x
        
        spring({ () -> Void in
            self.frame = moveRect
            }, completion: nil)
    }
    
    func movePoint (x: CGFloat, y: CGFloat) {
        var moveRect = self.frame
        moveRect.origin.x = x
        moveRect.origin.y = y
        
        spring({ () -> Void in
            self.frame = moveRect
            }, completion: nil)
    }
    
    func movePoint (point: CGPoint) {
        var moveRect = self.frame
        moveRect.origin = point
        
        spring({ () -> Void in
            self.frame = moveRect
            }, completion: nil)
    }
    
    
    func setScale (s: CGFloat) {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -1000.0
        transform = CATransform3DScale(transform, s, s, s)
        
        self.layer.transform = transform
    }
    
    func alphaTo (to: CGFloat) {
        UIView.animateWithDuration(BubbleControlMoveAnimationDuration,
            animations: {
                self.alpha = to
        })
    }
    
    func bubble () {
        
       self.setScale(sn + 0.1 )
        spring({ () -> Void in
            self.setScale(sn)
            }, completion: nil)
    }
}




// MARK: - BubbleControl

class BubbleControl: UIControl {
    
    
    // MARK: Constants
    
    let popTriggerDuration: NSTimeInterval = 0
    let popAnimationDuration: NSTimeInterval = 0.4
    let popAnimationShakeDuration: NSTimeInterval = 0.15
    
    var popAnimationScale: CGFloat = 1.3
    let popAnimationScale2: CGFloat = 1.6
    let popAnimationScale3: CGFloat = 2
    
    let snapOffsetMin: CGFloat = 10.0
    let snapOffsetMax: CGFloat = 50.0
    
      
    // MARK: Optionals
    
    var contentView: UIView?
    
    var snapsInside: Bool = false
    var popsToNavBar: Bool = true
    var movesBottom: Bool = false
    
    
    
    // MARK: Actions
    
    var didToggle: ((Bool) -> ())?
    var didNavigationBarButtonPressed: (() -> ())?
    var didPop: (()->())?
    
    var setOpenAnimation: ((contentView: UIView, backgroundView: UIView?)->())?
    var setCloseAnimation: ((contentView: UIView, backgroundView: UIView?) -> ())?
    
    
    
    // MARK: Bubble State
    
    enum BubbleControlState {
        case Snap       // snapped to edge
        case Drag       // dragging around
        case Pop       // long pressed and popping
        case NavBar     // popped and went to nav bar
    }
    
    var bubbleState: BubbleControlState = .Snap {
        didSet {
            if bubbleState == .Snap {
            
            } else {
                snapOffset = snapOffsetMin
            }
        }
    }
    
    
    
    // MARK: Snap
    
    private var snapOffset: CGFloat!
    
    private var snapInTimer: NSTimer?
    private var snapInInterval: NSTimeInterval = 2
    
    
    
    // MARK: Toggle
    
    private var positionBeforeToggle: CGPoint?
    
    var toggle: Bool = false {
        didSet {
           
            if toggle {
              
                
            } else {
                
            }
        }
    }
    
    
    
    // MARK: Navigation Button
    
    private var barButtonItem: UIBarButtonItem?
    
    
    
    
    // MARK: Image
    
    var imageView: UIImageView?
    var image: UIImage? {
        didSet {
            imageView?.image = image
        }
    }
    
    
    
    // MARK: Init
    
    init (size: CGSize) {
        super.init(frame: CGRect (origin: CGPointZero, size: size))
        defaultInit()
        
    }
    
    init (image: UIImage) {
        let size = image.size
        super.init(frame: CGRect (origin: CGPointZero, size: size))
        self.image = image
        
        defaultInit()
    }
   

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func defaultInit () {
        
        // self
        snapOffset = snapOffsetMin
        layer.cornerRadius = w/2
        
        
        // image view
        
        imageView = UIImageView (frame: CGRectInset(frame, -70, -70))
        imageView?.layer.cornerRadius = 248
      //  self.imageView?.layer.borderWidth = 1.0
      //  self.imageView?.layer.borderColor = UIColor.blackColor().CGColor
      //  self.imageView?.layer.cornerRadius = 248
        imageView?.layer.contentsScale = UIScreen.mainScreen().scale
        addSubview(imageView!)
        
        
       
        
        
        
        
        // events
        addTarget(self, action: #selector(BubbleControl.touchDown), forControlEvents: UIControlEvents.TouchDown)
        addTarget(self, action: #selector(BubbleControl.touchUp), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(BubbleControl.doubleTap(_:)));
        doubleTap.numberOfTapsRequired = numberOfTapsRequired
        
                addGestureRecognizer(doubleTap)
        
        
        // place
        center.x = APPDELEGATE.window!.w - w/2 + snapOffset - 100
        center.y =  h/2 + 200
        
        
      
    }
    
    
    
    // MARK: Snap To Edge
    
    
    func lockInWindowBounds () {
        let window = APPDELEGATE.window!
        
        if top < 64 {
            print(frame)
            var rect = frame
            rect.origin.y = 64
            frame = rect
        }
        
        if left < 0 {
            print(frame)
            var rect = frame
            rect.origin.x = 0
            frame = rect
        }
        
        
        if bottom > window.h {
            print(frame)
            var rect = frame
            rect.origin.y = window.botttomWithOffset(-h)
            frame = rect
        }
        
        if right > window.w {
            print(frame)
            var rect = frame
            rect.origin.x = window.rightWithOffset(-w)
            frame = rect
        }
    }
    
    
    
    // MARK: Events
    
    func touchDown () {
        pop()
        setScale(sn)
        
        
    }
    
    
    func touchUp (){
       
        
        print("Один тач")
        
           bubble()
        
            }
    
   func touchDrag (sender: BubbleControl, event: UIEvent) {
    
    
        let touch = event.allTouches()!.first!
        let location = touch.locationInView(APPDELEGATE.window!)
        print(location)
        center = location
        
    }
    func delete()
    {
        let grow = CABasicAnimation (keyPath: "transform.scale")
        
            grow.fromValue = sn
            grow.toValue = 20
            grow.duration = popAnimationDuration
            sn=20
                let anims = CAAnimationGroup ()
        anims.animations = [ grow]
        anims.duration = popAnimationDuration
        anims.delegate = self
        anims.removedOnCompletion = true
        
        layer.addAnimation(anims, forKey: "delete")
        
       
    }
    
    // Даблтап с анимацией
    var i = 0
    
    func doubleTap (sender: UITapGestureRecognizer) {
        print("долгий")
        delete()
        setScale(sn)
        i = i+1
        if (i % 2 == 0)
        {
            alphaTo(1.0)
        } else
        {
            alpha = 0.2
        }
        
    }
    
    func navButtonPressed (sender: AnyObject) {
        didNavigationBarButtonPressed? ()
        print("Нажато на навигации")
    }
    
    
    
    // MARK: Animations
    
    override func animationDidStop(anim: CAAnimation,
        finished flag: Bool) {
            if flag {
                if anim == layer.animationForKey("pop") {
                    print("pop")
                    
                    
                                    }
            }
    }
    
    func degreesToRadians (angle: CGFloat) -> CGFloat {
        return (CGFloat (M_PI) * angle) / 180.0
    }
    
    
    
    // MARK: Pop
    
    func pop () {
        bubbleState = .Pop
       print("Увеличивается")
        
        
       let grow = CABasicAnimation (keyPath: "transform.scale")
        if(sn < 1.6){
            
        grow.fromValue = sn
        grow.toValue = sn + 0.3
        grow.duration = popAnimationDuration
            sn=sn + 0.3
       }else{
                grow.fromValue = sn
        grow.toValue = 1
        grow.duration = popAnimationDuration
        sn = 1
        }
        let anims = CAAnimationGroup ()
        anims.animations = [ grow]
        anims.duration = popAnimationDuration
        anims.delegate = self
        anims.removedOnCompletion = true
        
        layer.addAnimation(anims, forKey: "pop")
        
    }
    
    
    
    
    
        
    
    
    func popFromNavBar () {
        if let last = APPDELEGATE.window!.rootViewController as? UINavigationController {
            let vc = last.viewControllers[0]
            vc.navigationItem.rightBarButtonItem = nil
            
            bubbleState = .Snap
            self.barButtonItem = nil
            self.hidden = false
            
            let toPosition = self.frame.origin
            self.position = CGPoint(x: APPDELEGATE.window!.right, y: APPDELEGATE.window!.top)
            self.movePoint(toPosition)
            self.alphaTo(1)
        }
    }
    
    
    
    // MARK: Toggle
    
    /*  func openContentView () {
        if let v = contentView {
            let win = APPDELEGATE.window!
            win.addSubview(v)
            win.bringSubviewToFront(self)
            
            snapOffset = snapOffsetMin
           
            positionBeforeToggle = frame.origin
            
            if let anim = setOpenAnimation {
                anim (contentView: v, backgroundView: win.subviews[0] as? UIView)
            } else {
                v.bottom = win.bottom
            }
            
            if movesBottom {
                movePoint(CGPoint (x: win.center.x - w/2, y: win.bottom - h - snapOffset))
            } else {
                moveY(v.top - h - snapOffset)
            }
        }
    } */
    
            }






