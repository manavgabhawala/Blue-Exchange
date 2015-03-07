//
//  Review.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 3/5/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import Foundation

/**
*  This is a model of a review that is displayed in the results controller. It is a model of the PFObject(className: "Review") with all the relevant fields.
*/
enum CourseLoad : Int, Printable
{
	case VeryEasy = 0
	case Easy, Medium, Difficult, VeryDifficult, InsanelyDifficult
	case Nil
	var description : String
	{
		get
		{
			switch self
			{
			case .VeryEasy:
				return "Very Easy"
			case .Easy:
				return "Easy"
			case .Medium:
				return "Medium"
			case .Difficult:
				return "Difficult"
			case .VeryDifficult:
				return "Very Difficult"
			case .InsanelyDifficult:
				return "Insanenly Difficult"
			default:
				return "Undefined"
			}
		}
	}
}
class Review : AnyObjectForClass
{
	var anonymous = false
	var description = ""
	var rating : Float = 2.5
	var courseLoad : CourseLoad = .Nil
	var professor = ""
	override init?(object: PFObject, forClass someClass: Class?)
	{
		super.init(object: object, forClass: someClass)
		anonymous = object["anonymous"] as? Bool ?? false
		rating = object["rating"] as? Float ?? 2.5
		let load = object["workload"] as? Int ?? 6
		courseLoad = CourseLoad(rawValue: load) ?? .Nil
		description = object["text"] as? String ?? "No Comments"
		professor = object["professor"] as? String ?? "Not Mentioned"
	}
}