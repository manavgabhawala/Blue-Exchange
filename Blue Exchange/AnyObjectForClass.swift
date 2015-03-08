//
//  AnyObjectForClass.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 3/5/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

class AnyObjectForClass
{
	var objectId: String?
	var user : PFUser!
	var forClass : Class! // Instead of using the class code this stores the actual Class object reference.
	init(forClass someClass: Class)
	{
		objectId = nil
		user = nil
		forClass = someClass
	}
	init?(object: PFObject, forClass someClass: Class?)
	{
		objectId = object.objectId
		(object["user"] as? PFUser)?.fetchIfNeededInBackgroundWithBlock{(result, error) in
			if (error == nil && result != nil)
			{
				self.user = result as! PFUser
			}
		}
		var actualClass : Class
		if someClass != nil
		{
			actualClass = someClass!
		}
		else
		{
			let obj = (object["course"] as? PFObject)
			if obj == nil
			{
				return nil
			}
			//obj!.fetch()
			actualClass = Class(object: obj!, subjectCode: obj!["subject"] as! String)
		}
		forClass = actualClass
	}
}