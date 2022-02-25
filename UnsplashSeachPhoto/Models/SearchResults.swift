//
//  SearchResults.swift
//  UnsplashSeachPhoto
//
//  Created by T on 21.11.2021.
//  Copyright © 2021 Spridl. All rights reserved.
//

import Foundation

struct SearchResults: Decodable {

    let total: Int
    let results: [UnsplashPhoto]

}

struct UnsplashPhoto: Decodable{


    let width: Int
    let height: Int
    let urls: [URLKing.RawValue : String]


    enum URLKing: String {
        case raw
        case full
        case regular
        case small
        case thumb
    }

}


