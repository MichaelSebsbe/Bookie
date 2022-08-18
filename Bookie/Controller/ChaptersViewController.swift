//
//  ChaptersViewController.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/4/22.
//

import UIKit

let emptyChaptersImage = UIImage(named: K.emptyChaptersArt)!

class ChaptersViewController: UITableViewController {
    
    var book: Book?
    var chapters: [Chapter] {
        didSet{
            refreshTableViewBackground()
        }
    }
    
    required init?(coder: NSCoder) {
        chapters = []
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = book?.title
        
        // query load to only show books chapters
        let request = Chapter.fetchRequest()
        request.predicate = NSPredicate(format: "parentBook.title MATCHES %@ && parentBook.author MATCHES %@ ", argumentArray: [book!.title!, book!.author!])
        if let savedChapters = CoreDataManager.shared.loadItems(with: request){
            chapters = savedChapters
        }
        
        refreshTableViewBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // because date modified will change after note is edited
        tableView.reloadData()
        tableView.rowHeight = 90
    }
    
    private func refreshTableViewBackground(){
        AnimationManager.refreshTableViewBackground(tableView, collection: chapters, image: emptyChaptersImage)
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add Chapter", message: "Enter Chapter's Title", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = "Chapter \(self.chapters.count + 1): "
            textField.spellCheckingType = .yes
            textField.autocapitalizationType = .words
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            
            if let title = alertController.textFields?.first?.text,
               title.count > 0 {

                if self.chapters.contains(where: {$0.title == title
                }) || title.contains(where:{ $0 == "\\"})
                {
                    let texfield = alertController.textFields?.first
                    texfield?.placeholder = "Choose a different Name"
                    texfield?.text = ""
                    self.present(alertController, animated: true)
                    return
                }
                
                
                let chapter = Chapter(context: CoreDataManager.shared.container.viewContext)
                chapter.parentBook = self.book
                chapter.title = title
                chapter.lastModified = Date.now
                
                self.chapters.append(chapter)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                CoreDataManager.shared.saveItems()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        alertController.view.tintColor = AppColors.navigtationBarTint
        
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
        content.secondaryAttributedText = NSAttributedString(string: "Last modified \(chapter.lastModified?.formatted() ?? "NA")", attributes: [NSAttributedString.Key.foregroundColor : AppColors.cellSecondaryColor])
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alertController = UIAlertController(title: "Delete '\(chapters[indexPath.row].title ?? "")'?", message: "Note within the chapter will be deleted", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                let chapterToDelete = self.chapters[indexPath.row]
                //let deleteRequest = books[indexPath.row]
                
                CoreDataManager.shared.container.viewContext.delete(chapterToDelete)
                self.chapters.remove(at: indexPath.row)
                
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
    
    //MARK: Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.segueIDToNotes, sender: self)
        SoundEffect.shared.playSoundEffect(.pageFlip)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let noteVC = segue.destination as! NoteViewController
        let index = tableView.indexPathForSelectedRow?.row
        noteVC.chapter = chapters[index!]
    }
}
