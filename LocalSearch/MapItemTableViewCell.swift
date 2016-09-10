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
        let nameFontSize = nameLabel.font.pointSize

        let titleAttributes: [String: Any] = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: nameFontSize),
            NSForegroundColorAttributeName: nameLabel.textColor]
        let titleNonBoldAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: nameFontSize)
        ]
        let titleString = NSMutableAttributedString(string: searchCompletion.title, attributes: titleAttributes)
        for range in searchCompletion.titleHighlightRanges as [NSRange] {
            titleString.addAttributes(titleNonBoldAttributes, range: range)
        }
        nameLabel.attributedText = titleString

        addressLabel.text = searchCompletion.subtitle
    }
}
