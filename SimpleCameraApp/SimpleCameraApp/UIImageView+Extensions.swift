//
//  UIImageView+Extensions.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 5. 18..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

extension UIImageView {
    /**
     container scrollView의 크키에 맞게 imageView의 크기를 이미지 비율에 맞게 조정한다.
     그리고 container scrollView의 contentSize도 imageView의 크기와 동일하게 맞춘다.
     콜라주의 이미지가 변경(설정) 되었을 때 호출한다.
     @param imageViewContainerScrollView : imageView container scrollView
     */
    func sizeThatFit(_ imageViewContainerScrollView:UIScrollView) {
        let scrollView = imageViewContainerScrollView
        
        let h = self.frame.size.height
        let w = self.frame.size.width
        
        
        let sh = scrollView.frame.size.height
        let sw = scrollView.frame.size.width
        
        let imageSize = CGSize(width: w, height: h)
        let scrollSize = CGSize(width: sw, height: sh)
        
        
        var contentSize: CGSize!
        
        if (scrollSize.width > scrollSize.height && imageSize.width < imageSize.height) {
            contentSize = CGSize(width: sw, height: sw * h / w)
        } else if (sw < sh && w > h) {
            contentSize = CGSize(width: sh * w / h, height: sh)
        } else {
            contentSize = CGSize(width: sw, height: sw * h / w)
            if (contentSize.width < sw || contentSize.height < sh) {
                contentSize = CGSize(width: sh * w / h, height: sh)
            }
        }
        
        scrollView.contentSize = contentSize
        self.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: contentSize)
    }
    
    func applyTransform(_ transform: CGAffineTransform, andSizeToFitScrollView scrollView: UIScrollView) {
        self.transform = transform
        
        let rotatedSize = self.frame.size
        let originalSize = self.bounds.size
        let dSize = 0.5 * (rotatedSize - originalSize)
        
        scrollView.contentSize = self.frame.size
        scrollView.contentInset = UIEdgeInsets(top: dSize.height, left: dSize.width, bottom: -dSize.height, right: -dSize.width)
    }
    
    static func copyImageView(_ that: UIImageView) -> UIImageView {
        let imageView = UIImageView(image: that.image)
        imageView.transform = that.transform
        imageView.contentMode = that.contentMode
        imageView.frame = that.frame
        return imageView
    }
}

extension UIImageOrientation {
    func mirroredImageOrientation() -> UIImageOrientation {
        switch(self) {
        case .up:
            return UIImageOrientation.upMirrored
        case .down:
            return UIImageOrientation.downMirrored
        case .left:
            return UIImageOrientation.leftMirrored
        case .right:
            return UIImageOrientation.rightMirrored
        case .upMirrored:
            return UIImageOrientation.up
        case .downMirrored:
            return UIImageOrientation.down
        case .leftMirrored:
            return UIImageOrientation.left
        case .rightMirrored:
            return UIImageOrientation.right
        }
    }
    
    func verticalMirroredImageOrientation() -> UIImageOrientation {
        switch(self) {
        case .up:
            return UIImageOrientation.downMirrored
        case .down:
            return UIImageOrientation.upMirrored
        case .left:
            return UIImageOrientation.rightMirrored
        case .right:
            return UIImageOrientation.leftMirrored
        case .upMirrored:
            return UIImageOrientation.down
        case .downMirrored:
            return UIImageOrientation.up
        case .leftMirrored:
            return UIImageOrientation.right
        case .rightMirrored:
            return UIImageOrientation.left
        }
    }
}
