//
//  DescriptionCell.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 3/7/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import Foundation
class DescriptionCell : UITableViewCell
{
	@IBOutlet var textView : UITextView!
	func setup()
	{
		textView.layer.cornerRadius = 8.0
		textView.layer.masksToBounds = true
		textView.layer.borderColor = UIColor.umMaizeColor().CGColor
		textView.layer.borderWidth = 0.5
	}
}