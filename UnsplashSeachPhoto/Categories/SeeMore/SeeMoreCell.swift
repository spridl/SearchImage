//
//  SeeMoreCell.swift
//  UnsplashSeachPhoto
//
//  Created by T on 27.11.2021.
//  Copyright © 2021 Spridl. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class SeeMoreCell: UICollectionViewCell {
    static let reuseId = "SeeMoreCellId"
    
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
        return imageView
    }()
    let checkmark: UIImageView = {
       let checkmark = UIImageView()
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        return checkmark
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }
    
    override var isSelected: Bool {
        didSet {
            updateSelectedState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        updateSelectedState()
    }
    
    private func updateSelectedState() {
        photoImageView.alpha = isSelected ? 0.7 : 1
        checkmark.alpha = isSelected ? 1 : 0
    }
    
    private func setupImageView() {
        addSubview(photoImageView)
        NSLayoutConstraint.activate([photoImageView.topAnchor.constraint(equalTo: self.topAnchor),
                                     photoImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                                     photoImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                                     photoImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        addSubview(checkmark)
        checkmark.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: -8).isActive = true
        checkmark.bottomAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: -8).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
