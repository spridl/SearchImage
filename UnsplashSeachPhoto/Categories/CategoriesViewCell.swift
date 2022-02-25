//
//  CategoriesViewCell.swift
//  UnsplashSeachPhoto
//
//  Created by T on 21.11.2021.
//  Copyright © 2021 Spridl. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class CategoriesViewCell: UICollectionViewCell {
    static let reuseId = "categoriesCellId"
    
    
    var unsplashPhoto: UnsplashPhoto! {
        didSet {
            let photoUrl = unsplashPhoto.urls["regular"]
            guard let imageUrl = photoUrl, let url = URL(string: imageUrl) else { return }
            photoImageView.sd_setImage(with: url, completed: nil)
        }
    }
    let photoImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    var updateBool = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
        
    private func setupImageView() {
        addSubview(photoImageView)
        NSLayoutConstraint.activate([photoImageView.topAnchor.constraint(equalTo: self.topAnchor),
                                     photoImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                                     photoImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                                     photoImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
//        buttonCheck.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(buttonCheck)
//        buttonCheck.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 10).isActive = true
//        buttonCheck.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10).isActive = true
//        buttonCheck.setTitle("Check", for: .normal)
//        buttonCheck.tintColor = .red
//        buttonCheck.layer.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//        buttonCheck.addTarget(self, action: #selector(buttonCheckPressed), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
