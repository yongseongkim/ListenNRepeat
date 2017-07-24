//
//  iTunesArtistCell.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 6. 12..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MediaPlayer

class iTunesArtistCell: UICollectionViewCell {
    
    class func height() -> CGFloat {
        return 50
    }
    
    //MARK: UI Components
    let nameLabel = UILabel().then { (label) in
        label.font = label.font.withSize(17)
        label.textColor = UIColor.black
    }
    let borderView = UIView().then { (view) in
        view.backgroundColor = UIColor.gray220
    }
    
    //MARK: Properties
    var collection: MPMediaItemCollection? {
        didSet {
            guard let item = collection?.representativeItem else {
                self.nameLabel.text = ""
                return
            }
            self.nameLabel.text = item.artist
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.centerY.equalTo(self)
        }
        self.addSubview(self.borderView)
        self.borderView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(44)
            make.bottom.equalTo(self)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(UIScreen.scaleWidth)
        }
    }

}
