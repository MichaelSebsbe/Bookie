//
//  BookShelfViewController.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/4/22.
//

import UIKit


class BookShelfViewController: UITableViewController {
    
    var books = [Book]()
    let coreDataManager = CoreDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedBooks = coreDataManager.loadItems(with: Book.fetchRequest()){
            self.books = savedBooks
        }
        title = "BookShelf"
        tableView.rowHeight = 75
    }
    
    // MARK: - Tableview data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return books.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.bookCellID, for: indexPath) as! BookCell
        
        var content = cell.defaultContentConfiguration()
        content.text = books[indexPath.row].title
        
        cell.titleLabel.text = books[indexPath.row].title
        cell.authorLabel.text = books[indexPath.row].author
        cell.authorLabel.textColor = .gray
        if let imageData = books[indexPath.row].imageData,
           let uIImage = UIImage(data: imageData) {
            cell.bookImageView.image = uIImage
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "Delete '\(books[indexPath.row].title ?? "Book")'?", message: "All chapters and Notes within the chapters will also be deleted", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                let bookToDelete = self.books[indexPath.row]
                //let deleteRequest = books[indexPath.row]
                
                self.coreDataManager.container.viewContext.delete(bookToDelete)
                self.books.remove(at: indexPath.row)
                
                DispatchQueue.main.async {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    SoundEffect.shared.playSoundEffect(.deletion)
                    self.coreDataManager.saveItems()
                }
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true)
            
        }
    }
    
    // MARK: -Tableview delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.segueIDToChapter, sender: self)
        SoundEffect.shared.playSoundEffect(.pageFlip)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let chaptersVC = segue.destination as? ChaptersViewController {
            let index = tableView.indexPathForSelectedRow?.row
            chaptersVC.book = books[index!]
        }
    }
    
    func addBook(_ bookSearch: BookSearch){
        let book = Book(context: coreDataManager.container.viewContext)
        book.title = bookSearch.title
        book.author = bookSearch.author
        book.imageData = bookSearch.image?.jpegData(compressionQuality: 1.0)
        
        books.append(book)
        
        tableView.reloadData()
        
        coreDataManager.saveItems()
    }
    

}
