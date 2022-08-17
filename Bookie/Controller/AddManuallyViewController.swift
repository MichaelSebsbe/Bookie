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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
    }
    
    
    func setupUI() {
        addCoverButton.tintColor = AppColors.cellSecondaryColor
        doneButton.tintColor = AppColors.cellSecondaryColor
        coverImageView.layer.cornerRadius = 5
        coverImageView.image = UIImage(systemName: "book")
        coverImageView.tintColor = AppColors.cellSecondaryColor
        doneButton.isEnabled = false
        cancelButton.tintColor = AppColors.cellSecondaryColor
        
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
        bookShelfVC.addBook(book)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func titleTextFieldNextTapped(_ sender: UITextField) {
        authorTextField.becomeFirstResponder()
        
        if sender.hasText && authorTextField.hasText {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
    }
    
    @IBAction func authorTextFieldDoneTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
        
        if sender.hasText && titleTextField.hasText {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
    }
}

extension AddManuallyViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let photo = info[.originalImage] as? UIImage {
            
            let frameSize = CGSize(width: 200, height: 300)
            let croppedPhoto = photo.crop(to: frameSize)
            
            coverImageView.image = croppedPhoto
            coverImageView.contentMode = .scaleAspectFit
            
            addCoverButton.setTitle("Change Photo", for: .normal)
            
            picker.dismiss(animated: true)
        }
    }
}
