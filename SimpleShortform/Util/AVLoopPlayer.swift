//
//  AVLoopPlayer.swift
//  Marble
//
//  Created by sangmin han on 2023/03/31.
//

import Foundation
import AVKit

class AVLoopPlayer: AVPlayer {
    
    
    override init() {
        super.init()
        initialize()
        
    }
    
    override init(url URL: URL) {
        super.init(url: URL)
        initialize()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initialize() {
        NotificationCenter.default.addObserver(self, selector: #selector(didRecieveNotification(sender:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("isMute"), object: nil, queue: nil) { [
        weak self] data in
            if let dict = data.userInfo, let isMute = dict["isMute"] as? Bool {
                self?.isMuted = isMute
            }
        }
    }
    
    
    @objc func didRecieveNotification(sender : Notification){
        if self.timeControlStatus == .paused { return }
        self.seek(to: CMTime.zero)
        self.play()
    }
    
    
}
