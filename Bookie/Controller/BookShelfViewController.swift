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

//    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
//        let alertController = UIAlertController(title: "Add Book", message: "Insert Book Titile", preferredStyle: .alert)
//        
//        alertController.addTextField()
//        
//        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
//            if let booktitle = alertController.textFields?.first?.text,
//               booktitle.count > 0 {
//                let book = Book(context: self.coreDataMananger.container.viewContext)
//                book.title = booktitle
//                
//                self.books.append(book)
//                
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//                
//                self.coreDataMananger.saveItems()
//                // save
//            }
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancle", style: .cancel)
//        
//        alertController.addAction(addAction)
//        alertController.addAction(cancelAction)
//        
//        self.present(alertController, animated: true)
//        
//    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return books.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.bookCellID, for: indexPath) as! BookCell

        var content = cell.defaultContentConfiguration()
        content.text = books[indexPath.row].title

        cell.titleLabel.text = books[indexPath.row].title
        cell.authorLabel.text = books[indexPath.row].author
        if let imageData = books[indexPath.row].imageData,
           let uIImage = UIImage(data: imageData) {
            cell.bookImageView.image = uIImage
        }
        
        return cell
    }

    // MARK: -Table View delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.segueIDToChapter, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let chaptersVC = segue.destination as? ChaptersViewController {
            let index = tableView.indexPathForSelectedRow?.row
            chaptersVC.book = books[index!]
        }
    }
    
    func addBook(_ bookSearch: BookSearch){
        let book = Book(context: coreDataMananger.container.viewContext)
        book.title = bookSearch.title
        book.author = bookSearch.author
        book.imageData = bookSearch.image?.jpegData(compressionQuality: 1.0)
        
        books.append(book)
        
        tableView.reloadData()
        
        coreDataMananger.saveItems()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
