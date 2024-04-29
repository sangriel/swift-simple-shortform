//
//  NetWorkManager.swift
//  Marble
//
//  Created by sangmin han on 2023/03/31.
//

import Foundation
import RxSwift
import RxCocoa

enum HttpMethod : String {
    case GET
    case POST
    case DELETE
    case PUT
}

class NetWorkManager {
    private func getRequestURL(method : HttpMethod, baseUrl : String, parameter : [String : Any] ) -> (URLRequest?,CustomError?) {
        
        var urlComponents = URLComponents(string: baseUrl)
        
        if method == .DELETE || method == .GET {
            var queryItems : [URLQueryItem] = []
            for (key,value) in parameter {
                let queryItem = URLQueryItem(name: key, value: String(describing: value ))
                queryItems.append(queryItem)
            }
            urlComponents!.queryItems = queryItems
        }
        
        
        guard let url = urlComponents?.url else {
            return (nil,CustomError.error("unable to parse url Request") )
        }
        var requestUrl = URLRequest(url: url)
        requestUrl.httpMethod = method.rawValue
        
        if method == .POST || method == .PUT {
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameter, options: []) else {
                return (nil,CustomError.error("http body making failed"))
            }
            requestUrl.httpBody = httpBody
        }
        
        
        return (requestUrl,nil)
    }
    
    func execute<T : Decodable>(method : HttpMethod,baseUrl : String,parameter : [String : Any]) -> Observable<NetWorkResult<T>> {
        return Observable.create { [weak self] seal in
            guard let self = self else {
                seal.onNext(.error(CustomError.selfDeallocated))
                return Disposables.create()
            }
            
            let (requestUrl,err) = self.getRequestURL(method: method, baseUrl: baseUrl, parameter: parameter)
            
            guard let requestUrl = requestUrl else {
                seal.onNext(.error(err!))
                return Disposables.create()
            }
            
            
            let task = URLSession.shared.dataTask(with: requestUrl) { data, response, error in
                
                if let error = error {
                    seal.onNext(.error(error))
                    return
                }
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    seal.onNext(.error(CustomError.error(
                        "HTTP Error - status code \((response as? HTTPURLResponse)?.statusCode ?? -1)"
                    )))
                    return
                }
                
                guard let data = data, let decoded = try? JSONDecoder().decode(T.self, from: data) else {
                    seal.onNext(.error(CustomError.error("data null or unable to decode data with \(T.self)")))
                    return
                }
                seal.onNext(.success(decoded))
                seal.onCompleted()
            }
            task.resume()
            
            return Disposables.create{
                task.cancel()
            }
        }
    }
    
}
