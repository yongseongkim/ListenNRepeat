//
//  UIScreen+Extension.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 4. 1..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation

extension UIScreen {
    class func mainScreenSize() -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    class func mainScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    class func mainScreenHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
}
