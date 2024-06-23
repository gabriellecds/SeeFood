//
//  ViewController.swift
//  SeeFood
//
//  Created by Gabrielle Oliveira on 21/06/24.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage into CIImage.")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage){
        
        do {
            let configuration = MLModelConfiguration()
            
            let model = try VNCoreMLModel(for: Inceptionv3(configuration: configuration).model)
            
            let request = VNCoreMLRequest(model: model) { (request, error) in
                guard let results = request.results as? [VNClassificationObservation] else {
                    fatalError("Model failed to process image.")
                }
                
                if let firstResult = results.first {
                    DispatchQueue.main.async {
                        if firstResult.identifier.contains("hotdog") {
                            self.navigationItem.title = "HotDog!"
                        } else {
                            self.navigationItem.title = "Not HotDog!"
                        }
                    }
                }
            }

            let handler = VNImageRequestHandler(ciImage: image)
            
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
            
        } catch {
            print("Erro ao inicializar o modelo ou ao processar a imagem: \(error)")
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

