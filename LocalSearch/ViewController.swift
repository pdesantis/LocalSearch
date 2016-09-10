//
//  ViewController.swift
//  LocalSearch
//
//  Created by Patrick DeSantis on 9/10/16.
//  Copyright © 2016 Patrick DeSantis. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    fileprivate let locationManager = CLLocationManager()
    fileprivate let searchCompleter = MKLocalSearchCompleter()

    fileprivate var localSearch: MKLocalSearch?
    fileprivate var mapItems = [MKMapItem]()
    fileprivate var searchCompletions = [MKLocalSearchCompletion]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension

        locationManager.delegate = self
        searchCompleter.delegate = self
        searchCompleter.filterType = .locationsAndQueries
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        locationManager.requestWhenInUseAuthorization()
    }

    @IBAction func toggleResults(_ sender: AnyObject) {
        tableView.reloadData()
    }

    func search(query: String) {
        guard let location = locationManager.location else {
            return
        }

        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)

        if searchCompleter.isSearching {
            searchCompleter.cancel()
        }
        searchCompleter.region = region
        searchCompleter.queryFragment = query

        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = query
        request.region = region

        localSearch = MKLocalSearch(request: request)
        localSearch?.start(completionHandler: localSearchCompletionHandler)
    }

    func search(searchCompletion: MKLocalSearchCompletion) {
        let request = MKLocalSearchRequest(completion: searchCompletion)
        localSearch = MKLocalSearch(request: request)
        localSearch?.start(completionHandler: localSearchCompletionHandler)

        segmentedControl.selectedSegmentIndex = 1
        textField.text = request.naturalLanguageQuery
    }

    func localSearchCompletionHandler(response: MKLocalSearchResponse?, error: Error?) {
        guard let response = response, error == nil else {
            self.mapItems = []
            print(error)
            return
        }

        self.mapItems = response.mapItems
        self.tableView.reloadData()
    }
}

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension ViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchCompletions = completer.results
        tableView.reloadData()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return searchCompletions.count
        default:
            return mapItems.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapItemCell", for: indexPath) as! MapItemTableViewCell

        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let searchCompletion = searchCompletions[indexPath.row]
            cell.update(searchCompletion: searchCompletion)
        default:
            let mapItem = mapItems[indexPath.row]
            cell.update(mapItem: mapItem)
        }
        return cell
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let searchCompletion = searchCompletions[indexPath.row]
            search(searchCompletion: searchCompletion)
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension ViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        localSearch?.cancel()

        let previousText = textField.text as NSString?
        let text = previousText?.replacingCharacters(in: range, with: string) as String?
        if let text = text, !text.isEmpty {
            search(query: text)
        } else {
            mapItems = []
            searchCompletions = []
        }
        return true
    }
}
