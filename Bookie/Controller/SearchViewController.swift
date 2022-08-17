//
//  SearchViewController.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/5/22.
//

import UIKit

let searchImage = UIImage(named: K.searchArt)!

class SearchViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cantFindLabel: UILabel!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    var searchResults: [BookSearch] {
        didSet{
            refreshTableViewBackground()
        }
    }
    
    required init?(coder: NSCoder) {
        searchResults = []
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        cantFindLabel.textColor = AppColors.cellSecondaryColor
        cantFindLabel.isHidden = true
        searchBar.placeholder = "Search by book title"
        searchBar.tintColor = AppColors.navigtationBarTint
        
        tabBarController?.tabBar.tintColor = AppColors.navigtationBarTint
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshTableViewBackground()
    }
    
    @objc func dismissKeyboard(){
        searchBar.resignFirstResponder()
    }
    
    private func refreshTableViewBackground(){
        AnimationManager.refreshTableViewBackground(tableView, collection: searchResults, image: searchImage)
    }
    
    // MARK: - Tableview delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        var selectedBook = searchResults[index]
        selectedBook.image = tableView.cellForRow(at: indexPath)?.imageView?.image
        
        let bookShelfVC = (presentingViewController as! UINavigationController).viewControllers[0] as! BookShelfViewController
        
        self.dismiss(animated: true)
        
        bookShelfVC.addBook(selectedBook)
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
        
        if let isbn = book.isbn {
            Task{
                do {
                    let coverImage = try await NetworkRequest.fetchImage(for: isbn) ?? UIImage(systemName: "book")?.withRenderingMode(.alwaysTemplate)
                    coverImage?.withTintColor(AppColors.navigtationBarTint)
                    
                    searchCell.bookImageView.image = coverImage
                    // set the image in the data
                    
                }
                catch {print(error.localizedDescription)}
            }
        }
        
        return searchCell
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        cantFindLabel.isHidden = true
        view.endEditing(true)
        view.removeGestureRecognizer(tapGestureRecognizer)
        
        if let searchString = searchBar.text,
           searchString.count > 0 {
            
            searchResults = []
            tableView.reloadData()
            
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = AppColors.navigtationBarTint
            spinner.startAnimating()
            tableView.backgroundView = spinner
            
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
                        spinner.stopAnimating()
                        self.tableView.backgroundView = nil
                    }
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchBar.placeholder = "Search Book by Title"
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true)
    }
}
