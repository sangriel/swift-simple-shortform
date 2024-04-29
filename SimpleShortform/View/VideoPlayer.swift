//
//  VideoPlayer.swift
//  Marble
//
//  Created by sangmin han on 2023/03/31.
//

import Foundation
import UIKit
import AVKit
import RxSwift
import RxCocoa

class VideoPlayer : UIView {
    
    private var player = AVLoopPlayer()
    lazy private var playerLayer : AVPlayerLayer = {
        let playerLayer = AVPlayerLayer()
        playerLayer.videoGravity = .resizeAspectFill
        self.playerView.layer.addSublayer(playerLayer)
        return playerLayer
    }()
    private var isPlaying = false
    private let playerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private var observerStatus: NSKeyValueObservation?
    
    let playerLoadSuccessObservable = PublishSubject<Bool>()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playerViewTapped(sender: )))
        tapGesture.numberOfTapsRequired = 1
        
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
       fatalError()
    }
    
    
    @objc func playerViewTapped(sender : UITapGestureRecognizer){
        NotificationCenter.default.post(name: Notification.Name("isMute"), object: nil,userInfo: ["isMute" : !self.player.isMuted])
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer.frame = playerView.bounds
        
    }
    
    deinit {
        print("videoView deinit")
    }
    
    /**
     동영상이 재생가능한지 판별하는 함수 입니다.
     */
    private func setObserver(item : AVPlayerItem){
        observerStatus = item.observe(\.status, changeHandler: { [weak self] (item, value) in
            switch item.status {
            case .readyToPlay:
                self?.playerLoadSuccessObservable.onNext(true)
            case .failed, .unknown:
                print("video failed")
                self?.playerLoadSuccessObservable.onNext(false)
            @unknown default:
                self?.playerLoadSuccessObservable.onNext(false)
            }
        })
    }
    
    
    func setAVPlayerItem(item : AVPlayerItem){
        self.setObserver(item: item)
        self.player.replaceCurrentItem(with: item)
        playerLayer.player = self.player
    }
    
    /**
     셀이 재사용이 됨에 따라 이전에 있던 AvPlayerItem을 초기화 시켜주는 함수 입니다.
     */
    func refreshPlayer(){
        self.player.replaceCurrentItem(with: nil)
    }
    
    
    func play() {
        guard !isPlaying else { return }
        player.play()
        isPlaying = true
        
    }
    
    func pause() {
        guard isPlaying else { return }
        player.pause()
        isPlaying = false
        
    }
    
    
}
extension VideoPlayer {
    private func setLayout(){
        self.addSubview(playerView)
        
        
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: self.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
