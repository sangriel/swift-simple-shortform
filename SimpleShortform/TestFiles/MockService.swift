//
//  MockService.swift
//  Marble
//
//  Created by sangmin han on 2023/04/01.
//

import Foundation
import RxSwift
import RxCocoa

class MockService {
    
     func makeMockData(fileName : String) -> BaseListModel {
        let path = Bundle.main.path(forResource: fileName, ofType: "json")!
        let jsonString = try! String(contentsOfFile: path)
        
        let decoder = JSONDecoder()
        let data = jsonString.data(using: .utf8)
        let result = try! decoder.decode(BaseListModel.self, from: data!)
        return result
    }
    

}
