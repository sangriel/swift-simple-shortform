//
//  ContentListViewModel.swift
//  Marble
//
//  Created by sangmin han on 2023/03/31.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit


class ContentListViewModel : NSObject, ViewModelType {
    
    
    struct Input {
        
    }
    
    struct Output {
        let profileImage : Driver<UIImage?>
        let infulencerId : Driver<String>
        let likeCount : Driver<String>
        let followCount : Driver<String>
        let description : Driver<String>
        let numberOfPages : Observable<Int>
    }
    
    private var data : PostModel!
    private var shouldPlayVideoOnFirstLaunch : Bool = false
    private var cvdataSource : [ContentViewModel] = []
    private var disposeBag = DisposeBag()
    
    init(data : PostModel,shouldPlayVideoOnFirstLaunch : Bool){
        super.init()
        self.setData(data: data)
        self.shouldPlayVideoOnFirstLaunch = shouldPlayVideoOnFirstLaunch
    }
    
    func transform(input: Input) -> Output {
        
        
        let profileImage = ImageDownLoader.shared.download(imageUrl: data.influencer!.profile_thumbnail_url!)
            .map{ UIImage(data: $0) }
            .asDriver(onErrorJustReturn: UIImage(named: "ic_follow"))
        
        
        return Output(profileImage: profileImage,
                      infulencerId: .just(data.influencer!.display_name!),
                      likeCount: .just(data.like_count!.abstractedNumberString),
                      followCount: .just(data.influencer!.follow_count!.abstractedNumberString),
                      description: .just(data.description!),
                      numberOfPages: .just(data.contents!.count))
    }
    
    
    private func setData(data : PostModel){
        self.data = data
        self.cvdataSource = data.contents!.map { item in
            let type : ContentViewModel.type = item.type! == "video" ? .video : .image
            return .init(urlString: item.content_url ?? "", type: type)
        }
    }
    
}
extension ContentListViewModel : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cvdataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCollectionViewCell.cellId, for: indexPath) as! ContentCollectionViewCell
        if shouldPlayVideoOnFirstLaunch && indexPath.row == 0 {
            cell.playVideoInLaunch(true)
            shouldPlayVideoOnFirstLaunch = false
        }
        else {
            cell.playVideoInLaunch(false)
        }
        cell.setViewModel(viewModel: cvdataSource[indexPath.row])
        
        return cell
    }
    
    
}
