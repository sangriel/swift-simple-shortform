//
//  ImageDownloadHelper.swift
//  Marble
//
//  Created by sangmin han on 2023/03/31.
//

import Foundation
import RxSwift

class ImageDownLoader {
    static let shared = ImageDownLoader()
    private init(){}
    
    //이미지 캐싱을 위한 변수입니다.
    private let cache = NSCache<NSString,NSData>()
    
    func download(imageUrl : URL) -> Observable<Data> {
        return Observable<Data>.create { [unowned self] seal  in
            
            if let imageData = cache.object(forKey: imageUrl.absoluteString as NSString) {
                seal.onNext(imageData as Data)
                seal.onCompleted()
                return Disposables.create{ }
            }
            
            let task = URLSession.shared.downloadTask(with: imageUrl) { [unowned self] url, response, error in
                if let error = error {
                    seal.onError(error)
                    return
                }
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    seal.onError(CustomError.error(
                        "HTTP Error - status code \((response as? HTTPURLResponse)?.statusCode ?? -1)"
                    ))
                    return
                }
                
                guard let url = url else {
                    seal.onError(CustomError.error("invalid url"))
                    return
                }
                
                do {
                    let data = try Data(contentsOf: url)
                    
                    self.cache.setObject(data as NSData, forKey: imageUrl.absoluteString as NSString)
                    seal.onNext(data)
                    seal.onCompleted()
                }
                catch( let error ) {
                    seal.onError(error)
                }
            }
            
            task.resume()
            
            return Disposables.create{ task.cancel() }
        }
    }
    
    func download(imageUrl : String) -> Observable<Data> {
        return Observable<Data>.create { [unowned self] seal  in
            
            if let imageData = cache.object(forKey: imageUrl as NSString) {
                seal.onNext(imageData as Data)
                seal.onCompleted()
                return Disposables.create{ }
            }
            
            guard let url = URL(string: imageUrl) else {
                seal.onError(CustomError.error("invalid image url"))
                return Disposables.create{ }
            }
            
            let task = URLSession.shared.downloadTask(with: url) { [unowned self] url, response, error in
                if let error = error {
                    seal.onError(error)
                    return
                }
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    seal.onError(CustomError.error(
                        "HTTP Error - status code \((response as? HTTPURLResponse)?.statusCode ?? -1)"
                    ))
                    return
                }
                
                guard let url = url else {
                    seal.onError(CustomError.error("invalid url"))
                    return
                }
                
                do {
                    let data = try Data(contentsOf: url)
                    
                    self.cache.setObject(data as NSData, forKey: imageUrl as NSString)
                    seal.onNext(data)
                    seal.onCompleted()
                }
                catch( let error ) {
                    seal.onError(error)
                }
            }
            
            task.resume()
            
            return Disposables.create{ task.cancel() }
        }
    }
    
}
