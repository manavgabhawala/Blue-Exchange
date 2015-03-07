//
//  Subject.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 11/2/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

import Foundation
/**
*  This is a struct that is used to populate the subject picker. It has relevant information such as the school it belongs to and an array of cached classes. It also has its own code and description.
:discussion: The cached classes array will be empty until it is pulled from the database at which time you should call the addClasses: function to cache the classes.
*/
class Subject
{
	var objectId : String?
	var code : String?
	var subjectDescription : String
	var classes = [Class]()
	weak var school : School?
	
	/**
	This is the main initializer for the Subject struct and can be used to make a new valid Subject object.
	
	:param: code        The subject code. Example: EECS
	:param: description The description of the subject. Example: Electrical Engineering and Computer Science.
	:param: schoolCode  The school code to which this subject belongs. Example: ENGR
	
	:returns: Returns an initialized object that can be used to display this subject.
	*/
	init(code: String?, description: String, school: School)
	{
		self.code = code
		self.subjectDescription = description
		self.school = school
		setClassesToNil()
	}
	/**
	This is a convenience intializer that can be used to create a subject using a PFObject.
	
	:param: object The PFObject for the subject.
	:param: school The school
	
	:returns: Creates a Subject with the description from PFObject which can be displayed to the user. It also has a code of nil which can be used to check if subjects were found or not.
	*/
	convenience init(object: PFObject, school: School)
	{
		self.init(code: object["code"] as? String, description: object["description"] as? String ?? "No Subjects Found", school: school)
		objectId = object.objectId
	}
	/**
	This is a convenience intializer that can be used when no classes are found for a school or subject.
	
	:param: school The school for which no subjects were found
	
	:returns: The subject object.
	*/
	convenience init(school: School)
	{
		self.init(code: nil, description: "No Subjects Found", school: school)
	}
	
	func setClassesToNil()
	{
		classes = [Class(school: school, subject: self)]
	}
	/**
	This function adds all classes the subject has into its own classes array. This creates a local cache of Classes so that this data does not need to be pulled the next time if the subject is deselected and then reselected.
	
	:param: classes The array of classes that are to be added to the cache for this subject.
	:see: Class
	*/
	func addClasses (classes: [PFObject])
	{
		self.classes = classes.map { Class(object: $0, school: self.school, subject: self) }
		if classes.count <= 0
		{
			setClassesToNil()
		}
		sortClasses()
	}
	func sortClasses()
	{
		classes.sort { $0.catalogNumber?.toInt() < $1.catalogNumber?.toInt() }
	}
	var description : String
		{
		get
		{
			if (school == nil || code == nil)
			{
				return "No Subjects Found"
			}
			return "\(subjectDescription)"
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