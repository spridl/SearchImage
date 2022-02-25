//
//  SeeMoreVC.swift
//  UnsplashSeachPhoto
//
//  Created by T on 27.11.2021.
//  Copyright © 2021 Spridl. All rights reserved.
//

import Foundation
import UIKit

class SeeMoreVC: UIViewController {
    
    var collectionView: UICollectionView! = nil
    let countPerPage = 30
    var page = 1
    
    
    var sectionName: String! {
        didSet {
            fetchImage()
            setupNavigationBar()
        }
    }
    
    var photos = [UnsplashPhoto]()

    let itemsPerRow: CGFloat = 2
    let sectionInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationBar()
    }
    
    private func fetchImage() {
        let networkDataFetcher = NetworkDataFetcher()
        networkDataFetcher.fetchImages(searchTerm: sectionName, countPerPage: self.countPerPage, page: page) { [weak self] (searchResults) in
                guard let fetchedPhotos = searchResults else { return }
                self?.photos = fetchedPhotos.results
                self?.collectionView.reloadData()
            }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let networkDataFetcher = NetworkDataFetcher()
        if scrollView.contentOffset.y > scrollView.contentSize.height / 1.3, page <= 10 {
            page += 1
            networkDataFetcher.fetchImages(searchTerm: sectionName, countPerPage: self.countPerPage, page: page) { [weak self] (searchResults) in
                guard let fetchedPhotos = searchResults else { return }
                self?.photos.append(contentsOf: fetchedPhotos.results)
                self?.collectionView.reloadData()
                print(self?.page ?? "none")
            }
        }
    }
    
    deinit {
        print("вышел")
    }

    
// MARK: - Setup UI Elements
    
    private func setupNavigationBar() {
        navigationItem.title = sectionName
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.9725490196, blue: 0.9921568627, alpha: 1)
        view.addSubview(collectionView)
        collectionView.register(SeeMoreCell.self, forCellWithReuseIdentifier: SeeMoreCell.reuseId)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension SeeMoreVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeeMoreCell.reuseId, for: indexPath) as! SeeMoreCell
        let unsplashPhoto = photos[indexPath.item]
        cell.unsplashPhoto = unsplashPhoto
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SeeMoreVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingWidth = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingWidth
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem + 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fullVC = FullPhotoViewController()
        fullVC.modalPresentationStyle = .fullScreen
           present(fullVC, animated: true) { [weak self] in
            fullVC.addLibraryButton.isEnabled = true
            fullVC.addLibraryButton.isHidden = false
            let unsplashPhoto = self?.photos[indexPath.item]
               fullVC.unsplashPhoto = unsplashPhoto
            fullVC.delegate = self
                
           }
       }
}


//MARK: Image moving back or forward
extension SeeMoreVC: ImageMovingDelegate {

    private func getImage(isForwardImage: Bool) -> String? {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return nil }
        collectionView.deselectItem(at: indexPath, animated: true)
        var nextIndexPath: IndexPath!
        if isForwardImage {
            nextIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
            if nextIndexPath.item == photos.count {
                nextIndexPath.item = 0
            }
        } else {
            nextIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            if nextIndexPath.item == -1 {
                nextIndexPath.item = photos.count - 1
            }
        }
        collectionView.selectItem(at: nextIndexPath, animated: true, scrollPosition: .init())
        let nextPhoto = photos[nextIndexPath.item].urls["regular"]
        return nextPhoto

    }

    func moveBackForPreviousImage() -> String? {
        return getImage(isForwardImage: false)
    }

    func moveForwardForNextImage() -> String? {
        return getImage(isForwardImage: true)
    }


}
