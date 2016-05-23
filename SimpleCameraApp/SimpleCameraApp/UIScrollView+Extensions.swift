//
//  UIScrollView+Extensions.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 5. 23..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

extension UIScrollView {
    /**
     크기가 변경된 contentView(scrollView's subview)의 스크롤을 올바르게 할 수 있도록
     contentSize, contentInset을 재조정 한다.
     */
    func adjustContentSizeAndInset(contentViewOfScrollView: UIView) {
        let rotatedSize = contentViewOfScrollView.frame.size
        let originalSize = contentViewOfScrollView.bounds.size
        let dSize = 0.5 * (rotatedSize - originalSize)
        
        self.contentSize = contentViewOfScrollView.frame.size
        self.contentInset = UIEdgeInsets(top: dSize.height, left: dSize.width, bottom: -dSize.height, right: -dSize.width)
    }
}
