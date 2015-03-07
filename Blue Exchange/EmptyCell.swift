//
//  EmptyCell.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 3/5/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import UIKit

class EmptyCell: UICollectionViewCell
{
	@IBOutlet var label : UILabel!
	func setup()
	{
		layer.cornerRadius = 12.0
	}
}
