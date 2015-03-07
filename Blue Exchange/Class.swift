//
//  Subject.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 11/2/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

/**
*  This is a struct that is used to populate the class picker. It has a relevant information such as the school and subject it belongs to, its own catalog number and the class description.
*/
class Class : Printable, DebugPrintable
{
	var objectId : String?
	var catalogNumber : String?
	var classDescription : String
	weak var subject : Subject?
	weak var school : School?
	var subjectCode : String?
	
	/**
	This is the main initializer for the Class struct and can be used to make a new valid Class object.
	
	:param: catalogNumber The catalog number to which this class refers. Example: 280
	:param: description   The description of the class. Example: Programming and Data Structures.
	:param: schoolCode    The school to which this class belongs. Example: ENGR
	:param: subjectCode   The subject (or department) for this class. Example: EECS
	
	:returns: Returns an initialized class with the paramaters given.
	*/
	init(catalogNumber: String?, description: String, school: School?, subject: Subject?)
	{
		self.catalogNumber = catalogNumber
		self.classDescription = description
		self.school = school
		self.subject = subject
	}
	
	convenience init(object: PFObject, school: School?, subject: Subject?)
	{
		self.init(catalogNumber: object["catalogNumber"] as? String, description: object["description"] as? String ?? "No Classes Found", school: school, subject: subject)
		objectId = object.objectId
	}
	
	convenience init(object: PFObject, subjectCode: String)
	{
		self.init(catalogNumber: object["catalogNumber"] as? String, description: object["description"] as? String ?? "No Classes Found", school: nil, subject: nil)
		self.subjectCode = subjectCode
		objectId = object.objectId
	}
	
	/**
	This is a convenience intializer that can be used when no classes are found for a school or subject
	
	:param: school  The school for which no classes were found
	:param: subject The subject for which no classes were found
	
	:returns: Creates a Class with the description "No Classes Found" which can be displayed to the user. It also has a catalogNumber of nil which can be used to check if classes were found or not.
	*/
	convenience init(school: School?, subject: Subject?)
	{
		self.init(catalogNumber: nil, description: "No Classes Found", school: school, subject: subject)
	}
	
	var description : String
	{
		get
		{
			let subjectCode = subject?.code ?? self.subjectCode
			if (catalogNumber == nil || subjectCode == nil)
			{
				return "No Classes Found"
			}
			return "\(subjectCode!) \(catalogNumber!): \(classDescription)"
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

