//
//  PostListViewController.swift
//  Marble
//
//  Created by sangmin han on 2023/03/31.
//

import Foundation
import UIKit
import AVFoundation
import RxSwift
import RxCocoa


class PostListViewController : UIViewController {
    
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.alwaysBounceVertical = true
        cv.backgroundColor = .white
        cv.isPagingEnabled = true
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = viewModel
        cv.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.cellId)
        cv.contentInsetAdjustmentBehavior = .never
        cv.refreshControl = refreshControl
        return cv
    }()
    
    let speakerBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "ic_speaker_filled")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.setImage(UIImage(named: "ic_speaker_mute")?.withRenderingMode(.alwaysTemplate), for: .selected)
        btn.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    
    let retryBtn : UIButton = {
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
    
    let spinnerView : UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .black
        spinner.isHidden = true
        return spinner
    }()
    
    lazy var refreshControl : UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshCollectionView(sender:)), for: .valueChanged)
        refreshControl.tintColor = .black
        return refreshControl
    }()
    
    let pagingErrorView : PagingErrorView = {
        let pagingErrorView = PagingErrorView()
        pagingErrorView.translatesAutoresizingMaskIntoConstraints = false
        pagingErrorView.isHidden = true
        return pagingErrorView
    }()
    
    
    lazy private var viewModel = PostListViewModel()
    
    private var disposeBag = DisposeBag()
    private var oldOffset : CGFloat = 0
    private let requestFetch = BehaviorRelay<ReloadType>(value: .refresh)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        setLayout()
        bindViewModel()
        
    }

    private func bindViewModel(){
        //action
        
        retryBtn.rx.tap
            .subscribe(onNext : { [weak self] in
                self?.spinnerView.isHidden = false
                self?.spinnerView.startAnimating()
                self?.requestFetch.accept(.refresh)
                self?.retryBtn.isHidden = true
            })
            .disposed(by: disposeBag)
        
        let toggleSpeaker = speakerBtn.rx.tap
            .map{ [weak self] _ -> Bool in
                return !(self?.speakerBtn.isSelected ?? false)
            }
                
        let input = PostListViewModel.Input(requestFetch: requestFetch.asObservable(),
                                            toggleSpeaker: toggleSpeaker)
        
        let output = viewModel.transform(input: input)
        
        
        output.refreshCollectionView
            .observe(on: MainScheduler.instance)
            .subscribe(onNext : { [weak self] in
                guard let self = self else { return }
                self.collectionView.reloadData()
                if self.spinnerView.isHidden == false {
                    self.spinnerView.isHidden = true
                    self.spinnerView.stopAnimating()
                }
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        
        output.showRetryView
            .observe(on: MainScheduler.instance)
            .subscribe(onNext : { [weak self] show in
                self?.retryBtn.isHidden = !show
            })
            .disposed(by: disposeBag)
        
        output.showErrorView
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext : { [weak self] show in
                self?.pagingErrorView.isHidden = !show
            })
            .disposed(by: disposeBag)
        
        output.toggleSpeaker
            .bind(to: speakerBtn.rx.isSelected)
            .disposed(by: disposeBag)
        
        
    }
    
    
    @objc func refreshCollectionView(sender : UIRefreshControl){
        self.refreshControl.beginRefreshing()
        requestFetch.accept(.refresh)
    }
    
    
    
}
extension PostListViewController {
    private func setLayout(){
        self.view.addSubview(collectionView)
        self.view.addSubview(speakerBtn)
        self.view.addSubview(retryBtn)
        self.view.addSubview(spinnerView)
        self.view.addSubview(pagingErrorView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            speakerBtn.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 20),
            speakerBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -20),
            speakerBtn.widthAnchor.constraint(equalToConstant: 40),
            speakerBtn.heightAnchor.constraint(equalToConstant: 40),
            
            
            retryBtn.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            retryBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            retryBtn.widthAnchor.constraint(equalToConstant: 100),
            retryBtn.heightAnchor.constraint(equalToConstant: 40),
            
            spinnerView.bottomAnchor.constraint(equalTo: retryBtn.topAnchor,constant: -20),
            spinnerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            
            pagingErrorView.topAnchor.constraint(equalTo: self.view.topAnchor),
            pagingErrorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            pagingErrorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            pagingErrorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            
            
        ])
    }
    
}
extension PostListViewController : UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.numberOfItems(inSection: 0) - indexPath.row == 1 {
            requestFetch.accept(.paging)
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.calculateAlpha(scrollView)
        self.checkFocusedCell(scrollView)
    }
    
    /**
     스크롤이 됨에 따라 알파를 적용하는 함수
     */
    private func calculateAlpha(_ scrollView : UIScrollView) {
        let scrollViewHeight = scrollView.frame.height
        let yContentOffset = scrollView.contentOffset.y
        let index = Int( yContentOffset / scrollViewHeight )
        if let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? PostCollectionViewCell {
            if oldOffset > yContentOffset {
                
                //스크롤을 아래로 내리고 있는 경우 인덱스 위에서 내려오고 있는 셀을 바라보게 됩니다.
                //yContentOffset이 점점 작아지게 되고 oldOffset - yContentOffset 최소차는 scrollViewHeight 만큼 됩니다.
                //따라서 위에 있는 셀이 아래로 내려올수록 알파가 1에 가까워집니다.
                cell.setContentAlphas(value: (oldOffset - yContentOffset ) / (scrollViewHeight * 0.75))
            }
            else {
                //스크르롤 위로 올리는 경우 인덱스가 현재 포커싱된 셀을 바라보게 됩니다.
                if yContentOffset < oldOffset + scrollViewHeight - 20 {
                    cell.setContentAlphas(value: 1 - ((yContentOffset - oldOffset) / (scrollViewHeight * 0.75)))
                }
                else {
                    cell.setContentAlphas(value: 1)
                }
            }
        }
    }
    
    /**
     현재 포커싱이 되는 셀을 판별하는 함수
     포커싱의 기준점은 화면의 중앙을 차지했냐 안했냐로 따지고 있습니다.
     */
    private func checkFocusedCell(_ scrollView : UIScrollView){
        let centerIndex = Int((scrollView.contentOffset.y + scrollView.frame.height / 2) / scrollView.frame.height)
        let centeredIndexPath = IndexPath(row: centerIndex, section: 0)
        
        let visibleIndexPath = collectionView.indexPathsForVisibleItems
        for indexPath in visibleIndexPath {
            if let cell = collectionView.cellForItem(at: indexPath) as? PostCollectionViewCell {
                cell.isCellFocused(isFocused: indexPath == centeredIndexPath)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //처음 드래깅 하는 위치를 저장합니다.
        oldOffset = scrollView.contentOffset.y
    }
    
    
    /**
     드래깅을 하며 1차적으로 포커싱을 설정하고
     2차로 셀이 완전히 화면에서 벗어날때 한번더 설정해 줍니다.
     */q
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PostCollectionViewCell {
            cell.isCellFocused(isFocused: false)
        }
    }
    

    
}
