//
//  ImageScrollViewSampleVCViewController.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 5. 17..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

class ImageScrollViewSampleVCViewController: UIViewController {
    @IBOutlet weak var scrollview: UIScrollView!
    weak var imageView: UIImageView!
    
    @IBOutlet weak var imageViewRatioProgress: UIProgressView!
    @IBOutlet weak var imageViewRatioLabel: UILabel!
    @IBOutlet weak var imageViewRatioButton: RadioButton!
    
    @IBOutlet weak var scrollViewRatioProgress: UIProgressView!
    @IBOutlet weak var scrollViewRatioLabel: UILabel!
    @IBOutlet weak var scrollViewRatioButton: RadioButton!
    
    override func loadView() {
        super.loadView()
        
//        let image = UIImage(named: "stretched-1920-1200-120548.jpg")
        let image = UIImage(named: "1400_2149.jpg")
        let imageView = UIImageView(image: image)
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
//        imageView.frame.size = CGSizeMake(500, 500)
        imageView.sizeToFit()
        self.scrollview.addSubview(imageView)
        self.scrollview.contentSize = imageView.frame.size
        self.imageView = imageView

        
        self.imageViewRatioButton.onChangeLocation = { (view: RadioButton, originalPosition: CGPoint, incX: CGFloat, incY: CGFloat) -> (Void) in
            let buttonRadious = view.frame.size.width / 2
            
            let start = buttonRadious
            let end = view.superview!.frame.size.width - buttonRadious
            
            view.center.x = min(max(originalPosition.x + incX, start), end)
            
            let progress: Float = (Float)(view.center.x - start)/(Float)(end - start)
            self.imageViewRatioProgress.setProgress(progress, animated: false)
            
            let img_p = CGFloat(self.imageViewRatioProgress.progress)
            let img_ip = CGFloat(1 - self.imageViewRatioProgress.progress)
            self.imageViewRatioLabel.text = "\(img_p) : \(img_ip)"
            
            self.imageView.frame.size = CGSize(width: img_p / 0.5 * 500, height: img_ip / 0.5 * 500)
            
            self.applyContentSize()
        }
        
        self.scrollViewRatioButton.onChangeLocation = { (view: RadioButton, originalPosition: CGPoint, incX: CGFloat, incY: CGFloat) -> (Void) in
            let buttonRadious = view.frame.size.width / 2
            
            let start = buttonRadious
            let end = view.superview!.frame.size.width - buttonRadious
            
            view.center.x = min(max(originalPosition.x + incX, start), end)
            
            let progress: Float = (Float)(view.center.x - start)/(Float)(end - start)
            self.scrollViewRatioProgress.setProgress(progress, animated: false)
            
            let scr_p = CGFloat(self.scrollViewRatioProgress.progress)
            let scr_ip = CGFloat(1 - self.scrollViewRatioProgress.progress)
            self.scrollViewRatioLabel.text = "\(scr_p) : \(scr_ip)"
            // 1 : 1 = 50 : 50 = (100, 100)
            // 100 : 100
            // 0.1 : 0.9 = (0.1/ 0.5 * 100, 0.9 / 0.5 * 100)
            self.scrollview.frame.size = CGSize(width: scr_p / 0.5 * 100, height: scr_ip / 0.5 * 100)
            
            self.applyContentSize()
        }
    }
    
    private func applyContentSize() {
        
        let h = self.imageView.frame.size.height
        let w = self.imageView.frame.size.width
        
        let sh = self.scrollview.frame.size.height
        let sw = self.scrollview.frame.size.width
        
        
        var contentSize: CGSize!
        if (h < w) {
            // case 1
            if (sh > sw) {
                contentSize = CGSize(width: sh * w / h, height: sh)
            } else {
                contentSize = CGSize(width: sw, height: sw * h / w)
            }
        } else {
            if (sh > sw) {
                contentSize = CGSize(width: sh * w / h, height: sh)
            } else {
                contentSize = CGSize(width: sw, height: sw * h / w)
            }
        }
        
        print("contentSize : \(contentSize.width / contentSize.height)")
//        print("imageRatio : \(1920 / 1200.0)")
        print("imageRatio : \(1400 / 2149.0)")
        self.imageView.frame.size = contentSize
        self.scrollview.contentSize = contentSize
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

}
