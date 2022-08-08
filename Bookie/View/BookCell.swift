//
//  SearchCell.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/5/22.
//

import UIKit

class BookCell: UITableViewCell {

    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        authorLabel.textColor = AppColors.cellSecondaryColor
        bookImageView.image = UIImage(systemName: "book")?.withRenderingMode(.alwaysTemplate)
        bookImageView.tintColor = AppColors.navigtationBarTint
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
