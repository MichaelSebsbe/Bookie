//
//  ChaptersViewController.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/4/22.
//

import UIKit

class ChaptersViewController: UITableViewController {
    
    let coreDataManager = CoreDataManager()
    var book: Book?
    var chapters = [Chapter]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = book?.title
        
        // query load to only show books chapters
        let request = Chapter.fetchRequest()
        request.predicate = NSPredicate(format: "parentBook.title MATCHES %@", book!.title!)
        if let savedChapters = coreDataManager.loadItems(with: request){
            chapters = savedChapters
        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add Chapter", message: "Enter Chapter's Title", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = "Chapter \(self.chapters.count + 1): "
            textField.spellCheckingType = .yes
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            
            if let title = alertController.textFields?.first?.text,
               title.count > 0 {
                let chapter = Chapter(context: self.coreDataManager.container.viewContext)
                chapter.parentBook = self.book
                chapter.title = title
                chapter.lastModified = Date.now
                
                self.chapters.append(chapter)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                self.coreDataManager.saveItems()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        
        self.present(alertController, animated: true)
        
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chapters.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChapterCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        let chapter = chapters[indexPath.row]
        
        content.text = chapter.title
        content.secondaryText = "Last modified \(chapter.lastModified?.formatted() ?? "NA")"
        cell.contentConfiguration = content
        
        return cell
    }
    
    //MARK: Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.segueIDToChapter, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let noteVC = segue.destination as! NoteViewController
        let index = tableView.indexPathForSelectedRow?.row
        noteVC.chapter = chapters[index!]
    }
}
