//
//  School.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 11/2/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

import Foundation

/**
*  This is a struct that is used to populate the school picker. It has a relevant information such as an array of cached subjects. It also has its own code and description.
:discussion: The cached subjects array will be empty until it is pulled from the database at which time you should call the addSubjects: function to cache the subjects.
*/
class School : CustomStringConvertible, CustomDebugStringConvertible
{
	var objectId : String?
	var code : String? = ""
	var schoolDescription = ""
	var subjects = [Subject]()
	
	/**
	This is the main initializer for the School struct and can be used to make a new valid School object.
	
	- parameter code:        The code of the school. Example: ENGR
	- parameter description: The user readable string of the school's name. Example: Engineering
	
	- returns: Returns an initialized object that can be used to display this school.
	*/
	init(code: String?, description: String)
	{
		self.code = code
		schoolDescription = description
		
	}
	
	/**
	This is a convenience intializer that can be used when no classes are found for a school or subject.
	
	- returns: Creates a School with the description "No Schools Found" which can be displayed to the user. It also has a code of nil which can be used to check if schools were found or not.
	*/
	convenience init()
	{
		self.init(code: nil, description: "No Schools Found")
	}
	
	convenience init(object: PFObject)
	{
		self.init(code: object["code"] as? String, description: object["description"] as? String ?? "No Schools Found")
		objectId = object.objectId
		setSubjectsToNil()
	}
	
	/**
	This function adds all subjects the school has into its own subjects array. This creates a local cache of Subjects so that this data does not need to be pulled the next time the School is deselected and then reselected.
	
	- parameter subjects: The array of subjects that are to be added to the cache for this school.
	*/
	func addSubjects (subjects: [PFObject])
	{
		self.subjects = subjects.map { Subject(object: $0, school: self) }
		if subjects.count <= 0
		{
			setSubjectsToNil()
		}
		sortSubjects()
	}
	func setSubjectsToNil()
	{
		subjects = [Subject(school: self)]
	}
	func sortSubjects()
	{
		subjects.sortInPlace { $0.description < $1.description }
	}
	
	var description : String
	{
		get
		{
			if (code == nil)
			{
				return "No Schools Found"
			}
			return "\(schoolDescription)"
		}
	}
	var debugDescription : String
	{
		get
		{
			return description
		}
	}
}