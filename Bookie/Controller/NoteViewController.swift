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
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: textView.font!]
        navigationItem.title = chapter?.title
        
        loadNote()
        
        makeSelfKeyboardObserver() //minor adjuastment to the text view when keyboard shows and hides (on top of IQKeyboard Manager)
        
        setupFormatOptionsView()
        
        makeSelfBrightnessObserver()
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector(hideFormatOptions))
        tapGestureRecognizer.delegate = self
        textView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SoundEffect.shared.playSoundEffect(.bookClose)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)]
    }
    
    @IBAction func formatButtonTapped(_ sender: UIBarButtonItem) {
        formatOptionsView.isHidden.toggle()
    }
    // MARK: TextView Delegate Methods
    
    func textViewDidChange(_ textView: UITextView) {
        saveNote()
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
                let mutableString = NSMutableAttributedString(attributedString:attributedString)
                mutableString.replaceFont(with: AppearanceManager.shared.font)
                textView.attributedText = mutableString
            }
        }
    }
    
    // MARK: NotificationCenter observer methods
    
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
    
    fileprivate func makeSelfBrightnessObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(brightnessDidChange),
            name: UIScreen.brightnessDidChangeNotification,
            object: nil
        )
    }
    
    @objc func brightnessDidChange(){
        brightnessSlider.value = Float(UIScreen.main.brightness)
    }
    
    
    // MARK: FormatOptionsMethods
    private func setupFormatOptionsView(){
        formatOptionsView.isHidden = true
        formatOptionsView.layer.cornerRadius = 10
        fontSegmentedControl.selectedSegmentIndex = AppearanceManager.shared.indexOfSelecedFont
    }
    
    // MARK: FormatOptions IBActions
    
    @IBAction func brightnessSliderValueChanged(_ sender: UISlider) {
        UIScreen.main.brightness = CGFloat(sender.value)
    }
    @IBAction func decreaseFontButtonTapped(_ sender: UIButton) {
        AppearanceManager.shared.decreaseFont()
        updateFonts()
    }
    
    @IBAction func increaseFontButtonTapped(_ sender: UIButton) {
        AppearanceManager.shared.increaseFont()
        updateFonts()
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
        updateFonts()
    }
    
    func updateFonts() {
        let font  = AppearanceManager.shared.font
        
        let mutableString = NSMutableAttributedString(attributedString: textView.attributedText)
        mutableString.replaceFont(with: font!)
        
        textView.attributedText = mutableString
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font!]
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




