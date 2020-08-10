//
//  PhotosCollectionViewController.swift
//  Astronomy
//
//  Created by patelpra on 8/10/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ImageCell"

class PhotosCollectionViewController: UICollectionViewController {
    
        // MARK: - Properties
        
        private let client = MarsRoverClient()
        private let photoFetchQueue = OperationQueue()
        private var operations = [Int: Operation]()
        private let cache = Cache<UIImage>()
        
        private let solLabel = UILabel()
        private let minimumCellSpacing: CGFloat = 10.0
        
        private var roverInfo: MarsRover? {
            didSet {
                // index 654 has 1 photo; index 53 has 4 photos; index 81 has 9 photos; index 4 has 26 photos
                solDescription = roverInfo?.solDescriptions[0]
            }
        }
        
        private var solDescription: SolDescription? {
            didSet {
                if let rover = roverInfo,
                    let sol = solDescription?.sol {
                    photoReferences = []
                    client.fetchPhotos(from: rover, onSol: sol) { photoRefs, error in
                        if let error = error { NSLog("Error fetching photos for \(rover.name) on sol \(sol): \(error)"); return }
                        self.photoReferences = photoRefs ?? []
                        self.updateTitleView()
                    }
                }
            }
        }
        
        private var photoReferences = [MarsPhotoReference]() {
            didSet {
                cache.clear()
                self.collectionView?.reloadData()
            }
        }
        
        // MARK: - View Controller Lifecycle
        
        override func viewDidLoad() {
            super.viewDidLoad()

            let roverName = "curiosity"
            
            client.fetchMarsRover(withName: roverName) { rover, error in
                if let error = error {
                    NSLog("Error fetching info for \(roverName): \(error)")
                    return
                }
                
                self.roverInfo = rover
            }
                    
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action:  #selector(refresh), for: .valueChanged)
            collectionView.refreshControl = refreshControl
            
            configureTitleView()
            updateTitleView()
        }
        
        @objc func refresh() {
            collectionView.reloadData()
            collectionView.refreshControl?.endRefreshing()
        }
        
        // MARK: - Navigation

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "ShowDetail" {
                guard let indexPath = collectionView.indexPathsForSelectedItems?.first,
                    let detailVC = segue.destination as? PhotoDetailViewController else { return }
                
                detailVC.photoReference = photoReferences[indexPath.item]
                
                guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell,
                    let image = cell.marsImageView.image else { return }
                
                detailVC.image = image
            }
        }
        
        // MARK: - IBActions
        
        @IBAction func goToPreviousSol(_ sender: Any?) {
            guard let solDescription = solDescription else { return }
            guard let solDescriptions = roverInfo?.solDescriptions else { return }
            guard let index = solDescriptions.firstIndex(of: solDescription) else { return }
            guard index > 0 else { return }
            self.solDescription = solDescriptions[index-1]
        }
        
        @IBAction func goToNextSol(_ sender: Any?) {
            guard let solDescription = solDescription else { return }
            guard let solDescriptions = roverInfo?.solDescriptions else { return }
            guard let index = solDescriptions.firstIndex(of: solDescription) else { return }
            guard index < solDescriptions.count - 1 else { return }
            self.solDescription = solDescriptions[index+1]
        }
        
        // MARK: - Private Methods
        
        private func configureTitleView() {
            let font = UIFont.systemFont(ofSize: 30)
            let attrs = [NSAttributedString.Key.font: font]

            let prevTitle = NSAttributedString(string: "<", attributes: attrs)
            let prevButton = UIButton(type: .system)
            prevButton.accessibilityIdentifier = "PhotosCollectionViewController.PreviousSolButton"
            prevButton.setAttributedTitle(prevTitle, for: .normal)
            prevButton.addTarget(self, action: #selector(goToPreviousSol(_:)), for: .touchUpInside)
            
            let nextTitle = NSAttributedString(string: ">", attributes: attrs)
            let nextButton = UIButton(type: .system)
            nextButton.setAttributedTitle(nextTitle, for: .normal)
            nextButton.addTarget(self, action: #selector(goToNextSol(_:)), for: .touchUpInside)
            nextButton.accessibilityIdentifier = "PhotosCollectionViewController.NextSolButton"
            
            let stackView = UIStackView(arrangedSubviews: [prevButton, solLabel, nextButton])
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fill
            stackView.spacing = UIStackView.spacingUseSystem
            
            navigationItem.titleView = stackView
        }
        
        private func updateTitleView() {
            guard isViewLoaded else { return }
            solLabel.text = "Sol \(solDescription?.sol ?? 0)"
        }
        
        private func loadImage(forCell cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
            let photoReference = photoReferences[indexPath.item]
            
            if let photo = cache.value(forKey: photoReference.id) {
                cell.marsImageView.image = photo;
                return
            }
                    
            let fetchOp = FetchPhotoOperation(marsPhotoReference: photoReference)
            
            let cacheOp = BlockOperation {
                if let image = fetchOp.image {
                    self.cache.cacheValue(image, forKey: photoReference.id)
                }
            }
            
            let completionOp = BlockOperation {
                defer { self.operations.removeValue(forKey: photoReference.id) }
                            
                if let currentIndexPath = self.collectionView.indexPath(for: cell),
                    currentIndexPath != indexPath {
                    return // Cell has been reused
                }
                
                if let image = fetchOp.image {
                    cell.marsImageView.image = image
                }
            }
            
            cacheOp.addDependency(fetchOp)
            completionOp.addDependency(fetchOp)
            
            photoFetchQueue.addOperation(fetchOp)
            photoFetchQueue.addOperation(cacheOp)
            OperationQueue.main.addOperation(completionOp)
            
            operations[photoReference.id] = fetchOp
        }
    }


    // MARK: - UICollectionViewDataSource

    extension PhotosCollectionViewController {

        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return photoReferences.count
        }

        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
            
            loadImage(forCell: cell, forItemAt: indexPath)
        
            return cell
        }
        
        override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print("selected item #: \(indexPath.item)")
            self.performSegue(withIdentifier: "ShowDetail", sender: self)
        }
        
        override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if photoReferences.count > 0 {
                let photoRef = photoReferences[indexPath.item]
                operations[photoRef.id]?.cancel()
            } else {
                for (_, operation) in operations {
                    operation.cancel()
                }
            }
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    extension PhotosCollectionViewController: UICollectionViewDelegateFlowLayout {
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            var totalUsableWidth = collectionView.frame.width
            let inset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
            totalUsableWidth -= inset.left + inset.right
            
            let minWidth: CGFloat = 150.0
            let numberOfItemsInOneRow = Int(totalUsableWidth / minWidth)
            totalUsableWidth -= CGFloat(numberOfItemsInOneRow - 1) * minimumCellSpacing
            let width = totalUsableWidth / CGFloat(numberOfItemsInOneRow)
            return CGSize(width: width, height: width)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: minimumCellSpacing, bottom: 0, right: minimumCellSpacing)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            minimumCellSpacing
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            minimumCellSpacing
        }



}
