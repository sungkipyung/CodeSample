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
     
     @param imageViewContainerScrollView : imageView container scrollView
     */
    func sizeThatFit(imageViewContainerScrollView:UIScrollView) {
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
}
