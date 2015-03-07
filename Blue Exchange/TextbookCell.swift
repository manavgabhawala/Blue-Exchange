//
//  TextbookCell.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 3/5/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import UIKit

class TextbookCell: UICollectionViewCell
{
	@IBOutlet var classLabel : UILabel!
	@IBOutlet var title : UILabel!
	@IBOutlet var buyerSeller : UILabel!
	@IBOutlet var user : UILabel!
	@IBOutlet var price : UILabel!
	@IBOutlet var condition : UILabel!
	func setDetails(textbook: Textbook)
	{
		layer.borderColor = UIColor(white: 1.0, alpha: 0.55).CGColor
		layer.borderWidth = 1.0
		layer.cornerRadius = 12.0
		backgroundColor = UIColor.clearColor()
		buyerSeller.text = textbook.selling ? "Seller" : "Buyer" + ":"
		var name = "Anonymous"
		if textbook.user != nil
		{
			textbook.user.fetchIfNeeded()
			name = (textbook.user["firstName"] as? String ?? "John") + " " + (textbook.user["lastName"] as? String ?? "Doe")
		}
		user.text = name
		classLabel.text = "\(textbook.forClass.description)"
		title.text = textbook.title
		let currencyFormatter = NSNumberFormatter()
		currencyFormatter.numberStyle = .CurrencyStyle
		price.text = currencyFormatter.stringFromNumber(textbook.price)
		condition.text = textbook.condition
	}
}
