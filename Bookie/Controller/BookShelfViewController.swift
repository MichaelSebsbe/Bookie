//
//  BookShelfViewController.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/4/22.
//

import UIKit

class BookShelfViewController: UITableViewController {

    var books = [Book]()
    let coreDataMananger = CoreDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedBooks = coreDataMananger.loadItems(with: Book.fetchRequest()){
            self.books = savedBooks
        }
     }

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add Book", message: "Insert Book Titile", preferredStyle: .alert)
        
        alertController.addTextField()
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            if let booktitle = alertController.textFields?.first?.text,
               booktitle.count > 0 {
                let book = Book(context: self.coreDataMananger.container.viewContext)
                book.title = booktitle
                
                self.books.append(book)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                self.coreDataMananger.saveItems()
                // save
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancle", style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
        
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return books.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShelfCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = books[indexPath.row].title

        cell.contentConfiguration = content
        
        return cell
    }

    // MARK: -Tabel View delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToChapters", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let chaptersVC = segue.destination as! ChaptersViewController
        let index = tableView.indexPathForSelectedRow?.row
        chaptersVC.book = books[index!]
        
    }
    
}
