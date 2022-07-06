//
//  SearchViewController.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/5/22.
//

import UIKit

class SearchViewController: UITableViewController{

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cantFindLabel: UILabel!
    
    var searchResults = [BookSearch]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        cantFindLabel.isHidden = true
        searchBar.placeholder = "Search by book title"
    }

    // MARK: - Tableview delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let selectedBook = searchResults[index]
        
        let bookShelfVC = (presentingViewController as! UINavigationController).viewControllers[0] as! BookShelfViewController
        bookShelfVC.addBook(selectedBook)
        
        self.dismiss(animated: true)
    }
    
    // MARK: - Tableview data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResults.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchCell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath) as! BookCell
        
        let book = searchResults[indexPath.row]
        
        searchCell.titleLabel.text = book.title
        searchCell.authorLabel.text = book.author
        
        if let bookCover = book.image {
            searchCell.bookImageView.image = bookCover
        } else {
            searchCell.bookImageView.image = UIImage(systemName: "book.fill")
        }
    
        return searchCell
    }

}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        cantFindLabel.isHidden = true
        
        if let searchString = searchBar.text,
            searchString.count > 0 {
            
            searchResults = []
            tableView.reloadData()
            
           Task {
               do {
                   let bookSearch = try await NetworkRequest.fetchBook(for: searchString)
                   if bookSearch.count > 0 {
                        searchResults = bookSearch
                   } else {
                       searchResults = []
                       self.cantFindLabel.isHidden = false
                   }
                   
                   DispatchQueue.main.async {
                       self.tableView.reloadData()
                   }
                   
               } catch {
                   print(error.localizedDescription)
               }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchBar.placeholder = "Title"
        }
    }
}
