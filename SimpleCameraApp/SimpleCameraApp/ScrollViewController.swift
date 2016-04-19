//
//  ScrollViewController.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 19..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage.init(named: "stretched-1920-1200-120548.jpg")!
        let imageView = UIImageView.init(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        scrollView.contentSize = image.size
        scrollView.addSubview(imageView)
        self.imageView = imageView
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
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
