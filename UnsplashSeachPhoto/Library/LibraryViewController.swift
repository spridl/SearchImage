//
//  LibraryViewController.swift
//  UnsplashSeachPhoto
//
//  Created by T on 16.11.2021.
//  Copyright © 2021 Spridl. All rights reserved.
//

import Foundation
import UIKit

class LibraryViewController: UIViewController {
    
    let fullVC = FullPhotoViewController()
    var collectionView: UICollectionView!
    let itemsPerRow: CGFloat = 2
    let sectionInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    let userDefaults = UserDefaults.standard
    var listOfPhotos = [String]()
    let longTapGesture = UILongPressGestureRecognizer()
    
    override func viewDidLoad() {
           super.viewDidLoad()
        unarchivedData()
           setupCollectionView()
           setupNavigationBar()
        addGesture()
        view.backgroundColor = .white
       }
    
    @objc private func longTapGesturePressed(sender: UITapGestureRecognizer!) {
             guard longTapGesture.state != .ended else { return }
             let point = longTapGesture.location(in: collectionView)
        deleteAlert(point: point)
        }
    
    private func deleteAlert(point: CGPoint) {
        let deleteAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.deleteImageAction(point: point) { result in
                if result {
                    self.unarchivedData()
                    self.collectionView.reloadData()
                }
            }
        }
        deleteAlert.addAction(deleteAction)
        present(deleteAlert, animated: true)
    }
    
    private func deleteImageAction(point: CGPoint, completion: @escaping (Bool) -> Void) { //удаление из userDefaults
     let defaults = UserDefaults.standard
     var libraryPhotos = [String]()
        if let indexPath = collectionView.indexPathForItem(at: point) {
                    if let savedPhotos = defaults.object(forKey: "photos") as? Data {
                           if let decodedPhotos = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPhotos) as? [String] {
                               libraryPhotos = decodedPhotos
                           }
                       }
                    libraryPhotos.remove(at: indexPath.item)
            
                    if let saveData = try? NSKeyedArchiver.archivedData(withRootObject: libraryPhotos, requiringSecureCoding: false) {
                        defaults.set(saveData, forKey: "photos")
                        
            }
            print(indexPath.row)
            completion(true)
        } else {
            print("Could not find index path")
            completion(false)
        }
    }
    
    private func addGesture() {
        longTapGesture.addTarget(self, action: #selector(longTapGesturePressed))
        collectionView.addGestureRecognizer(longTapGesture)
    }
    
    private func unarchivedData() {
        if let savedPhotos = userDefaults.object(forKey: "photos") as? Data {
            if let decodedPhotos = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPhotos) as? [String] {
                listOfPhotos = decodedPhotos
            }
        }
       }
    @objc private func refreshButtonPressed() {
        unarchivedData()
        collectionView.reloadData()
    }
    
    // MARK: - Setup UI Elements
    
    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "Library"
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = #colorLiteral(red: 0.5019607843, green: 0.4980392157, blue: 0.4980392157, alpha: 1)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonPressed))
    }
     private func setupCollectionView() {
            collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
            collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            collectionView.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.9725490196, blue: 0.9921568627, alpha: 1)
            view.addSubview(collectionView)
            
        collectionView.register(LibraryViewCell.self, forCellWithReuseIdentifier: LibraryViewCell.reuseId)
            
            collectionView.delegate = self
            collectionView.dataSource = self
        }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension LibraryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryViewCell.reuseId, for: indexPath) as! LibraryViewCell
        let photoUrl = listOfPhotos[indexPath.item]
        cell.libraryPhoto = photoUrl
        cell.backgroundColor = .darkGray
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     fullVC.modalPresentationStyle = .fullScreen
        present(fullVC, animated: true) { [weak self] in
            self?.fullVC.addLibraryButton.isEnabled = false
            self?.fullVC.addLibraryButton.isHidden = true
         let unsplashPhoto = self?.listOfPhotos[indexPath.item]
            self?.fullVC.fetchImage(unsplahPhotoUrl: unsplashPhoto)
         self?.fullVC.delegate = self
             
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension LibraryViewController: UICollectionViewDelegateFlowLayout {
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
}

//MARK: Image moving back or forward
extension LibraryViewController: ImageMovingDelegate {
    
    private func getImage(isForwardImage: Bool) -> String? {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return nil }
        collectionView.deselectItem(at: indexPath, animated: true)
        var nextIndexPath: IndexPath!
        if isForwardImage {
            nextIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
            if nextIndexPath.item == listOfPhotos.count {
                nextIndexPath.item = 0
            }
        } else {
            nextIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            if nextIndexPath.item == -1 {
                nextIndexPath.item = listOfPhotos.count - 1
            }
        }
        collectionView.selectItem(at: nextIndexPath, animated: true, scrollPosition: .init())
        let nextPhoto = listOfPhotos[nextIndexPath.item]
        return nextPhoto
        
    }
    
    func moveBackForPreviousImage() -> String? {
        return getImage(isForwardImage: false)
    }
    
    func moveForwardForNextImage() -> String? {
        return getImage(isForwardImage: true)
    }
    
    
}
