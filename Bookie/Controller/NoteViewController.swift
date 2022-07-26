//
//  NoteViewController.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/4/22.
//

import UIKit
import NotesTextView

class NoteViewController: UIViewController, UITextViewDelegate {
    
    let coreDataManager = CoreDataManager()
    var note: Note?
    var chapter: Chapter?
    
    let textView = NotesTextView()
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = chapter?.title
        setupNotesTextView()
        loadNote()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SoundEffect.shared.playSoundEffect(.bookClose)
        saveNote()
    }
    
    @IBAction func shareBarButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    // MARK: TextView Delegate Methods
    
    func textViewDidChange(_ textView: UITextView) {
        saveNote()
    }

    
    // MARK: NotesTextView Setup
    func setupNotesTextView() {
        view.addSubview(textView)
        
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        // to adjust the content insets based on keyboard height
        textView.shouldAdjustInsetBasedOnKeyboardHeight = true
        
        // to support iPad
        textView.hostingViewController = self
        
    }
    
    // MARK: Note-Data Manipulation
    
    func saveNote() {
        if let note = note {
            note.setValue(NSMutableAttributedString(attributedString: textView.attributedText), forKey: "attributedText")
        } else {
            note = Note(context: coreDataManager.container.viewContext)
            note?.parentChapter = chapter
            note?.attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        }
        note?.parentChapter?.lastModified = Date.now //might need a singleton
        coreDataManager.saveItems()
    }
    
    func loadNote() {
        let request = Note.fetchRequest()
        request.predicate = NSPredicate(format: "parentChapter.title MATCHES %@ && parentChapter.parentBook.title MATCHES %@",argumentArray: [chapter!.title!, chapter!.parentBook!.title!] )
        if let savedNote = coreDataManager.loadItems(with: request) {
            note = savedNote.first
            
            if let attributedString = note?.attributedText {
                textView.attributedText = attributedString
            }
        }
    }
}
    




