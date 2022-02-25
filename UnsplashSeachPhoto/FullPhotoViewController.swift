//
//  FullPhotoViewController.swift
//  UnsplashSeachPhoto
//
//  Created by T on 25.11.2021.
//  Copyright © 2021 Spridl. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

protocol ImageMovingDelegate: class {
    func moveBackForPreviousImage() -> String?
    func moveForwardForNextImage() -> String?
}

class FullPhotoViewController: UIViewController {
    
    weak var delegate: ImageMovingDelegate?
    
    let topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.alpha = 0.2
        return view
    }()
    
    let dismissButton: UIButton = {
       let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setPreferredSymbolConfiguration(.init(pointSize: 28), forImageIn: .normal)
        button.addTarget(self, action: #selector(dismissButtonPressed), for: .touchUpInside)
        button.alpha = 0.7
        return button
    }()
    let addLibraryButton: UIButton = {
       let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setPreferredSymbolConfiguration(.init(pointSize: 30), forImageIn: .normal)
        button.alpha = 0.7
        button.addTarget(self, action: #selector(addLibraryButtonPressed), for: .touchUpInside)
        return button
    }()
    let saveToGaleryButton: UIButton = {
       let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setPreferredSymbolConfiguration(.init(pointSize: 35), forImageIn: .normal)
        button.alpha = 0.7
        button.addTarget(self, action: #selector(shareImage), for: .touchUpInside)
        return button
    }()
    
    
    
    let fullPhotoImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
  
    let photoImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    var unsplashPhoto: UnsplashPhoto! {
          didSet {
            fetchImage(unsplahPhotoUrl: unsplashPhoto.urls["regular"])
            hideAddButton()
          }
      }
    
    let tapGesture = UITapGestureRecognizer()
    let swipeDownGesture = UISwipeGestureRecognizer()
    let swipeLeftGesture = UISwipeGestureRecognizer()
    let swipeRightGesture = UISwipeGestureRecognizer()
    
    var statusBarHide = false
    override var prefersStatusBarHidden: Bool {
        return statusBarHide
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle(rawValue: 1)!
    }
    
    var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupImageView()
        setupView()
        setupButton()
        addBlur()
        addGesture()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        FullPhotoViewController().dismiss(animated: true) {
            self.photoImageView.image = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func hideAddButton() {
        let defaults = UserDefaults.standard
        let photo = unsplashPhoto.urls["regular"]
        var libraryPhotos = [String]()
        if let savedPhotos = defaults.object(forKey: "photos") as? Data {
               if let decodedPhotos = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPhotos) as? [String] {
                   libraryPhotos = decodedPhotos
               }
           }
        if libraryPhotos.contains(photo!) {
            addLibraryButton.isHidden = true
        } else {
            addLibraryButton.isHidden = false
        }
        
    }
    
    @objc private func tapGesturePressed(sender: UITapGestureRecognizer!) {
        switch statusBarHide {
        case true:
            UIView.animate(withDuration: 0.5) {
                self.topView.alpha = 0.2
                self.dismissButton.alpha = 0.7
                self.addLibraryButton.alpha = 0.7
                self.saveToGaleryButton.alpha = 0.7
            }
            statusBarHide = false
            setNeedsStatusBarAppearanceUpdate()
        default:
            UIView.animate(withDuration: 0.5) {
                self.topView.alpha = 0
                self.dismissButton.alpha = 0
                self.addLibraryButton.alpha = 0
                self.saveToGaleryButton.alpha = 0
            }
            statusBarHide = true
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    private func addGesture() {
        tapGesture.addTarget(self, action: #selector(tapGesturePressed))
        view.addGestureRecognizer(tapGesture)
        
        swipeDownGesture.direction = .down
        swipeDownGesture.addTarget(self, action: #selector(dismissButtonPressed))
        view.addGestureRecognizer(swipeDownGesture)
        
        swipeLeftGesture.direction = .left
        swipeLeftGesture.addTarget(self, action: #selector(swipeLeft))
        
        swipeRightGesture.direction = .right
        swipeRightGesture.addTarget(self, action: #selector(swipeRight))
        
        view.addGestureRecognizer(swipeRightGesture)
        view.addGestureRecognizer(swipeLeftGesture)
    }
    
    private func addBlur() {
        let effect = UIBlurEffect(style: .dark)
        let visualEffect = UIVisualEffectView(effect: effect)
        visualEffect.frame = view.bounds
        visualEffect.alpha = 0.9
        visualEffect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        fullPhotoImageView.addSubview(visualEffect)

    }
    
    func fetchImage(unsplahPhotoUrl: String?) {
        let photoUrl = unsplahPhotoUrl
        guard let imageUrl = photoUrl, let url = URL(string: imageUrl) else { return }
        photoImageView.sd_setImage(with: url, completed: nil)
        fullPhotoImageView.sd_setImage(with: url, completed: nil)
        
    }
    
    @objc private func swipeLeft() {
        let photoUrl = delegate?.moveForwardForNextImage()
        fetchImage(unsplahPhotoUrl: photoUrl)
    }
    
    @objc private func swipeRight() {
        let photoUrl = delegate?.moveBackForPreviousImage()
        fetchImage(unsplahPhotoUrl: photoUrl)
    }
    
    @objc private func shareImage(sender: UIButton!) {
        let shareController = UIActivityViewController(activityItems: [fullPhotoImageView.image!], applicationActivities: nil)
        present(shareController, animated: true, completion: nil)
    }
    
    @objc private func dismissButtonPressed(sender: UIButton!) {
        self.dismiss(animated: true) {
            self.photoImageView.image = nil
            self.fullPhotoImageView.image = nil
        }
    }
    
    @objc private func addLibraryButtonPressed(sender: UIButton!) {
        let defaults = UserDefaults.standard
        guard let photo = unsplashPhoto.urls["regular"] else { return }
        var libraryPhotos = [String]()
        if let savedPhotos = defaults.object(forKey: "photos") as? Data {
               if let decodedPhotos = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPhotos) as? [String] {
                   libraryPhotos = decodedPhotos
               }
           }
        
        libraryPhotos.append(photo)
        if let saveData = try? NSKeyedArchiver.archivedData(withRootObject: libraryPhotos, requiringSecureCoding: false) {
            defaults.set(saveData, forKey: "photos")
        }
        sender.isHidden = true
        
    }
    
    private func setupButton() {
        view.addSubview(dismissButton)
        view.addSubview(saveToGaleryButton)
        view.addSubview(addLibraryButton)
        
        dismissButton.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -5).isActive = true
        dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        
        addLibraryButton.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -5).isActive = true
        addLibraryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        saveToGaleryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60).isActive = true
        saveToGaleryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupImageView() {
        
        view.addSubview(fullPhotoImageView)
        view.addSubview(photoImageView)
        
         photoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
         photoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
         photoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        NSLayoutConstraint.activate([
            fullPhotoImageView.topAnchor.constraint(equalTo: view.topAnchor),
            fullPhotoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fullPhotoImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fullPhotoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
     }
    
    private func setupView() {
        view.addSubview(topView)
        topView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: view.frame.height / 11).isActive = true
        
        
        
    }
}


