//
//  CategoriesViewController.swift
//  UnsplashSeachPhoto
//
//  Created by T on 16.11.2021.
//  Copyright © 2021 Spridl. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController {
    
    var collectionView: UICollectionView! = nil
    let countPerPage = 10
    let page = 1
    let sectionsArray = ["cat","black","white","blue"]
    var sectionResults = [String]()
    let userDefaults = UserDefaults.standard
    
    let seeMoreVC = SeeMoreVC()
    let fullVC = FullPhotoViewController()
    let networkDataFetcher = NetworkDataFetcher()
    var photos = [[UnsplashPhoto]]()
    var photosCount = [UnsplashPhoto]()
    var updateSelected = false
    
//    let selectButton = UIButton()
//    let cancelButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchImage()
        setupCollectionView()
        setupNavigationBar()
    }
    
    private func fetchImage() {
        for section in sectionsArray {
            self.networkDataFetcher.fetchImages(searchTerm: section, countPerPage: countPerPage, page: page) { [weak self] (searchResults) in
            self?.sectionResults.append(section)
            guard let fetchedPhotos = searchResults else { return }
            self?.photos.append(fetchedPhotos.results)
            self?.photosCount = fetchedPhotos.results
            self?.collectionView.reloadData()
            }
        }
    }
    
// MARK: - Setup UI Elements
    
    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "Categories"
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = #colorLiteral(red: 0.5019607843, green: 0.4980392157, blue: 0.4980392157, alpha: 1)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)

    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.9725490196, blue: 0.9921568627, alpha: 1)
        view.addSubview(collectionView)
        
        collectionView.register(CategoriesViewCell.self, forCellWithReuseIdentifier: CategoriesViewCell.reuseId)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoriesSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoriesSectionHeader.reuseId)
        collectionView.allowsMultipleSelection = true
    }
    
    private var headerItem: NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(40)
        )
        
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .topLeading
        )
    }
    
    @objc private func seeMoreButtonPressed(sender: UIButton!) {
//        let navCon = UINavigationController(rootViewController: seeMoreVC)
//        navCon.modalPresentationStyle = .fullScreen
//        present(navCon, animated: true) { [weak self] in
//            self?.seeMoreVC.sectionName = self?.sectionResults[sender.tag]
//        }
        self.seeMoreVC.sectionName = self.sectionResults[sender.tag]
        self.seeMoreVC.page = 1
//        navigationController?.pushViewController(seeMoreVC, animated: true)
        navigationController?.show(seeMoreVC, sender: nil)
    }
    
// MARK: - Setup Layout
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalWidth(0.7))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 2)
        let spacing = CGFloat(20)
        group.interItemSpacing = .fixed(spacing)
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [headerItem]
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: spacing, bottom: spacing, trailing: spacing)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension CategoriesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosCount.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoriesViewCell.reuseId, for: indexPath) as! CategoriesViewCell
        let unsplashPhotoSection = photos[indexPath.section]
        let unsplashPhoto = unsplashPhotoSection[indexPath.item]
        cell.unsplashPhoto = unsplashPhoto
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoriesSectionHeader.reuseId, for: indexPath) as! CategoriesSectionHeader
        header.title.text = sectionResults[indexPath.section]
        header.seeMoreButton.addTarget(self, action: #selector(seeMoreButtonPressed), for: .touchUpInside)
        header.seeMoreButton.tag = indexPath.section
        return header
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        fullVC.modalPresentationStyle = .fullScreen
        present(fullVC, animated: true) { [weak self] in
            self?.fullVC.addLibraryButton.isEnabled = true
            self?.fullVC.addLibraryButton.isHidden = false
            let unsplashPhotoSection = self?.photos[indexPath.section]
            let unsplashPhoto = unsplashPhotoSection?[indexPath.item]
            self?.fullVC.unsplashPhoto = unsplashPhoto
        }
    }
}


// MARK: - SwiftUI
//import SwiftUI
//struct CompostitionalProvider: PreviewProvider {
//    static var previews: some View {
//        ContainterView().edgesIgnoringSafeArea(.all)
//    }
//
//    struct ContainterView: UIViewControllerRepresentable {
//
//        let tabBar = MainTabBarController()
//        func makeUIViewController(context: UIViewControllerRepresentableContext<CompostitionalProvider.ContainterView>) -> MainTabBarController {
//            return tabBar
//        }
//
//        func updateUIViewController(_ uiViewController: CompostitionalProvider.ContainterView.UIViewControllerType, context: UIViewControllerRepresentableContext<CompostitionalProvider.ContainterView>) {
//
//        }
//    }
//}
