//
//  AddEditConsoleViewController.swift
//  My Games
//
//  Created by Aluno on 21/07/18.
//  Copyright © 2018 CESAR School. All rights reserved.
//

import UIKit
import Photos

class AddEditConsoleViewController: UIViewController {
    
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var btIcon: UIButton!
    @IBOutlet weak var btAdd: UIButton!
    @IBOutlet weak var tvName: UITextField!
    
    var console: Console!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareDataLayout()
    }
    
    func prepareDataLayout() {
        if console != nil {
            title = "Editar console"
            btAdd.setTitle("ALTERAR", for: .normal)
            tvName.text = console.name
            
            ivIcon.image = console.icon as? UIImage
            
            if console.icon != nil {
                btIcon.setTitle(nil, for: .normal)
            }
        }
    }
    
    @IBAction func AddEditIcon(_ sender: UIButton) {
        // para adicionar uma imagem da biblioteca
        let alert = UIAlertController(title: "Selecinoar ícone", message: "De onde você quer escolher o ícone?", preferredStyle: .actionSheet)
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default, handler: {(action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        })
        alert.addAction(libraryAction)
        
        let photosAction = UIAlertAction(title: "Album de fotos", style: .default, handler: {(action: UIAlertAction) in
            self.selectPicture(sourceType: .savedPhotosAlbum)
        })
        alert.addAction(photosAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func chooseImageFromLibrary(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.navigationBar.tintColor = UIColor(named: "main")
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        
        //Photos
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    
                    self.chooseImageFromLibrary(sourceType: sourceType)
                    
                } else {
                    
                    print("unauthorized -- TODO message")
                }
            })
        } else if photos == .authorized {
            
            self.chooseImageFromLibrary(sourceType: sourceType)
        }
    }

    @IBAction func addConsoleClick(_ sender: UIButton) {
        // acao salvar novo ou editar existente
        if console == nil {
            console = Console(context: context)
        }
        
        console.name = tvName.text
        console.icon = ivIcon.image
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        // Back na navigation
        navigationController?.popViewController(animated: true)
    }
 
}

extension AddEditConsoleViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // tip. implementando os 2 protocols o evento sera notificando apos user selecionar a imagem
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            // ImageView won't update with new image
            // bug fixed: https://stackoverflow.com/questions/42703795/imageview-wont-update-with-new-image
            DispatchQueue.main.async {
                self.ivIcon.image = pickedImage
                self.ivIcon.setNeedsDisplay()
                self.btIcon.setTitle(nil, for: .normal)
                self.btIcon.setNeedsDisplay()
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}
