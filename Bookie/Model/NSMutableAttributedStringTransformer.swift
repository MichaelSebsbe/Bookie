//
//  NSAttributedStringTransformer.swift
//  Bookie
//
//  Created by Michael Sebsbe on 8/12/22.
//

import Foundation

class NSMutableAttributedStringTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        guard let mutableAttributedString = value as? NSMutableAttributedString else{return nil}
        
        do{
            let data = try NSKeyedArchiver.archivedData(withRootObject: mutableAttributedString, requiringSecureCoding: true)
            return data
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        
        do{
            let mutableAttributedString = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSMutableAttributedString.self, from: data)
            return mutableAttributedString
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
