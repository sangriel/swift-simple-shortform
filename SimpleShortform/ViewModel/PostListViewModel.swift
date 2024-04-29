//
//  PostListViewModel.swift
//  Marble
//
//  Created by sangmin han on 2023/04/01.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import AVFoundation


class PostListViewModel : NSObject, ViewModelType {
    struct Input {
        let requestFetch : Observable<ReloadType>
        let toggleSpeaker : Observable<Bool>
    }
    
    struct Output {
        let refreshCollectionView : Observable<Void>
        let showRetryView : Observable<Bool>
        let showErrorView : Observable<Bool>
        let toggleSpeaker : Observable<Bool>
    }
    
    private let showRetryView = PublishSubject<Bool>()
    private let showErrorView = PublishSubject<Bool>()
    private let toggleSpeaker = PublishSubject<Bool>()
    
    private let fetchService : FetchServiceDelegate!
    private var cvDataSource : [PostModel] = []
    private var currentPage : Int = 0
    private var isLoading : Bool = false
    private var noMoredata : Bool = false
    //앱이 최초로 실행되었을때 동영상을 바로 재생하기 위한 변수입니다.
    private var isFirstLoad : Bool = true
    private var disposeBag = DisposeBag()
    
    
    init(fetchService : FetchServiceDelegate = FetchService()){
        self.fetchService = fetchService
        super.init()
        addNotificationObserver()
        
    }
    
    
    
    func transform(input: Input) -> Output {
        
        let refreshCollectionView = input.requestFetch
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
        //페이징의 경우 짧은 사이의 많은 수의 요청이 올 수도 있기 때문에 이를 방지하고 최초 fetchRequest이후 일정시간동안 요청을 무시합니다.
            .throttle(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .skip(while: { [weak self]  reloadType -> Bool in
                guard let self = self else  { return true }
                self.noMoredata = reloadType == .refresh ? false : self.noMoredata
                //지금 자신이 로딩중이거나 더이상의 데이터가 없다면 이벤트를 건너 뜁니다.
                return self.isLoading || self.noMoredata
            })
            .map { [weak self] type -> (Int,ReloadType) in
                guard let self = self else {
                    return (0,.refresh)
                }
                if type == .refresh {
                    self.currentPage = 0
                }
                else {
                    self.currentPage += 1
                }
                return (self.currentPage,type)
            }
            .flatMap { [weak self] page,type -> Observable<Void> in
                guard let self = self else { return .just(()) }
                return self.fetch(page: page, reloadType: type)
            }
        
        input.toggleSpeaker
            .subscribe(onNext : { isMute in
                NotificationCenter.default.post(name: Notification.Name("isMute"), object: nil,userInfo: ["isMute" : isMute])
            })
            .disposed(by: disposeBag)
        
        
        return Output(refreshCollectionView: refreshCollectionView,
        showRetryView: showRetryView,
        showErrorView: showErrorView,
        toggleSpeaker: toggleSpeaker)
    }
    
    private func fetch(page : Int,reloadType : ReloadType) -> Observable<Void> {
        self.isLoading = true
        return fetchService.fetchPosts(page: page)
            .observe(on: MainScheduler.instance)
            .map{ [weak self] result -> Void in
                self?.isLoading = false
                switch result {
                case .success(let data):
                    self?.showRetryView.onNext(false)
                    self?.setcvDataSource(data: data,reloadType: reloadType)
                case.error(_):
                    if page == 0 {
                        self?.showRetryView.onNext(true)
                        self?.cvDataSource.removeAll()
                    }
                    else{
                        self?.currentPage -= 1
                        self?.showErrorView.onNext(true)
                    }
                }
                return
            }
    }
    
    
    private func setcvDataSource(data : BaseListModel,reloadType : ReloadType){
        if reloadType == .refresh {
            self.cvDataSource.removeAll()
        }
        cvDataSource.append(contentsOf: data.posts!)
        noMoredata = data.posts!.isEmpty
    }
    
    
    private func addNotificationObserver(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name("isMute"), object: nil, queue: nil) { [
        weak self] data in
            if let dict = data.userInfo, let isMute = dict["isMute"] as? Bool {
                self?.toggleSpeaker.onNext(isMute)
            }
        }
    }
    
    
    
}
extension PostListViewModel : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cvDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.cellId, for: indexPath) as! PostCollectionViewCell
        var shouldPlayVideoOnFirstLaunch : Bool
        //최초 실행이면서 인덱스가 0일 경우 동영상 재생을 준비합니다.
        if isFirstLoad == true && indexPath.row == 0 {
            shouldPlayVideoOnFirstLaunch = true
            isFirstLoad = false
        }
        else {
            shouldPlayVideoOnFirstLaunch = false
        }
        cell.setViewModel(viewModel: ContentListViewModel(data: cvDataSource[indexPath.row],shouldPlayVideoOnFirstLaunch: shouldPlayVideoOnFirstLaunch))
        
        
        return cell
    }
    
    
}
