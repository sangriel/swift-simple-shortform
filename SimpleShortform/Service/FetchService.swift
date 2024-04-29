//
//  FetchService.swift
//  Marble
//
//  Created by sangmin han on 2023/03/31.
//

import Foundation
import RxSwift
import RxCocoa


protocol FetchServiceDelegate {
    func fetchPosts(page : Int) -> Observable<NetWorkResult<BaseListModel>>
}


class FetchService : FetchServiceDelegate {
    
    private let networkManager = NetWorkManager()
    private let baseUrl : String = "https://0fjrekl8p0.execute-api.ap-northeast-1.amazonaws.com/dev/posts"
    
    func fetchPosts(page: Int) -> Observable<NetWorkResult<BaseListModel>> {
        return networkManager.execute(method: .GET, baseUrl: baseUrl, parameter: ["page" : page])
    }
    
    
}
