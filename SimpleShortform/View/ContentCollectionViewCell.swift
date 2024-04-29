//
//  ContentCollectionViewCell.swift
//  Marble
//
//  Created by sangmin han on 2023/03/31.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import AVKit
import OSLog



class ContentCollectionViewCell : UICollectionViewCell {
    
    
    static let cellId = "contentCollectionViewCellId"
    
    private let imageView : UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
    }()
    
    
    private let retryBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("다시 시도하기", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .black
        btn.layer.cornerRadius = 10
        btn.isHidden = true
        return btn
    }()
    
    private let spinnerView : UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .black
        spinner.isHidden = true
        return spinner
    }()
    private let videoView : VideoPlayer = {
        let videoView = VideoPlayer()
        videoView.translatesAutoresizingMaskIntoConstraints = false
        return videoView
    }()
    
    private var viewModel : ContentViewModel!
    //앱이 최초로 실행되었을때 동영상을 재생할지 말지 결정하는 변수 입니다.
    private var playVideoInLaunch : Bool = false
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .gray
        setLayout()
        bindView()
    }
    
    required init?(coder : NSCoder){
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
        self.bindView()
        self.retryBtn.isHidden = true
        self.imageView.isHidden = true
        self.videoView.isHidden = true
        self.imageView.image = nil
        videoView.refreshPlayer()
        
    }
    
    func playVideoInLaunch(_ shouldPlay : Bool){
        playVideoInLaunch = shouldPlay
    }
    
    func setViewModel(viewModel : ContentViewModel){
        self.viewModel = viewModel
        guard let url = URL(string: viewModel.urlString) else {
            showErrorView()
            return
        }
        if viewModel.type == .image {
            downloadImage(url: url)
        }
        else if viewModel.type == .video {
            self.downloadVideo(url: url)
        }
    }
    
    func play(){
        if viewModel.type != .video { return }
        videoView.play()
    }
    
    func pause(){
        if viewModel.type != .video { return }
        videoView.pause()
    }
    
    
    private func downloadImage(url : URL){
        startSpinnerView()
        ImageDownLoader.shared.download(imageUrl: url)
            .map{ UIImage(data: $0) }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext : { [weak self] image in
                self?.imageView.image = image
                self?.showImageView()
                self?.stopSpinnerView()
            },
            onError: { [weak self] err in
                if let err = err as? CustomError {
                    print(err.getDesc())
                }
                else {
                    print(err.localizedDescription)
                }
                self?.showErrorView()
                self?.stopSpinnerView()
            })
            .disposed(by: disposeBag)
    }
    private func downloadVideo(url : URL){
        startSpinnerView()
        VideoDownloadHelper.shared.downLoadVideo(url: url)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext : { [weak self] item in
                self?.showVideoView()
                self?.videoView.setAVPlayerItem(item: item)
                self?.stopSpinnerView()
                //셀이 최초로 로딩되었을때 동영상을 바로 실행합니다.
                if self != nil && self!.playVideoInLaunch{
                    self?.play()
                    self?.playVideoInLaunch = false
                }
            },onError: { [weak self] error in
                self?.showErrorView()
                self?.stopSpinnerView()
                if let error = error as? CustomError{
                    print(error.getDesc())
                }
                else {
                    print(error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    private func bindView(){
        
        videoView.playerLoadSuccessObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext : { [weak self] isLoaded in
                self?.stopSpinnerView()
                if isLoaded {
                    self?.showVideoView()
                }
                else {
                    self?.showErrorView()
                }
            })
            .disposed(by: disposeBag)
        
        retryBtn.rx.tap
            .subscribe(onNext : { [weak self] in
                guard let self = self else { return }
                guard let url = URL(string: self.viewModel.urlString) else { return }
                self.startSpinnerView()
                if self.viewModel.type == .image {
                    self.downloadImage(url: url)
                }
                else {
                    self.downloadVideo(url: url)
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    
    private func showErrorView(){
        self.retryBtn.isHidden = false
        self.imageView.isHidden = true
        self.videoView.isHidden = true
    }
    
    private func showImageView(){
        self.retryBtn.isHidden = true
        self.imageView.isHidden = false
        self.videoView.isHidden = true
    }
    
    private func showVideoView(){
        self.retryBtn.isHidden = true
        self.imageView.isHidden = true
        self.videoView.isHidden = false
    }
    
    private func startSpinnerView(){
        spinnerView.isHidden = false
        spinnerView.startAnimating()
    }
    
    private func stopSpinnerView(){
        spinnerView.isHidden = true
        spinnerView.stopAnimating()
    }
}
extension ContentCollectionViewCell {
    private func setLayout(){
        self.addSubview(imageView)
        self.addSubview(videoView)
        self.addSubview(retryBtn)
        self.addSubview(spinnerView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            
            videoView.topAnchor.constraint(equalTo: self.topAnchor),
            videoView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            videoView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            retryBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            retryBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            retryBtn.widthAnchor.constraint(equalToConstant: 100),
            retryBtn.heightAnchor.constraint(equalToConstant: 40),
            
            spinnerView.bottomAnchor.constraint(equalTo: retryBtn.topAnchor,constant: -20),
            spinnerView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            
        ])
    }
    
}

