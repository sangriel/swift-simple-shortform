//
//  ViewModelType.swift
//  Marble
//
//  Created by sangmin han on 2023/03/31.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input : Input) -> Output
}
