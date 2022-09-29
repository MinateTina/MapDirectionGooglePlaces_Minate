//
//  LocationCarouselController.swift
//  MapDirectionGooglePlaces_Minate
//
//  Created by Minate on 9/28/22.
//

import LBTATools
import UIKit
import MapKit

class LocationCell: LBTAListCell<MKMapItem> {
    
    override var item: MKMapItem! {
        didSet {
            label.text = item.name
           
            addressLabel.text = item.address()
            
        }
    }
    
    
    let label = UILabel(text: "Location", font: .boldSystemFont(ofSize: 16))
    let coordinateLabel = UILabel(text: "Coordinate")
    let addressLabel = UILabel(text: "Address", numberOfLines: 0)
    
    override func setupViews() {
        backgroundColor = .white
        setupShadow(opacity: 0.5, radius: 5, offset: .zero, color: .black)
        layer.cornerRadius = 5
        clipsToBounds = false
        stack(label, coordinateLabel, addressLabel).withMargins(.allSides(16))
    }
}

class LocationCarouselController: LBTAListController<LocationCell, MKMapItem> {
    
    weak var mainController: MainController?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(self.items[indexPath.item].name)
        
        let annotations = mainController?.mapView.annotations
        annotations?.forEach({ annotation in
            if annotation.title == self.items[indexPath.item].name {
                mainController?.mapView.selectAnnotation(annotation, animated: true)
            }
        })
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds =  false
        
        let placeMark = MKPlacemark(coordinate: .init(latitude: 10, longitude: 55))
        let dummyMapItem = MKMapItem(placemark: placeMark)
        dummyMapItem.name = "Dummy location for example"
        self.items = [dummyMapItem]
        
    }
    
}

extension LocationCarouselController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}
