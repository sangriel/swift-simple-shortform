//
//  PagingErrorView.swift
//  Marble
//
//  Created by sangmin han on 2023/04/01.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class PagingErrorView : UIView {
    
    
    let textLabel : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textColor = .white
        lb.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lb.textAlignment = .center
        lb.numberOfLines = 2
        lb.text = "데이터를 불러오는 도중 오류가 발생했습니다.\n 다시 시도해 주세요"
        return lb
    }()
    
    let closeBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("닫기", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.backgroundColor = .black
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .init(white: 0, alpha: 0.4)
        setLayout()
        
        bindView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func bindView(){
        closeBtn.rx.tap
            .subscribe(onNext : { [weak self] in
                self?.isHidden = true
            })
            .disposed(by: disposeBag)
    }
    
    
}
extension PagingErrorView {
    private func setLayout(){
        self.addSubview(textLabel)
        self.addSubview(closeBtn)
        
        NSLayoutConstraint.activate([
            textLabel.bottomAnchor.constraint(equalTo: self.centerYAnchor,constant: -10),
            textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            textLabel.widthAnchor.constraint(equalToConstant: 300),
            textLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 100),
            
            closeBtn.topAnchor.constraint(equalTo: self.centerYAnchor,constant: 10),
            closeBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            closeBtn.widthAnchor.constraint(equalToConstant: 100),
            closeBtn.heightAnchor.constraint(equalToConstant: 40)
            
        ])
        
        
    }
}
