//
//  ViewController.swift
//  cariad-challenge
//
//  Created by Rodrigo Scroferneker on 02/03/2023.
//

import UIKit
import MapKit
import Combine

class MapViewController: UIViewController {
    public enum State: Equatable {
        public static func == (lhs: MapViewController.State, rhs: MapViewController.State) -> Bool {
            switch (lhs, rhs) {
            case (.fetching, .fetching), (.error, .error), (.idle, .idle):
                return true
            default:
                return false
            }
        }
        
        case fetching
        case error(Error)
        case idle
    }
    
    private let model: MapViewModel
    private var cancellables = Set<AnyCancellable>()
    
    lazy var mapView: MKMapView = {
        let view = MKMapView()
        view.register(ChargingStationAnnotation.self, forAnnotationViewWithReuseIdentifier: ChargingStationAnnotation.identifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var statusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 25
        return view
    }()
    
    lazy var statusText: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = ""
        return view
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(model: MapViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
        view.addSubview(mapView)
        view.addSubview(statusView)
        statusView.addSubview(statusText)
        statusView.addSubview(activityIndicator)

        addMapConstraints()
        addStatusConstraints()
        setupObservables()
        
        model.fetchData()
        model.startMapPolling()
    }
    
    private func setupObservables() {
        model
            .$viewState
            .receive(on: RunLoop.main)
            .sink { [weak self] viewState in
                switch viewState {
                case .fetching:
                    self?.statusView.backgroundColor = .systemBlue
                    self?.statusText.text = "Loading"
                    self?.statusText.textColor = .white
                    self?.activityIndicator.startAnimating()
                case .error(let error):
                    self?.statusView.backgroundColor = .systemRed
                    self?.statusText.text = "Error: \(error.localizedDescription)"
                    self?.statusText.textColor = .white
                    self?.activityIndicator.stopAnimating()
                case .idle:
                    self?.statusView.backgroundColor = .systemYellow
                    self?.statusText.text = "Updated"
                    self?.statusText.textColor = .black
                    self?.activityIndicator.stopAnimating()
                }
            }.store(in: &cancellables)
        model
            .$stations
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink { [weak self] stations in
                self?.updateAnnotations(stations)
            }.store(in: &cancellables)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let region = MKCoordinateRegion(
            center: .init(latitude: model.lat, longitude: model.lon),
            latitudinalMeters: model.zoomDistance,
            longitudinalMeters: model.zoomDistance)
        let adjustedReg = mapView.regionThatFits(region)
        mapView.setRegion(adjustedReg, animated: true)
    }
    
    private func updateAnnotations(_ stations: [ChargingStation]) {
        self.mapView.annotations.forEach { self.mapView.removeAnnotation($0)}
        stations.forEach {
            let annotation = ChargingStationAnnotation(
                coordinate: CLLocationCoordinate2D(
                    latitude: $0.addressInfo.latitude,
                    longitude: $0.addressInfo.longitude),
                station: $0)
            annotation.title = $0.addressInfo.addressLine1
            self.mapView.addAnnotation(annotation)
        }
    }

    private func addMapConstraints() {
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
        ])
    }
    
    private func addStatusConstraints() {
        NSLayoutConstraint.activate([
            statusView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusView.heightAnchor.constraint(equalToConstant: 50),
            statusView.widthAnchor.constraint(equalToConstant: 200),
            statusView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            activityIndicator.topAnchor.constraint(equalTo: statusView.topAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: statusView.bottomAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 16),
            activityIndicator.widthAnchor.constraint(equalToConstant: 20),
            statusText.leadingAnchor.constraint(equalTo: activityIndicator.trailingAnchor, constant: 16),
            statusText.trailingAnchor.constraint(equalTo: statusView.trailingAnchor),
            statusText.bottomAnchor.constraint(equalTo: statusView.bottomAnchor),
            statusText.topAnchor.constraint(equalTo: statusView.topAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        
        guard let customAnnotation = annotation as? ChargingStationAnnotation else { return }
        let lat = annotation.coordinate.latitude
        let lon = annotation.coordinate.longitude
        
        let region = MKCoordinateRegion(
            center: .init(latitude: lat, longitude: lon),
            latitudinalMeters: model.zoomDistance,
            longitudinalMeters: model.zoomDistance)
        let adjustedReg = mapView.regionThatFits(region)
        mapView.setRegion(adjustedReg, animated: true)
        
        show(POIDetailViewController(station: customAnnotation.station), sender: self)
    }
}

