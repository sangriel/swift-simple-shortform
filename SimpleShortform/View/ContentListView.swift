//
//  ContentListView.swift
//  Marble
//
//  Created by sangmin han on 2023/03/31.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import AVKit

class ContentListView : UIView {
     
    lazy private var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        cv.isPagingEnabled = true
        cv.backgroundColor = .black
        cv.register(ContentCollectionViewCell.self, forCellWithReuseIdentifier: ContentCollectionViewCell.cellId)
        cv.delegate = self
        cv.contentInsetAdjustmentBehavior = .never
        return cv
    }()
    
    private let likeBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ic_heart_filled")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let likeCountLabel : UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = .white
        lb.textAlignment = .center
        lb.text = "test"
        return lb
    }()
    
    private let followBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ic_follow")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    private let followCountLabel : UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = .white
        lb.textAlignment = .center
        lb.text = "test"
        return lb
    }()
    
    private let moreBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ic_more")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    private let profileImageView : UIImageView = {
        let imgView = UIImageView()
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 20
        imgView.contentMode = .scaleAspectFill
        imgView.backgroundColor = .blue
        return imgView
    }()
    private let idLabel : UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lb.text = "test"
        return lb
    }()
    
    private let descriptionLabel : UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lb.numberOfLines = 0
        lb.lineBreakMode = .byWordWrapping
        return lb
    }()
    
    private let shrinkAndExpandDescriptionLabelBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "ic_chevron_down")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
        btn.isSelected = false
        return btn
    }()
    
    private let pageController : UIPageControl = {
        let pageController = UIPageControl()
        pageController.translatesAutoresizingMaskIntoConstraints = false
        pageController.currentPage = 0
        pageController.currentPageIndicatorTintColor = .white
        pageController.tintColor = .gray
        return pageController
    }()
    
    lazy private var shortendDescriptionLabelHeight : CGFloat = {
        return ceil(self.descriptionLabel.font.lineHeight * 2)
    }()
    
    private var expandedDescriptionLabelHeight : CGFloat = UIScreen.main.bounds.height - 150
    lazy private var descriptionHeightAnchor : NSLayoutConstraint = {
        return descriptionLabel.heightAnchor.constraint(lessThanOrEqualToConstant: shortendDescriptionLabelHeight)
    }()
    
    private var disposeBag = DisposeBag()
    
    
    private var viewModel : ContentListViewModel!
    
    override init(frame : CGRect){
        super.init(frame: .zero)
        setLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViewModel(viewModel : ContentListViewModel){
        self.viewModel = viewModel
        self.collectionView.dataSource = viewModel
        self.disposeBag = DisposeBag()
        bindViewModel()
    }
    
    func setContentAlphas(value : CGFloat) {
        profileImageView.alpha = value
        descriptionLabel.alpha = value
        idLabel.alpha = value
        shrinkAndExpandDescriptionLabelBtn.alpha = value
        likeBtn.alpha = value
        likeCountLabel.alpha = value
        followBtn.alpha = value
        followCountLabel.alpha = value
        moreBtn.alpha = value
    }
    
    /**
     셀이 재사용되면서 contentOffset이 고정되는 경우가 있어서 초기화를 해주는 함수입니다.
     */
    func setCvAtIndexZero(){
        self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    /**
     PostListViewController에서의 드래깅에따라 포커싱 되는 셀을 설정하는 함수입니다.
     */
    func isCellFocused(isFocused : Bool){
        let visibleIndexPath = collectionView.indexPathsForVisibleItems
        for indexPath in visibleIndexPath {
            if let cell = collectionView.cellForItem(at: indexPath) as? ContentCollectionViewCell {
                if isFocused {
                    cell.play()
                }
                else {
                    cell.pause()
                }
            }
        }
    }
    
    
   
    
    
    private func bindViewModel(){
        //action
        shrinkAndExpandDescriptionLabelBtn.rx.tap
            .scan(false) { lastState, newState in !lastState }
            .subscribe(onNext : { [weak self] isSelected in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.2, delay: 0) {
                    if isSelected {
                        self.shrinkAndExpandDescriptionLabelBtn.transform = CGAffineTransform.init(rotationAngle: .pi)
                        self.descriptionHeightAnchor.constant = self.expandedDescriptionLabelHeight
                    }
                    else {
                        self.shrinkAndExpandDescriptionLabelBtn.transform = .identity
                        self.descriptionHeightAnchor.constant = self.shortendDescriptionLabelHeight
                    }
                }
            })
            .disposed(by: disposeBag)
        
        
        let output = viewModel.transform(input: ContentListViewModel.Input())
        
        output.profileImage
            .drive(profileImageView.rx.image)
            .disposed(by: disposeBag)
        
        output.infulencerId
            .drive(idLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.description
            .drive(onNext : { [weak self] description in
                guard let self = self else { return }
                self.descriptionLabel.text = description
                let maxLine = self.descriptionLabel.calculateMaxLines()
                self.shrinkAndExpandDescriptionLabelBtn.isHidden = !( maxLine > 2)
                
            })
            .disposed(by: disposeBag)
        
        output.followCount
            .drive(followCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.likeCount
            .drive(likeCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.numberOfPages
            .subscribe(onNext : { [weak self] numberOfPages in
                self?.pageController.isHidden = numberOfPages <= 1
                self?.pageController.numberOfPages = numberOfPages
            })
            .disposed(by: disposeBag)
        
    }

}
extension ContentListView {
    private func setLayout(){
        self.addSubview(collectionView)
        self.addSubview(shrinkAndExpandDescriptionLabelBtn)
        self.addSubview(pageController)
        
        let rightInfoStackView = UIStackView(arrangedSubviews: [likeBtn,likeCountLabel,followBtn,followCountLabel,moreBtn])
        self.addSubview(rightInfoStackView)
        rightInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        rightInfoStackView.axis = .vertical
        rightInfoStackView.alignment = .center
        rightInfoStackView.setCustomSpacing(2, after: likeBtn)
        rightInfoStackView.setCustomSpacing(20, after: likeCountLabel)
        rightInfoStackView.setCustomSpacing(2, after: followBtn)
        rightInfoStackView.setCustomSpacing(40, after: followCountLabel)
        
        
        let profileStack = UIStackView(arrangedSubviews: [profileImageView,idLabel])
        profileStack.axis = .horizontal
        profileStack.distribution = .fill
        profileStack.spacing = 5
        
        let bottomStack = UIStackView(arrangedSubviews: [profileStack,descriptionLabel])
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bottomStack)
        bottomStack.axis = .vertical
        bottomStack.spacing = 10
        
    
        
        NSLayoutConstraint.activate([
            descriptionHeightAnchor,
            
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            likeBtn.heightAnchor.constraint(equalToConstant: 20),
            followBtn.heightAnchor.constraint(equalToConstant: 20),
            moreBtn.heightAnchor.constraint(equalToConstant: 20),
            
            rightInfoStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant:  -20),
            rightInfoStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -130),
            rightInfoStackView.widthAnchor.constraint(equalToConstant: 50),
            rightInfoStackView.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
            
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileStack.heightAnchor.constraint(equalToConstant: 40),
            
            bottomStack.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -30),
            bottomStack.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 20),
            bottomStack.trailingAnchor.constraint(equalTo: rightInfoStackView.leadingAnchor,constant: -20),
            bottomStack.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
            
            shrinkAndExpandDescriptionLabelBtn.bottomAnchor.constraint(equalTo: bottomStack.bottomAnchor),
            shrinkAndExpandDescriptionLabelBtn.trailingAnchor.constraint(equalTo: bottomStack.trailingAnchor,constant: 10),
            shrinkAndExpandDescriptionLabelBtn.widthAnchor.constraint(equalToConstant: 20),
            shrinkAndExpandDescriptionLabelBtn.heightAnchor.constraint(equalToConstant: 20),
            
            pageController.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -10),
            pageController.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
    }
}
extension ContentListView : UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int((scrollView.contentOffset.x) / self.frame.width)
        self.pageController.currentPage = pageIndex
        
        self.checkFocusedCell(scrollView)
    }
    
    /**
     좌우로 스크롤시 포커싱이 되는 셀을 판별하는 함수 입니다.
     */
    private func checkFocusedCell(_ scrollView : UIScrollView){
        let centerIndex = Int((scrollView.contentOffset.x + self.frame.width / 2) / self.frame.width)
        let centeredIndexPath = IndexPath(row: centerIndex, section: 0)
        
        let visibleIndexPath = collectionView.indexPathsForVisibleItems
        for indexPath in visibleIndexPath {
            if let cell = collectionView.cellForItem(at: indexPath) as? ContentCollectionViewCell {
                if indexPath == centeredIndexPath {
                    cell.play()
                }
                else {
                    cell.pause()
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ContentCollectionViewCell {
            cell.pause()
        }
    }
    
    
}
