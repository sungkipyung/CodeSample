//
//  BubbleView.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 5. 3..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

protocol BubbleViewDelegate {
    func bubbleViewRotationButtonTouched(_ bubbleView: BubbleView, sender:AnyObject)
}

@IBDesignable
class BubbleView: UIView {
    @IBOutlet weak var contentView: UIView!
    
    weak var selectedCollageCell: CollageCell?
    
    var delegate: BubbleViewDelegate?
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init")
        load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("initWithCoder")
        load()
    }
    
    override func awakeFromNib() {
        print("awakeFromNib")
    }
    
    func load() {
        let bubbleView = Bundle(for: type(of: self)).loadNibNamed("BubbleView", owner: self, options: nil)?.first as! UIView
        self.addSubview(bubbleView)
    }
    
    @IBAction func touchRotationButton(_ sender: AnyObject) {
        self.delegate?.bubbleViewRotationButtonTouched(self, sender: sender)
    }
}
