//
//  Extensions.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/12/22.
//

import UIKit

/*
    used by: None at the moment, but can use to change font when exporting
    Source:  https://stackoverflow.com/questions/43723345/nsattributedstring-change-the-font-overall-but-keep-all-other-attributes
 */
extension NSMutableAttributedString {
    func replaceFont(with font: UIFont, color: UIColor? = nil) {
        beginEditing()
        self.enumerateAttribute(
            .font,
            in: NSRange(location: 0, length: self.length)
        ) { (value, range, stop) in

            if let f = value as? UIFont,
              let newFontDescriptor = f.fontDescriptor
                .withFamily(font.familyName)
                .withSymbolicTraits(f.fontDescriptor.symbolicTraits) {

                let newFont = UIFont(
                    descriptor: newFontDescriptor,
                    size: font.pointSize
                )
                removeAttribute(.font, range: range)
                addAttribute(.font, value: newFont, range: range)
                if let color = color {
                    removeAttribute(
                        .foregroundColor,
                        range: range
                    )
                    addAttribute(
                        .foregroundColor,
                        value: color,
                        range: range
                    )
                }
            }
        }
        endEditing()
    }
    
    func replaceWhiteFontColors(){
        beginEditing()
        self.enumerateAttribute(.foregroundColor, in: NSRange(location: 0, length: self.length)) { value, range, stop in
            // need to fix 
            if value as? UIColor == .white {
                removeAttribute(.foregroundColor, range: range)
                addAttribute(.foregroundColor, value: UIColor.black, range: range)
            }
        }
        endEditing()
    }
    
}

extension UIImage {
    
    func resizeImageToScreenSize() -> UIImage? {
        let screenSize = UIScreen.main.bounds.size
        UIGraphicsBeginImageContextWithOptions(screenSize, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: screenSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
