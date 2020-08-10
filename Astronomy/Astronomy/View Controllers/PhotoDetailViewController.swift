//
//  PhotoDetailViewController.swift
//  Astronomy
//
//  Created by patelpra on 8/10/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

import UIKit
import Photos

class PhotoDetailViewController: UIViewController {

    // MARK: - Properties & Outlets
    
    var photoReference: MarsPhotoReference?
    var image: UIImage?
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var cameraLabel: UILabel!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    // MARK: - IBActions & Methods
    
    @IBAction func save(_ sender: Any) {
        guard let image = imageView?.image else { return }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { (success, error) in
            if let error = error {
                NSLog("Error saving photo: \(error)")
                return
            }
            DispatchQueue.main.async {
                self.presentSuccessfulSaveAlert()
            }
        })
    }
    
    private func updateViews() {
        guard isViewLoaded else { return }
        
        if let photoReference = photoReference {
            let dateString = dateFormatter.string(from: photoReference.earthDate)
            detailLabel?.text = "Taken by \(photoReference.camera.roverId) on \(dateString) (Sol \(photoReference.sol))"
            cameraLabel?.text = photoReference.camera.fullName
        }
                
        if let image = image {
            imageView?.image = image
        } else {
            imageView?.image = UIImage(named: "MarsPlaceholder")
        }
    }
    
    private func presentSuccessfulSaveAlert() {
        let alert = UIAlertController(title: "Photo Saved!", message: "The photo has been saved to your Photo Library!", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        
        alert.addAction(okayAction)
        
        present(alert, animated: true, completion: nil)
    }

}
