//
//  EditViewController.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 7..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var textView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
        // Do any additional setup after loading the view.
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
    
    func textFieldDidEndEditing(textField: UITextField) {
        let text:String = textField.text!
        if (text.characters.count > 0) {
            self.pictureImageView.image = drawText(text, image: self.pictureImageView.image!, atPoint: self.pictureImageView.center)
            NSLog("write text : \(text)")
            textView.hidden = true
        }
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (string == "\n") {
            textView.resignFirstResponder()
            textView.hidden = true;
            return false
        }
        
        return true
    }
    
    func drawText(text: String, image:UIImage, atPoint point:CGPoint) -> UIImage {
//        var textStyle:NSMutableAttributedString = NSMutableParagraphStyle.defaultParagraphStyle()
        let textStyle = NSMutableAttributedString.init(string: text)
        textStyle.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, textStyle.length))
        textStyle.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(20.0), range: NSMakeRange(0, textStyle.length))
        
        UIGraphicsBeginImageContext(image.size)
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        let rect: CGRect = CGRectMake(point.x, point.y, image.size.width, image.size.height)
        UIColor.whiteColor().set()
        
        textStyle.drawInRect(CGRectIntegral(rect))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
