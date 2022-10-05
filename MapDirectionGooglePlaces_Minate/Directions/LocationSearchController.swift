//
//  LocationSearchController.swift
//  MapDirectionGooglePlaces_Minate
//
//  Created by Minate on 10/3/22.
//

import SwiftUI
import UIKit
import MapKit
import LBTATools
import Combine


class LocationSearchCell: LBTAListCell<MKMapItem> {
    
    override var item: MKMapItem! {
        didSet {
            nameLabel.text = item.name
            addressLabel.text = item.address()
        }
    }
    
    let nameLabel = UILabel(text: "name", font: .boldSystemFont(ofSize: 16))
    let addressLabel = UILabel(text: "address", font: .systemFont(ofSize: 14))
    
    override func setupViews() {
        backgroundColor = .clear
        stack(nameLabel, addressLabel).withMargins(.allSides(16))
        addSeparatorView(leftPadding: 16)
    }
}

class LocationSearchController: LBTAListController<LocationSearchCell,MKMapItem> {
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.becomeFirstResponder()
        setupSearchListener()
        setupSearchBar()
        
    }
    
    let navBarHeight: CGFloat = 66
    
    let backIcon = UIButton(image: #imageLiteral(resourceName: "back_arrow"), tintColor: .black, target: self, action: #selector(handleBack)).withWidth(32)
    
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    let searchTextField = IndentedTextField(placeholder: "Search Term", padding: 12)
    
    private func setupSearchBar() {
        let navBar = UIView(backgroundColor: .white)
        view.addSubview(navBar)
        navBar.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -navBarHeight, right: 0))
        collectionView.verticalScrollIndicatorInsets.top = navBarHeight
        
        let container = UIView()
        navBar.addSubview(container)
        container.fillSuperviewSafeAreaLayoutGuide()
        container.hstack(backIcon, searchTextField).withMargins(.init(top: 0, left: 16, bottom: 16, right: 16))
        searchTextField.layer.borderWidth = 2
        searchTextField.layer.borderColor = UIColor.lightGray.cgColor
        searchTextField.layer.cornerRadius = 5
        
        setupSearchListener()
    }
    
    
    var listener: Any!
    //cancel listener bcos might have retain cycles
//    var listener: AnyCancellable!
    private func setupSearchListener() {
        listener = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: searchTextField).debounce(for: .milliseconds(500), scheduler: RunLoop.main).sink(receiveValue: { [weak self] _ in
            self?.performLocalSearch()
        })
//        listener.cancel()
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: navBarHeight, left: 0, bottom: 0, right: 0)
    }
    
    //closure
    var selectionHandler: ((MKMapItem) -> ())?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mapItem = self.items[indexPath.item]
        selectionHandler?(mapItem)
        navigationController?.popViewController(animated: true)
    }
    
    private func performLocalSearch() {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTextField.text
        
        let search = MKLocalSearch(request: request)
        search.start { resp, err in
            
            if let err = err {
                print("Failed to perform local search", err)
                return
            }
            self.items = resp?.mapItems ?? []
        }
    }
}

extension LocationSearchController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 80)
    }
}

struct LocationSearch_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView()
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<LocationSearch_Previews.ContainerView>) -> UIViewController {
            return LocationSearchController()
        }
        
        func updateUIViewController(_ uiViewController: LocationSearch_Previews.ContainerView.UIViewControllerType, context: Context) {
            
        }
        
    }
}
