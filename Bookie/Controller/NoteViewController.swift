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
    
    //format options outlets
    @IBOutlet weak var formatOptionsView: UIView!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var fontSegmentedControl: UISegmentedControl!
    
    //for hiding the format options
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        textView.keyboardDismissMode = .interactive
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35)
        textView.font = AppearanceManager.shared.font
        textView.textAlignment = .justified
        
        chapterTitle.font = textView.font
        chapterTitle.text = chapter?.title
        loadNote()
        
        makeSelfKeyboardObserver() //minor adjuastment to the text view when keyboard shows and hides (on top of IQKeyboard Manager)
       
        setupFormatOptionsView()
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector(hideFormatOptions))
        tapGestureRecognizer.delegate = self
        textView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      SoundEffect.shared.playSoundEffect(.bookClose)
    }

    @IBAction func formatButtonTapped(_ sender: UIBarButtonItem) {
        formatOptionsView.isHidden.toggle()
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
        request.predicate = NSPredicate(format: "parentChapter.title MATCHES %@ && parentChapter.parentBook.title MATCHES %@",argumentArray: [chapter!.title!, chapter!.parentBook!.title!] )
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
            //textView.frame.origin.y -= 30 // a bit sketchy but good for now
            formatOptionsView.isHidden = true
       // }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        //if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            //let keyboardRectangle = keyboardFrame.cgRectValue
            //let keyboardHeight = keyboardRectangle.height
            //textView.frame.origin.y += 30 // a bit sketchy but good for now
        //}
    }
    
    // MARK: FormatOptionsMethods
    private func setupFormatOptionsView(){
        formatOptionsView.isHidden = true
        formatOptionsView.layer.cornerRadius = 10
        brightnessSlider.value = Float(UIScreen.main.brightness)
        fontSegmentedControl.selectedSegmentIndex = AppearanceManager.shared.indexOfSelecedFont
    }
    
    // MARK: FormatOptions IBActions
    
    @IBAction func brightnessSliderValueChanged(_ sender: UISlider) {
        UIScreen.main.brightness = CGFloat(sender.value)
    }
    @IBAction func decreaseFontButtonTapped(_ sender: UIButton) {
        AppearanceManager.shared.decreaseFont()
        textView.font = AppearanceManager.shared.font
        chapterTitle.font = textView.font
    }
    
    @IBAction func increaseFontButtonTapped(_ sender: UIButton) {
        AppearanceManager.shared.increaseFont()
        textView.font = AppearanceManager.shared.font
        chapterTitle.font = textView.font
    }
    
    @IBAction func fontChosen(_ sender: UISegmentedControl) {
        var fontName: AppearanceManager.Fonts!
        
        switch sender.selectedSegmentIndex {
        case 0:
            fontName = .defaultFont
        case 1:
            fontName = .typeWriter
        case 2:
            fontName = .avenir
        default:
            print("Segement 3 needs implementation")
        }
        
        AppearanceManager.shared.changeFont(font: fontName)
        textView.font = AppearanceManager.shared.font
        chapterTitle.font = AppearanceManager.shared.font
    }
}

extension NoteViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func hideFormatOptions(){
        formatOptionsView.isHidden = true
    }
}
