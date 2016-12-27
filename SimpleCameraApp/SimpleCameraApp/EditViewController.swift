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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text:String = textField.text!
        if (text.characters.count > 0) {
            self.pictureImageView.image = drawText(text, image: self.pictureImageView.image!, atPoint: self.pictureImageView.center)
            NSLog("write text : \(text)")
            textView.isHidden = true
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == "\n") {
            textView.resignFirstResponder()
            textView.isHidden = true;
            return false
        }
        
        return true
    }
    
    func drawText(_ text: String, image:UIImage, atPoint point:CGPoint) -> UIImage {
//        var textStyle:NSMutableAttributedString = NSMutableParagraphStyle.defaultParagraphStyle()
        let textStyle = NSMutableAttributedString.init(string: text)
        textStyle.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSMakeRange(0, textStyle.length))
        textStyle.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 20.0), range: NSMakeRange(0, textStyle.length))
        
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let rect: CGRect = CGRect(x: point.x, y: point.y, width: image.size.width, height: image.size.height)
        UIColor.white.set()
        
        textStyle.draw(in: rect.integral)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
