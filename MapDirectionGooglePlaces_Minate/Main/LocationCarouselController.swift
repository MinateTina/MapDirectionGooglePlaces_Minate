//
//  LocationCarouselController.swift
//  MapDirectionGooglePlaces_Minate
//
//  Created by Minate on 9/28/22.
//

import LBTATools
import UIKit

class LocationCell: LBTAListCell<String> {
    override func setupViews() {
        backgroundColor = .white
        setupShadow(opacity: 0.5, radius: 5, offset: .zero, color: .black)
        layer.cornerRadius = 5
        clipsToBounds = false
    }
}

class LocationCarouselController: LBTAListController<LocationCell,String>, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .clear
        self.items = ["1","2","3"]
        
    }
    
}
