//
//  CustomCallout.swift
//  MapDirectionGooglePlaces_Minate
//
//  Created by Minate on 10/9/22.
//

import UIKit
import LBTATools


class CalloutContainer: UIView {
    
    let imageView = UIImageView(image: nil, contentMode: .scaleAspectFill)
    let nameLabel = UILabel(textAlignment: .center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.borderWidth = 2
        layer.borderColor = UIColor.darkGray.cgColor
        setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .darkGray)
        layer.cornerRadius = 5
        
        // load the spinner
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .darkGray
        spinner.startAnimating()
        addSubview(spinner)
        spinner.fillSuperview()
        
        
        addSubview(imageView)
        imageView.layer.cornerRadius = 5
        imageView.fillSuperview()
        
        let labelContainer = UIView(backgroundColor: .white)
        labelContainer.stack(nameLabel)
        stack(UIView(), labelContainer.withHeight(30))
        
        
        labelContainer.stack(nameLabel)
        stack(UIView(), labelContainer.withHeight(30))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
