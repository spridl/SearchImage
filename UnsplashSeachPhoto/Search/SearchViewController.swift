//
//  SearchViewController.swift
//  UnsplashSeachPhoto
//
//  Created by T on 16.11.2021.
//  Copyright © 2021 Spridl. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UIViewController {
    
    var collectionView: UICollectionView! = nil
    let countPerPage = 30
    var searchText = ""
    var page = 1
    
    let fullVC = FullPhotoViewController()
    let networkDataFetcher = NetworkDataFetcher()
    
    
    var photos = [UnsplashPhoto]()
    private var selectedImages = [UIImage]()
    
    private var timer: Timer?
    let itemsPerRow: CGFloat = 2
    let sectionInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationBar()
        setupSearchBar()
    }
    
    func refresh() {
//        self.selectedImages.removeAll()
//        self.collectionView.selectItem(at: nil, animated: true, scrollPosition: [])
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y > scrollView.contentSize.height / 1.3, page <= 10 {
            page += 1
            self.networkDataFetcher.fetchImages(searchTerm: searchText, countPerPage: self.countPerPage, page: page) { [weak self] (searchResults) in
                guard let fetchedPhotos = searchResults else { return }
                self?.photos.append(contentsOf: fetchedPhotos.results)
                self?.collectionView.reloadData()
                print(self?.page ?? "none")
            }
        }
    }

    
// MARK: - Setup UI Elements
    
    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "Search"
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = #colorLiteral(red: 0.5019607843, green: 0.4980392157, blue: 0.4980392157, alpha: 1)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
    }
    private func setupSearchBar() {
        let seacrhController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = seacrhController
        seacrhController.hidesNavigationBarDuringPresentation = false
        seacrhController.obscuresBackgroundDuringPresentation = false
        seacrhController.searchBar.delegate = self
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.9725490196, blue: 0.9921568627, alpha: 1)
        view.addSubview(collectionView)
        
        collectionView.register(SearchViewCell.self, forCellWithReuseIdentifier: SearchViewCell.reuseId)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchViewCell.reuseId, for: indexPath) as! SearchViewCell
        let unsplashPhoto = photos[indexPath.item]
        cell.unsplashPhoto = unsplashPhoto
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
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
        fullVC.modalPresentationStyle = .fullScreen
           present(fullVC, animated: true) { [weak self] in
            self?.fullVC.addLibraryButton.isEnabled = true
            self?.fullVC.addLibraryButton.isHidden = false
            let unsplashPhoto = self?.photos[indexPath.item]
               self?.fullVC.unsplashPhoto = unsplashPhoto
            self?.fullVC.delegate = self
                
           }
       }
}
// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        page = 1
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            self.networkDataFetcher.fetchImages(searchTerm: searchText, countPerPage: self.countPerPage, page: self.page) { [weak self] (searchResults) in
                guard let fetchedPhotos = searchResults else { return }
                self?.photos = fetchedPhotos.results
                self?.collectionView.reloadData()
                self?.refresh()
                self?.searchText = searchText
            }
        })
    }
}
//MARK: Image moving back or forward
extension SearchViewController: ImageMovingDelegate {
    
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
