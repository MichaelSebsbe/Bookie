//
//  Constants.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/5/22.
//

import Foundation
import ChameleonFramework
import UIKit

struct K {
    static let bookCellID = "bookCell"
    static let chapterCellID = "chapterCell"
    static let segueIDToChapter = "goToChapters"
    static let segueIDToNotes = "goToNotes"
    static let emptyShelfArt = "EmptyShelf"
    static let emptyChaptersArt = "EmptyChapters"
    static let searchArt = "SearchArt"
    static let appLogo = "Logo"
}

struct AppColors {
    //static let cellPrimaryTextColor: UIColor = .black
    static let cellSecondaryColor = FlatMintDark()
    //static let backgroungColor: UIColor = .white
    static let navigtationBarTint = FlatMint()
}
