//
//  MapItemTableViewCell.swift
//  LocalSearch
//
//  Created by Patrick DeSantis on 9/10/16.
//  Copyright © 2016 Patrick DeSantis. All rights reserved.
//

import MapKit
import UIKit

class MapItemTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    func update(mapItem: MKMapItem) {
        nameLabel.text = mapItem.name
        addressLabel.text = mapItem.placemark.title
    }

    func update(searchCompletion: MKLocalSearchCompletion) {
        nameLabel.text = searchCompletion.title
        addressLabel.text = searchCompletion.subtitle
    }

}
