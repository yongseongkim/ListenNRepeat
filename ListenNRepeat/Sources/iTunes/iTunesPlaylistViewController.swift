//
//  iTunesPlaylistViewController.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 7. 23..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MediaPlayer
import URLNavigator

class iTunesPlaylistViewController: UIViewController {

    //MARK: UI Components
    fileprivate let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
        ).then { (view) in
            view.backgroundColor = UIColor.white
            view.register(iTunesPlaylistItemCell.self)
            view.alwaysBounceVertical = true
    }
    
    //MARK: Properties
    fileprivate var collections = [MPMediaItemCollection]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Playlist"
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(self.collectionView)
        
        self.updateConstraints()
        self.updateContentInset()
        self.bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadPlaylist()
    }
    
    func updateConstraints() {
        self.collectionView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(self.view)
        }
    }
    
    public func updateContentInset() {
        if PlayerView.isVisible() {
            self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, PlayerView.height(), 0)
            self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, PlayerView.height(), 0)
        } else {
            self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
            self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0)
        }
    }
    
    func bind() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func enterForeground() {
        self.collectionView.reloadData()
    }
    
    func loadPlaylist() {
        let query = MPMediaQuery.playlists()
        if let collections = query.collections {
            self.collections = collections
        }
    }
}

extension iTunesPlaylistViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as iTunesPlaylistItemCell
        cell.collection = collections[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailViewController = iTunesPlaylistDetailViewController()
        detailViewController.collection = collections[indexPath.row]
        Navigator.push(detailViewController)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.mainWidth, height: iTunesSongCell.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
