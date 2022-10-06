//
//  RouteHeader.swift
//  MapDirectionGooglePlaces_Minate
//
//  Created by Minate on 10/5/22.
//

import SwiftUI
import UIKit
import MapKit
import LBTATools
import JGProgressHUD

class RoutesCell: LBTAListCell<MKRoute.Step> {
    
    override var item: MKRoute.Step! {
        didSet {
            nameLabel.text = item.instructions
            let milesConversion = item.distance * 0.00062137
            distanceLabel.text = String(format: "%.2f mi", milesConversion)
        }
    }
    
    let nameLabel = UILabel(text: "Name", numberOfLines: 0)
    let distanceLabel = UILabel(text: "distance", textAlignment: .right)
    
    override func setupViews() {
        hstack(nameLabel, distanceLabel.withWidth(80)).withMargins(.allSides(16))
        addSeparatorView(leadingAnchor: nameLabel.leadingAnchor)
    }
}



class RoutesController: LBTAListHeaderController<RoutesCell,MKRoute.Step,RouteHeader>, UICollectionViewDelegateFlowLayout {
    
    var route: MKRoute!
    
    override func setupHeader(_ header: RouteHeader) {
        header.nameLabel.attributedText = header.generateAttributedString(title: "Route: ", description: route.name)
        
        let milesDistance = route.distance * 0.00062137
        let milesString = String(format: "%.2f mi", milesDistance)
        
        header.distanceLable.attributedText =  header.generateAttributedString(title: "Distance: ", description: milesString)
        
        var timeString = ""
        if route.expectedTravelTime > 3600 {
            let h = Int(route.expectedTravelTime /  60 / 60)
            let m = Int((route.expectedTravelTime.truncatingRemainder(dividingBy: 60 * 60)) /  60)
            timeString = String(format: "%d hr %d min", h, m)
        } else {
            let time = Int(route.expectedTravelTime / 60)
            timeString = String(format: "%d min", time)
        }
        
        header.estimatedTimeLabel.attributedText = header.generateAttributedString(title: "Estimated Time: ", description: timeString)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: 0, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 50)
    }
}

class RouteHeader: UICollectionReusableView {
    
    let nameLabel = UILabel(text: "Route Name", font: .systemFont(ofSize: 16))
    let distanceLable = UILabel(text: "Distance", font: .systemFont(ofSize: 16))
    let estimatedTimeLabel = UILabel(text: "Est time...", font: .systemFont(ofSize: 16))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        hstack(stack(nameLabel, distanceLable,estimatedTimeLabel, spacing: 8), alignment: .center).withMargins(.allSides(16))
        
        nameLabel.attributedText = generateAttributedString(title: "Route: ", description: "US 101S")
        distanceLable.attributedText = generateAttributedString(title: "Distance: ", description: "13.14mi")
    }
    
    func generateAttributedString(title: String, description: String) -> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(string: title, attributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
        
        attributedString.append(.init(string: description, attributes: [.font: UIFont.systemFont(ofSize: 16)]))
        
        return attributedString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has been implemented")
    }
    
}

struct RouteHeader_Previews: PreviewProvider {
    static var previews: some View {
        Container()
    }
    
    struct Container: UIViewRepresentable {
        
        func makeUIView(context: UIViewRepresentableContext<RouteHeader_Previews.Container>) -> UIView {
            
            return RouteHeader()
        }
        
        func updateUIView(_ uiView: UIViewType, context: Context) {
            
        }
        
        
        
        
    }
}
