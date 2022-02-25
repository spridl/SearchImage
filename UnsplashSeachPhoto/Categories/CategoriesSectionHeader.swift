//
//  CategoriesSectionHeader.swift
//  UnsplashSeachPhoto
//
//  Created by T on 19.11.2021.
//  Copyright © 2021 Spridl. All rights reserved.
//

import Foundation
import UIKit

class CategoriesSectionHeader: UICollectionReusableView {
    let categoriesVC = CategoriesViewController()
    let seeMoreVC = SeeMoreVC()
    let title = UILabel()
    let seeMoreButton = UIButton()
    static let reuseId = "SectionHeader"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customizedElements()
        setupConstraints()
    }
        
    private func customizedElements() {
        title.textColor = .black
        title.font = UIFont(name: "Apple Symbols", size: 25)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        seeMoreButton.translatesAutoresizingMaskIntoConstraints = false
        seeMoreButton.setTitleColor(.black, for: .normal)
        seeMoreButton.setTitle("See more ", for: .normal)
        seeMoreButton.titleLabel?.font = UIFont(name: "Apple Symbols", size: 22)
        seeMoreButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        seeMoreButton.tintColor = .black
        seeMoreButton.semanticContentAttribute = .forceRightToLeft
    }
    private func setupConstraints() {
        addSubview(title)
        addSubview(seeMoreButton)
        
        title.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        title.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        seeMoreButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        seeMoreButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
