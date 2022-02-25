//
//  LibraryViewCell.swift
//  UnsplashSeachPhoto
//
//  Created by T on 18.12.2021.
//  Copyright © 2021 Spridl. All rights reserved.
//

import UIKit

class LibraryViewCell: UICollectionViewCell {
    static let reuseId = "libraryCell"
    
    var libraryPhoto: String! {
        didSet {
            guard let imageUrl = libraryPhoto, let url = URL(string: imageUrl) else { return }
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        addSubview(photoImageView)
        NSLayoutConstraint.activate([photoImageView.topAnchor.constraint(equalTo: self.topAnchor),
                                     photoImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                                     photoImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                                     photoImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }

}
