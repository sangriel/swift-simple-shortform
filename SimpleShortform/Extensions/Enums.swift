//
//  Enums.swift
//  Marble
//
//  Created by sangmin han on 2023/03/31.
//

import Foundation


enum CustomError : Error {
    case error(String)
    case selfDeallocated
    func getDesc() -> String {
        switch self {
        case .error(let desc):
            return desc
        case .selfDeallocated:
            return "selfDeallocated"
        }
    }
}

enum NetWorkResult<T : Codable> {
    case success(T)
    case error(Error)
    
    
}

enum ReloadType {
    case refresh
    case paging
}

