//
//  AnimationManager.swift
//  Bookie
//
//  Created by Michael Sebsbe on 8/5/22.
//

import UIKit

struct AnimationManager {
    static func refreshTableViewBackground(_ tableView: UITableView, collection: [Any], image: UIImage){
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        
        if collection.isEmpty{
            tableView.backgroundView = imageView
            tableView.backgroundView?.alpha = 0
            UIView.animate(withDuration: 1.5) {
                tableView.backgroundView?.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 1.5) {
                tableView.backgroundView?.alpha = 0
            }
        }
    }
}
