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
    @IBOutlet weak var formatButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        textView.keyboardDismissMode = .interactive
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35)
        chapterTitle.font = textView.font
        chapterTitle.text = chapter?.title
        loadNote()
        
        makeSelfKeyboardObserver() //minor adjuastment to the text view when keyboard shows and hides (on top of IQKeyboard Manager)
       
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
    
    // MARK: Keyboard Adjustment Methods
    
    fileprivate func makeSelfKeyboardObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        //if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            //let keyboardRectangle = keyboardFrame.cgRectValue
            //let keyboardHeight = keyboardRectangle.height
            textView.frame.origin.y -= 30 // a bit sketchy but good for now
       // }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        //if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            //let keyboardRectangle = keyboardFrame.cgRectValue
            //let keyboardHeight = keyboardRectangle.height
            textView.frame.origin.y += 30 // a bit sketchy but good for now
        //}
    }
    
}
