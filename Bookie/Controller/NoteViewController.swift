//
//  NoteViewController.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/4/22.
//

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate {
    
    let coreDataManager = CoreDataManager()
    var note: Note?
    var chapter: Chapter?
    
    @IBOutlet weak var chapterTitle: UILabel!
    @IBOutlet weak var textView: UITextView!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        chapterTitle.text = chapter?.title
        loadNote()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      SoundEffect.shared.playSoundEffect(.bookClose)
    }

    // MARK: TextView Delegate Methods
    
    func textViewDidChange(_ textView: UITextView) {
        saveNote()
    }
    
    // MARK: Note-Data Manipulation
    // Made it a func incase I want to change when I save the note
    func saveNote() {
        if let note = note {
            note.setValue(textView.text, forKey: "text")
        } else {
            note = Note(context: coreDataManager.container.viewContext)
            note?.parentChapter = chapter
            note?.text = textView.text
        }
        note?.parentChapter?.lastModified = Date.now //might need a singleton
        
        coreDataManager.saveItems()
    }
    
    func loadNote() {
        let request = Note.fetchRequest()
        request.predicate = NSPredicate(format: "parentChapter.title MATCHES %@", chapter!.title!)
        if let savedNote = coreDataManager.loadItems(with: request) {
            note = savedNote.first
            textView.text = note?.text
        }
    }
}
