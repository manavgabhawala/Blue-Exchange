//
//  ReviewCell.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 3/5/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import UIKit

class ReviewCell: UICollectionViewCell
{
	@IBOutlet var classLabel : UILabel!
	@IBOutlet var professor : UILabel!
	@IBOutlet var user : UILabel!
	@IBOutlet var stars : RatingView!
	@IBOutlet var workload : UILabel!
	@IBOutlet var reviewDescription : UILabel!
	func setDetails(review: Review)
	{
		layer.borderColor = UIColor(white: 1.0, alpha: 0.55).CGColor
		layer.borderWidth = 1.0
		layer.cornerRadius = 12.0
		backgroundColor = UIColor.clearColor()
		var name = "Anonymous"
		if review.user != nil && !review.anonymous
		{
			review.user.fetchIfNeeded()
			name = (review.user["firstName"] as? String ?? "John") + " " + (review.user["lastName"] as? String ?? "Doe")
		}
		user.text = name
		classLabel.text = "\(review.forClass.description)"
		stars.emptyImage = UIImage(named: "star")!
		stars.fullImage = UIImage(named: "star-highlighted")!
		stars.minRating = 0
		stars.maxRating = 5
		stars.halfRatings = true
		stars.rating = review.rating
		stars.editable = false
		
		//FIXME: Show stars for rating.
		workload.text = review.courseLoad.description
		reviewDescription.text = review.description
	}
}
