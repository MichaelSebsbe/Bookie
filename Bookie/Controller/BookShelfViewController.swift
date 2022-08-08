//
//  BookShelfViewController.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/4/22.
//

import UIKit

let emptyShelfImage = UIImage(named: K.emptyShelfArt)!

class BookShelfViewController: UITableViewController {
    
    var books: [Book] {
        didSet{
            refreshTableViewBackground()
        }
    }
    var bookToExport: Book?
    
    required init?(coder: NSCoder) {
        books = []
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedBooks = CoreDataManager.shared.loadItems(with: Book.fetchRequest()){
            self.books = savedBooks
        }
        title = "BookShelf"
        
        tableView.rowHeight = 75
        
        refreshTableViewBackground()
        //tableView.backgroundColor = .white
        // let uiMenuInteractor = UIContextMenuConfiguration
    }
    
    private func refreshTableViewBackground(){
        AnimationManager.refreshTableViewBackground(tableView, collection: books, image: emptyShelfImage)
    }

    private func addInteraction(toCell cell: UITableViewCell) {
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(interaction)
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
        
        if let imageData = books[indexPath.row].imageData,
           let uIImage = UIImage(data: imageData) {
            cell.bookImageView.image = uIImage
        }
        
        addInteraction(toCell: cell)
        
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
                
                CoreDataManager.shared.container.viewContext.delete(bookToDelete)
                self.books.remove(at: indexPath.row)
                
                DispatchQueue.main.async {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    SoundEffect.shared.playSoundEffect(.deletion)
                    CoreDataManager.shared.saveItems()
                }
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            alertController.view.tintColor = AppColors.navigtationBarTint
            
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
        if books.contains(where: { $0.title == bookSearch.title && $0.author == bookSearch.author }) {
            let alertController = UIAlertController(title: "Book already in shelf", message: "'\(bookSearch.title)' is already in your shelf.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            
            alertController.addAction(okAction)
            alertController.view.tintColor = AppColors.navigtationBarTint
            
            self.present(alertController, animated: true)
            
        } else {
        
            let book = Book(context: CoreDataManager.shared.container.viewContext)
            book.title = bookSearch.title
            book.author = bookSearch.author
            book.imageData = bookSearch.image?.jpegData(compressionQuality: 1.0)
            
            books.append(book)
            
            tableView.reloadData()
            
            CoreDataManager.shared.saveItems()
        }
    }
}

extension BookShelfViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        // i have to use this becuase the passed location arg uses the view and no the tableview
        let location = interaction.location(in: self.tableView)
        
        if let indexPath = tableView.indexPathForRow(at: location){
    
            bookToExport = books[indexPath.row]
            
            let exportAction = UICommand(title: "Export as PDF", action: #selector(exportAsPDF))
            let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                let children: [UIMenuElement] = [exportAction]
                return UIMenu(title: "", children: children)
            }
            
            return configuration
        } else {
            return nil
        }
    }
    
    @objc func exportAsPDF(){
        // export
        
        guard (bookToExport?.childChapter!.count)! > 0 else {
            let alertController = UIAlertController(title: "Book has no Chapters", message: "Add chapters within the book to Export as PDF", preferredStyle: .alert)
            
            let cancleAction = UIAlertAction(title: "OK", style: .cancel)
            
            alertController.addAction(cancleAction)
            alertController.view.tintColor = AppColors.navigtationBarTint
            
            present(alertController, animated: true)
            
            return
        }
        
        
        let pdfCreator = PDFCreator(book: bookToExport!)
        let pdfData = pdfCreator.prepareData()
        
        let activityVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        //needs an anchor for iPad
        activityVC.popoverPresentationController?.sourceView = tableView
          
        present(activityVC, animated: true)
        
        // set book to export to nil
        bookToExport = nil
    }
}

