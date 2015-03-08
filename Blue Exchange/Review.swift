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
	@objc var description = ""
	var rating : Float = 2.5
	var courseLoad : CourseLoad = .Nil
	var professor = ""
	var average = false
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
	private init(forClass: Class, rating: Float, courseLoad: CourseLoad?, professor: String)
	{
		super.init(forClass: forClass)
		self.courseLoad = courseLoad ?? .Nil
		self.rating = min(max(rating, 0.0), 5.0)
		self.professor = professor
		self.average = true
		self.description = "These are average values for this course."
	}
	class func createAverageReview(reviews: [Review]) -> Review
	{
		assert(reviews.count > 0)
		let courseLoads = reviews.filter { $0.courseLoad != .Nil }.map { Float($0.courseLoad.rawValue) }
		let courseLoadAverage : Float = courseLoads.count > 0 ? courseLoads.reduce(courseLoads.first!, combine: { ($0.0 + $0.1) / 2}) : 6
		let averageLoad = Int(round(courseLoadAverage))
		var map = [String: Int]()
		for professor in (reviews.map { $0.professor.lowercaseString })
		{
			if (professor != "not mentioned")
			{
				if map[professor] != nil
				{
					map[professor]! += 1
				}
				else
				{
					map[professor] = 1
				}
			}
		}
		let highestProfessor = allKeysForValue(map,  maxElement(map.values)).first ?? "Unknown"
		return Review(forClass: reviews.first!.forClass, rating: reviews.reduce(reviews.first!.rating, combine: { ($0.0 + $0.1.rating) / 2 }), courseLoad: CourseLoad(rawValue: averageLoad), professor: highestProfessor.capitalizedString)
	}
}