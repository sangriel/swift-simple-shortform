//
//  PostCollectionViewCell.swift
//  Marble
//
//  Created by sangmin han on 2023/04/01.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class PostCollectionViewCell : UICollectionViewCell {
    
    
    static let cellId = "postcollectionviewcellId"
    
    private let view : ContentListView = {
        let view = ContentListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame : CGRect){
        super.init(frame: frame)
        setLayout()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        view.setCvAtIndexZero()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViewModel(viewModel: ContentListViewModel){
        self.view.setViewModel(viewModel: viewModel)
    }
    
    func setContentAlphas(value : CGFloat){
        self.view.setContentAlphas(value: value)
    }
    
    func isCellFocused(isFocused : Bool){
        self.view.isCellFocused(isFocused: isFocused)
    }
    
}
extension PostCollectionViewCell {
    private func setLayout(){
        self.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
