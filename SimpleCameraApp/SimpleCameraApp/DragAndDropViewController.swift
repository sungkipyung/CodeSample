//
//  DragAndDropViewController.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 28..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

class DragAndDropViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    
    var views: [UIView]!
    
    private var selectedView: UIView!
    private var targetForSwapView: UIView?
    
    private var offset: CGPoint!
    private var originalFrame: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.views = [view1, view2, view3, view4]
        
        let top: CGFloat = 20
        let width = self.view.bounds.size.width / 2
        let height = self.view.bounds.size.height / 2
        view1.frame = CGRect(x: 0, y: top, width: width, height: height)
        view2.frame = CGRect(x: width, y: top, width: width, height: height)
        view3.frame = CGRect(x: 0, y: top + height, width: width, height: height - 20)
        view4.frame = CGRect(x: width, y: top + height, width: width, height: height - 20)
        // Do any additional setup after loading the view.
//        self.imageView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleTopMargin)
//        self.imageView.translatesAutoresizingMaskIntoConstraints = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func cellLongPressed(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .Began:
            // begin dragging
            offset = sender.locationInView(self.view)
            
            self.selectedView = sender.view!
            
            self.targetForSwapView = nil
            self.originalFrame = self.selectedView.frame
            UIView.animateWithDuration(0.2, animations: {
                self.selectedView.frame = CGRectInset(self.selectedView.frame, 10, 10)
                self.selectedView.layer.shadowOffset = CGSizeMake(-15, 20)
                self.selectedView.layer.shadowRadius = 5
                self.selectedView.layer.shadowOpacity = 0.5
                }, completion: { (complete) in
                    
            })
            
            // 그림자 효과 넣어줄 것!
            break
        case .Ended, .Cancelled, .Failed:
            //end dragging
            
            NSLog("state: \(sender.state.rawValue)")
            UIView.animateWithDuration(0.5, animations: {
                if let target = self.targetForSwapView {
                    let a = target.frame
                    let b = self.originalFrame
                    self.selectedView.frame = a
                    target.frame = b
                } else {
                    self.selectedView.frame = self.originalFrame
                }
                }, completion: { (complete) in
                    self.selectedView.layer.shadowOffset = CGSizeMake(0, 0)
                    self.selectedView.layer.shadowRadius = 0
                    self.selectedView.layer.shadowOpacity = 0
                    
                    self.views.forEach({ (view) in
                        view.alpha = 1
                    })
            })
            break
        case .Changed:
            let cursor = sender.locationInView(self.view)
            let dp = cursor - offset
            self.selectedView.frame.origin = originalFrame.origin + dp
//            self.selectedView.frame.origin.x = originalFrame.origin.x + dp.x
//            self.selectedView.frame.origin.y = originalFrame.origin.y + dp.y
//            
            
            self.targetForSwapView = nil
            self.views.forEach({ (view) in
//                let point = view.convertPoint(cursor, toView: view)
                if (view == self.selectedView) {
                    return
                }
                if CGRectContainsPoint(view.frame, cursor) {
                    view.alpha = 0.5
                    self.targetForSwapView = view
                } else {
                    view.alpha = 1
                }
            })
            break
        default:
            NSLog("cancel state: \(sender.state.rawValue)")
            // TODO: DragAndDrop 종료
        }
    }
}
