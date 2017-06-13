//
//  iTunesAlbumListViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 6. 12..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation
import MediaPlayer
import URLNavigator

class iTunesAlbumListViewController: UIViewController {
    fileprivate let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
        ).then { (view) in
            view.backgroundColor = UIColor.white
            view.register(iTunesAlbumCell.self)
            view.contentInset = UIEdgeInsetsMake(64, 0, 49 ,0)
    }
    
    //MARK: Properties
    public var collection: MPMediaItemCollection? {
        didSet {
            self.loadArtistsAlbums()
        }
    }
    
    fileprivate var collections = [MPMediaItemCollection]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        AppDelegate.currentAppDelegate()?.notificationCenter.addObserver(self, selector: #selector(enterForeground), name: .onEnterForeground, object: nil)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    deinit {
        AppDelegate.currentAppDelegate()?.notificationCenter.addObserver(self, selector: #selector(enterForeground), name: .onEnterForeground, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Albums"
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(self.collectionView)
        
        self.updateConstraints()
        self.bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadArtistsAlbums()
    }
    
    func updateConstraints() {
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
    }
    
    func bind() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func closeViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func enterForeground() {
        self.loadArtistsAlbums()
    }
    
    func loadArtistsAlbums() {
        let query = MPMediaQuery.albums()
        if let artistName = self.collection?.representativeItem?.artist {
            query.addFilterPredicate(MPMediaPropertyPredicate(value: artistName, forProperty: MPMediaItemPropertyArtist, comparisonType: .equalTo))
        }
        if let collections = query.collections {
            self.collections = collections
        }
    }
}

extension iTunesAlbumListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as iTunesAlbumCell
        cell.collection = collections[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.mainWidth, height: iTunesAlbumCell.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailViewController = iTunesAlbumDetailViewController()
        detailViewController.collection = self.collections[indexPath.row]
        Navigator.push(detailViewController)
    }
}
