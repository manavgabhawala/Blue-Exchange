//
//  TextFieldCell.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 11/15/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

import UIKit
/**
*  This is just a generic textfield cell with the textfield center aligned allowing for user inputs.
*/
class TextFieldCell: UITableViewCell
{
	@IBOutlet var textField: UITextField!
	func setup(delegate: UITextFieldDelegate, placeholder: String)
	{
		textField.borderStyle = UITextBorderStyle.None
		textField.delegate = delegate
		textField.layer.cornerRadius = 8.0
		textField.layer.masksToBounds = true
		textField.layer.borderColor = UIColor.umMaizeColor().CGColor
		textField.layer.borderWidth = 0.5
		textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.6)])
	}
}
