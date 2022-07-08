//
//  AppearanceManager.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/7/22.
//

import Foundation
import UIKit

class AppearanceManager {
    
    enum Fonts: String, CaseIterable {
        case defaultFont = "Baskerville"
        case typeWriter = "American Typewriter"
        case avenir = "Avenir Book"
    }
    
    static let shared = AppearanceManager()
    
    var font: UIFont!
    var fontSize: CGFloat! {
        didSet{
            UserDefaults.standard.set(Float(fontSize), forKey: "fontSize")
        }
    }
    private var fontName: String! {
        didSet{
            UserDefaults.standard.set(fontName, forKey: "fontName")
        }
    }
    var indexOfSelecedFont: Int = 0
    
    
    init(){
        if let fontSize = UserDefaults.standard.object(forKey: "fontSize") as? Float,
           let fontName = UserDefaults.standard.object(forKey: "fontName") as? String {
            self.fontSize = CGFloat(fontSize)
            self.fontName = fontName
        } else {
            fontSize = 14
            UserDefaults.standard.set(Float(fontSize), forKey: "fontSize")
            fontName = Fonts.defaultFont.rawValue
            UserDefaults.standard.set(fontName, forKey: "fontName")
        }
        let font = Fonts.allCases.first { $0.rawValue == fontName}
        changeFont(font: font!)
    }
    
    func changeFont(font fontName: Fonts){
        switch fontName {
        case .defaultFont:
            indexOfSelecedFont = 0
        case .typeWriter:
            indexOfSelecedFont = 1
        case .avenir:
            indexOfSelecedFont = 2
        }
        self.fontName = fontName.rawValue
        font = UIFont(name: self.fontName, size: fontSize)
    }
   
    func increaseFont(){
        fontSize += 2
        font = UIFont(name: fontName, size: fontSize)
    }
    func decreaseFont(){
        fontSize -= 2
        font = UIFont(name: fontName, size: fontSize)
    }
}
