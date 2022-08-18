//
//  AddManuallyViewController.swift
//  Bookie
//
//  Created by Michael Sebsbe on 8/12/22.
//

import UIKit

class AddManuallyViewController: UIViewController {

    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var addCoverButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var book: Book?
    var bookIndexOnShelf: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    
    func setupUI() {
        addCoverButton.tintColor = AppColors.cellSecondaryColor
        doneButton.tintColor = AppColors.cellSecondaryColor
        
        titleTextField.tintColor = AppColors.cellSecondaryColor
        authorTextField.tintColor = AppColors.cellSecondaryColor
        
        coverImageView.layer.cornerRadius = 5
        coverImageView.image = UIImage(systemName: "book.closed.fill")
        coverImageView.tintColor = AppColors.cellSecondaryColor
        coverImageView.contentMode = .scaleAspectFit
        
        cancelButton.tintColor = AppColors.cellSecondaryColor
        
        if let book = book {
            titleTextField.text = book.title
            authorTextField.text = book.author
            
            if let imageData = book.imageData {
                coverImageView.image = UIImage(data:imageData)
                addCoverButton.setTitle("Change Cover", for: .normal)
            }
        } else {
            doneButton.isEnabled = false
        }
    }
    
    @IBAction func addCoverButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Add your book cover", message: nil ,preferredStyle: .actionSheet)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        alertController.popoverPresentationController?.sourceView = sender as! UIButton
        
        let libraryAction = UIAlertAction(title: "Photo's Library", style: .default) { [weak self] _ in
            
            imagePicker.sourceType = .photoLibrary
            self?.present(imagePicker, animated: true)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self]_ in
                imagePicker.sourceType = .camera
                self?.present(imagePicker, animated: true)
            }
            
            alertController.addAction(cameraAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        
        alertController.view.tintColor = AppColors.navigtationBarTint
        
        present(alertController, animated: true)
    }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        
        let bookShelfVC = (presentingViewController as! UINavigationController).viewControllers[0] as! BookShelfViewController
        
        let book = BookSearch(title: titleTextField.text!, author: authorTextField.text, isbn: nil, image: coverImageView.image)
        
        self.dismiss(animated: true)
        
        //if user was editing a book
        if let indexPath = bookIndexOnShelf{
            bookShelfVC.addBook(book, at: indexPath)
        }
        // if user was adding book manually
        else {
            bookShelfVC.addBook(book)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func textFieldsDidChange(_ sender: UITextField) {
       updateDoneButton()
    }
    
    private func updateDoneButton(){
        if titleTextField.hasText && authorTextField.hasText {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
    }
    
    @IBAction func titleTextFieldNextTapped(_ sender: UITextField) {
        authorTextField.becomeFirstResponder()
    }
    
    @IBAction func authorTextFieldDoneTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
}

extension AddManuallyViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let photo = info[.originalImage] as? UIImage {
            coverImageView.image = photo
            addCoverButton.setTitle("Change Photo", for: .normal)
            
            picker.dismiss(animated: true)
        }
    }
}
