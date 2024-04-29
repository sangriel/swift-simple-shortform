//
//  ContentViewModel.swift
//  Marble
//
//  Created by sangmin han on 2023/03/31.
//

import Foundation


struct ContentViewModel {
    
    enum type {
        case image
        case video
    }
    
    let urlString : String
    let type : type
    
}
