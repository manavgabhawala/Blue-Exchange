//
//  ReviewCell.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 3/5/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import UIKit
protocol ReviewCellDelegate: AnyObjectForClassCellDelegate
{
	func description(review: Review)
}
class ReviewCell: UICollectionViewCell
{
	@IBOutlet var classLabel : UILabel!
	@IBOutlet var professor : UILabel!
	@IBOutlet var user : UILabel!
	@IBOutlet var stars : RatingView!
	@IBOutlet var workload : UILabel!
	@IBOutlet var flagButton: UIButton!
	var review : Review!
	var delegate: ReviewCellDelegate?
	var deleteMode = false
	func setDetails(review: Review, delegate: ReviewCellDelegate?, deleteMode: Bool)
	{
		self.delegate = delegate
		self.review = review
		layer.borderColor = UIColor(white: 1.0, alpha: 0.55).CGColor
		layer.borderWidth = 1.0
		layer.cornerRadius = 12.0
		backgroundColor = UIColor.clearColor()
		if deleteMode
		{
			flagButton.setTitle("⌫", forState: .Normal)
			flagButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 22.0)!
		}
		if review.average
		{
			user.text = "Average For Course"
			stars.floatRatings = true
			user.textColor = UIColor.redColor()
			layer.borderColor = UIColor.umMaizeColor().CGColor
		}
		else
		{
			var name = "Anonymous"
			if review.user != nil && !review.anonymous
			{
				name = (review.user["firstName"] as? String ?? "John") + " " + (review.user["lastName"] as? String ?? "Doe")
			}
			user.text = name
			user.textColor = UIColor.whiteColor()
		}
		classLabel.text = "\(review.forClass.description)"
		stars.emptyImage = UIImage(named: "star")!
		stars.fullImage = UIImage(named: "star-highlighted")!
		stars.minRating = 0
		stars.maxRating = 5
		stars.halfRatings = true
		stars.rating = review.rating
		stars.editable = false
		professor.text = review.professor
		workload.text = review.courseLoad.description
	}
	@IBAction func flagObject(sender: UIButton)
	{
		delegate?.flag(review.objectId, className: "Review", sender: sender)
	}
	@IBAction func description(_: UIButton)
	{
		delegate?.description(review)
	}
}
