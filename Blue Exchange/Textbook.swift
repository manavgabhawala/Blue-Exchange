//
//  Textbook.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 11/14/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

import Foundation


/**
*  This is a model of a textbook that is displayed in the results controller. It is a model of the PFObject(className: "Textbook") with all the relevant fields.
*/
class Textbook : AnyObjectForClass
{
	var price : Float = 50.00
	var selling = false
	var showPhoneNumber = true
	var title : String = ""
	var condition : String = ""
	var description : String = ""
	var version : String = ""
	
	override init?(object: PFObject, forClass someClass: Class?)
	{
		super.init(object: object, forClass: someClass)
		selling = object["selling"] as? Bool ?? false
		price = object["price"] as? Float ?? 50.00
		title = object["title"] as? String ?? "No Title Available"
		title = title.isEmpty ? "No Title Available" : title
		condition = object["condition"] as? String ?? "None"
		description = object["description"] as? String ?? "No Description Given"
		version = object["edition"] as? String ?? "NA"
	}
}