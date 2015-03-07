//
//  PickerCell.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 11/14/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

import UIKit
/**
*  This is a custom cell with a UIPicker that let's the user pick from a list of classes, subjects, schools, games, sports, etc.
*/
class PickerCell: UITableViewCell
{
	@IBOutlet var picker : UIPickerView!
	func setup(dataSource: UIPickerViewDataSource, delegate: UIPickerViewDelegate)
	{
		picker.layer.borderColor = UIColor.umMaizeColor().CGColor
		picker.layer.borderWidth = 1.0
		picker.layer.cornerRadius = 12.0
		picker.dataSource = dataSource
		picker.delegate = delegate
	}
}
