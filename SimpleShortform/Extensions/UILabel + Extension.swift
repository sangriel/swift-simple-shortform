//
//  UILabel + Extension.swift
//  Marble
//
//  Created by sangmin han on 2023/04/01.
//

import Foundation
import UIKit


extension UILabel {
    func calculateMaxLines() -> (Int) {
        self.layoutIfNeeded()
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return (linesRoundedUp)
    }
}
