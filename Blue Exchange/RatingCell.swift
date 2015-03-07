//
//  RatingCell.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 3/7/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import UIKit

class RatingCell: UITableViewCell
{
	@IBOutlet var ratingView : RatingView!
	func setup()
	{
		ratingView.emptyImage = UIImage(named: "star")
		ratingView.fullImage = UIImage(named: "star-highlighted")
		ratingView.minRating = 0
		ratingView.maxRating = 5
		ratingView.editable = true
		ratingView.halfRatings = true
		ratingView.rating = 2.5
	}
}
