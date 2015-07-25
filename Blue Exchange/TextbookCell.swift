//
//  TextbookCell.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 3/5/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import UIKit

protocol AnyObjectForClassCellDelegate
{
	func flag(objectId: String?, className: String, sender: UIButton)
}
protocol TextbookCellDelegate : AnyObjectForClassCellDelegate
{
	func callNumber(number: Double?)
	func textNumber(number: Double?)
	func email(id: String?)
	func description(textbook: Textbook)
}
class TextbookCell: UICollectionViewCell
{
	@IBOutlet var classLabel : UILabel!
	@IBOutlet var title : UILabel!
	@IBOutlet var buyerSeller : UILabel!
	@IBOutlet var user : UILabel!
	@IBOutlet var price : UILabel!
	@IBOutlet var condition : UILabel!
	@IBOutlet var phoneNumberButton: UIButton!
	@IBOutlet var textButton: UIButton!
	@IBOutlet var flagButton: UIButton!
	
	var phoneNumber : Double? = nil
	var emailId : String?
	var textbookDescription : String?
	var delegate: TextbookCellDelegate?
	var textbook : Textbook!
	func setDetails(textbook: Textbook, delegate: TextbookCellDelegate?, deleteMode: Bool)
	{
		self.textbook = textbook
		self.delegate = delegate
		layer.borderColor = UIColor(white: 1.0, alpha: 0.55).CGColor
		layer.borderWidth = 1.0
		layer.cornerRadius = 12.0
		backgroundColor = UIColor.clearColor()
		buyerSeller.text = textbook.selling ? "Seller" : "Buyer" + ":"
		var name = "Anonymous"
		if textbook.user != nil
		{
			name = (textbook.user["firstName"] as? String ?? "John") + " " + (textbook.user["lastName"] as? String ?? "Doe")
			if let number = textbook.user["phone"] as? Double
			{
				if number != 0
				{
					phoneNumber = number
				}
			}
			if let id = textbook.user["email"] as? String
			{
				if !id.isEmpty
				{
					emailId = id

				}
			}
		}
		if deleteMode
		{
			flagButton.setTitle("⌫", forState: .Normal)
			flagButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 22.0)!
		}
		if !textbook.showPhoneNumber
		{
			phoneNumberButton.enabled = false
			textButton.enabled = false
		}
		else
		{
			phoneNumberButton.enabled = true
			textButton.enabled = true
		}
		user.text = name
		classLabel.text = "\(textbook.forClass.description)"
		title.text = textbook.title
		let currencyFormatter = NSNumberFormatter()
		currencyFormatter.numberStyle = .CurrencyStyle
		price.text = currencyFormatter.stringFromNumber(textbook.price)
		condition.text = textbook.condition
		textbookDescription = textbook.description
	}
	func debugNoDelegate()
	{
		if delegate == nil
		{
			print("No delegate")
		}
	}
	@IBAction func flagButton(sender : UIButton)
	{
		debugNoDelegate()
		delegate?.flag(textbook.objectId, className: "Textbook", sender: sender)
	}
	@IBAction func descriptionButton(_ : UIButton)
	{
		debugNoDelegate()
		delegate?.description(textbook)
	}
	@IBAction func callButton(_ : UIButton)
	{
		debugNoDelegate()
		delegate?.callNumber(phoneNumber)
	}
	@IBAction func textButton(_: UIButton)
	{
		debugNoDelegate()
		delegate?.email(emailId)
	}
	@IBAction func smsButton(_: UIButton)
	{
		debugNoDelegate()
		delegate?.textNumber(phoneNumber)
	}
}
