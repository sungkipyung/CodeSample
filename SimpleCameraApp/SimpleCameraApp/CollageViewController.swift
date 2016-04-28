//
//  CollageViewController.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 14..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

class CollageViewController: UIViewController {

    @IBOutlet weak var collageView: CollageView!
    
    @IBOutlet weak var intervalControlButton: RadioButton!
    @IBOutlet weak var intervalProgressView: UIProgressView!
    
    @IBOutlet weak var roundControlButton: RadioButton!
    @IBOutlet weak var roundProgressView: UIProgressView!
    
    @IBOutlet weak var layoutControlView: UIView!
    private static let MAX_BORDER_WIDTH: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIGraphicsBeginImageContext(self.collageView.frame.size);
        UIImage(named: "pattern-repeat-4.png")?.drawInRect(self.collageView.bounds)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.collageView.backgroundColor = UIColor(patternImage: image)
        // Do any additional setup after loading the view.
        
        intervalControlButton.onChangeLocation = { (view: RadioButton, originalPosition: CGPoint, incX: CGFloat, incY: CGFloat) -> (Void) in
            let buttonRadious = view.frame.size.width / 2
            
            let start = buttonRadious
            let end = view.superview!.frame.size.width - buttonRadious
            
            view.center.x = min(max(originalPosition.x + incX, start), end)
            
            let progress: Float = (Float)(view.center.x - start)/(Float)(end - start)
            self.collageView.layout?.border = CGFloat(progress) * CollageViewController.MAX_BORDER_WIDTH
            self.intervalProgressView.setProgress(progress, animated: false)
            self.collageView.redraw()
        }
        
        roundControlButton.onChangeLocation = { (view: RadioButton, originalPosition: CGPoint, incX: CGFloat, incY: CGFloat) -> (Void) in
            let buttonRadious = view.frame.size.width / 2
            
            let start = buttonRadious
            let end = view.superview!.frame.size.width - buttonRadious
            
            view.center.x = min(max(originalPosition.x + incX, start), end)
            let progress: Float = (Float)(view.center.x - start)/(Float)(end - start)
            self.collageView.layout?.curvature = CGFloat(progress)
            self.roundProgressView.setProgress(progress, animated: false)
            self.collageView.redraw()
        }
        
        let layout = LayoutFactory.sharedInstance.getLayout(0, limit: 1)![0]
        let width = UIScreen.mainScreen().bounds.size.width - 32
        collageView.frame.size.width = width
        collageView.frame.size.height = width
        collageView.layout = layout
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTouchFrameControlButton(sender: AnyObject) {
        layoutControlView.hidden = !layoutControlView.hidden
        if (layoutControlView.hidden) {
            collageView.drawGrapButtons = false
            self.collageView.swappable = true
        } else {
            collageView.drawGrapButtons = true
            collageView.cellGrapButtons.forEach({ (button) in
                collageView.bringSubviewToFront(button)
            })
            
            self.collageView.swappable = false
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onTouchBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
