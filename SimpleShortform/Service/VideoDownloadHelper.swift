//
//  VideoDownloadHelper.swift
//  Marble
//
//  Created by sangmin han on 2023/04/01.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation

class VideoDownloadHelper : NSObject {
    
    static let shared = VideoDownloadHelper()
    private let assetKeysRequiredToPlay : [String] = [ "playable", "hasProtectedContent"]
    
    //완전히 다운로드된 동영상을 기기내에 저장할때 쓰는 경로입니다.
    private var dirPathURL : URL? = {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirpath = paths.first {
           return URL(fileURLWithPath: dirpath).appendingPathComponent("MyFolder/Caches")
        }
        else {
            return nil
        }
    }()
    
    private override init() {
        guard let dirPathURL = dirPathURL else { return }
        
        do {
            //기기내 동영상을 저장할 디렉토리를 생성합니다.
            try FileManager.default.createDirectory(at: dirPathURL, withIntermediateDirectories: true)
        }
        catch(let error){
            print(error)
        }
        

    }
    
    func downLoadVideo(url : URL) -> Observable<AVPlayerItem> {
        //기기내에 동영상이 저장되어 있다면 서버에 요청하지 않고 바로 동영상 데이터를 반환합니다.
        if let cached = self.findCachedVideo(url: url) {
            return .just(AVPlayerItem(url: cached))
        }
        else {
            return self.asynchronouslyLoadURLAssets(AVURLAsset(url: url))
        }
    }
    
    private func asynchronouslyLoadURLAssets(_ asset: AVURLAsset) -> Observable<AVPlayerItem> {
        return Observable<AVPlayerItem>.create { [unowned self] seal  in
            asset.loadValuesAsynchronously(forKeys: self.assetKeysRequiredToPlay) {
                var error: NSError?
                for key in self.assetKeysRequiredToPlay {
                    if asset.statusOfValue(forKey: key, error: &error) == .failed {
                        seal.onError(CustomError.error(error?.localizedDescription ?? "" + " \(key)-\(asset.url.absoluteString)"))
                        return
                    }
                }
                if !asset.isPlayable || asset.hasProtectedContent {
                    seal.onError(CustomError.error("is not playable or has protectedContent"))
                    return
                }
                let currentItem = AVPlayerItem(asset: asset)
                switch asset.statusOfValue(forKey: "playable", error: &error) {
                case .loaded:
                    print("asset loaded")
                    //에셋이 완전히 다운로드가 되었으면 기기내에 저장합니다.
                    self.saveVideoDataToDevice(asset: asset, url: asset.url)
                case .failed:
                    print("asset failed")
                case .cancelled:
                    print("asset cancelled")
                default:
                    print("asset default")
                }

                seal.onNext(currentItem)
            }
            
            return Disposables.create{ }
        }
    }
    
    
    
    /**
     기기내에 동영상이 저장되어 있는지 확인하는 함수 입니다.
     */
    private func findCachedVideo(url : URL) -> URL? {
        guard let dirPathURL = dirPathURL else { return nil }
        guard let videoName = url.pathComponents.last else { return nil }
        let searchURL = dirPathURL.appendingPathComponent("\(videoName)")
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: searchURL.path) {
            return searchURL
        }
        else {
            return nil
        }
        
    }
    

    /**
     기기내에 동영상을 저장하는 함수입니다.
     */
    private func saveVideoDataToDevice(asset : AVURLAsset,url : URL){
        guard let dirPathURL = dirPathURL else { return }
        guard let videoName = url.pathComponents.last else { return }
        

        if findCachedVideo(url: url) != nil { return }
        
        DispatchQueue.main.async {
            asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
            guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough), exporter.supportedFileTypes.contains(AVFileType.mp4) else {
                print("no exporter")
                return
            }
            
            let exportURL = dirPathURL.appendingPathComponent("\(videoName)")
            
            exporter.outputURL = exportURL
            exporter.outputFileType = AVFileType.mp4

            exporter.exportAsynchronously(completionHandler: {
                switch exporter.status {
                case .cancelled:
                    print("export cancelled")
                case .completed:
                    print("export completed")
                case .exporting:
                    print("export exporting")
                case .failed:
                    print("export failed")
                case .unknown:
                    print("export unknown")
                case .waiting:
                    print("export waiting")
                @unknown default:
                    print("export default")
                }
                if let error = exporter.error {
                    print("exporter error",error)
                }
            })
        }
        
    }
    
    
}
extension VideoDownloadHelper : AVAssetResourceLoaderDelegate {
    
    
}
