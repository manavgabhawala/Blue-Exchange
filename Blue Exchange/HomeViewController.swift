//
//  HomeViewController.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 3/5/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController
{
	@IBOutlet var container : UIView!
	var textbooks = [Textbook]()
	var textbooksCount : Int! = 0
	var reviews = [Review]()
	var reviewsCount : Int! = 0
	var backgroundView : UIView!
	var subController : CollectionsViewController!
	var course : Class? = nil
	var sellerOnly : Bool? = nil
	let activityView = UIActivityIndicatorView(activityIndicatorStyle: .White)
	
	//MARK: - ViewControllerLifecycle
	override func viewDidLoad()
	{
        super.viewDidLoad()
		subController = storyboard!.instantiateViewControllerWithIdentifier("CollectionsViewController") as! CollectionsViewController
		subController.delegate = self
		container.addSubview(subController.view)
		UIApplication.sharedApplication().beginIgnoringInteractionEvents()
		activityView.startAnimating()
		container.addSubview(activityView)
        // Do any additional setup after loading the view.
    }
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)		
		if (!isConnectedToInternet())
		{
			let alert = UIAlertController.errorAlertController(title: "Please Connect To The Internet", message: "This application requires a valid internet connection to function properly. Please establish a valid internet connection before trying to run this application.", error: nil)
			presentViewController(alert, animated: true, completion: nil)
			return
		}
		if (textbooksCount == 0 || textbooks.count != textbooksCount)
		{
			let query = PFQuery(className: "Textbook")
			addSellerConstraintToQuery(query)
			query.countObjectsInBackgroundWithBlock {(number, error) in
				if (error == nil)
				{
					self.textbooksCount = min(Int(number), 40)
					self.loadTextbooks()
					self.subController.reloadTextbooks()
				}
				else
				{
					let alert = UIAlertController.errorAlertController(title: "Please Connect To The Internet", message: "This application requires a valid internet connection to function properly. Please establish a valid internet connection before trying to run this application.", error: error)
					self.presentViewController(alert, animated: true, completion: nil)
				}
				
			}
		}
		if (reviewsCount == 0 || reviews.count != reviewsCount)
		{
			let otherQuery = PFQuery(className: "Review")
			addCourseConstraintToQuery(otherQuery)
			otherQuery.countObjectsInBackgroundWithBlock {(number, error) in
				if (error == nil)
				{
					self.reviewsCount = min(Int(number), 40)
					self.loadReviews()
					self.subController.reloadReviews()
				}
				else
				{
					let alert = UIAlertController.errorAlertController(title: "Please Connect To The Internet", message: "This application requires a valid internet connection to function properly. Please establish a valid internet connection before trying to run this application.", error: error)
					self.presentViewController(alert, animated: true, completion: nil)
				}
			}
		}
		if PFUser.currentUser() == nil
		{
			performSegueWithIdentifier("login", sender: self)
		}
	}
	override func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()
		if backgroundView == nil
		{
			backgroundView = generateRandomBackground(view.frame.size)
			view.addSubview(backgroundView)
			view.sendSubviewToBack(backgroundView)
		}
		activityView.center = CGPoint(x: container.frame.width / 2, y: container.frame.height / 2)
		subController.view.frame.size = container.frame.size
	}
    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	//MARK: - Parse Interaction
	func loadTextbooks()
	{
		if (textbooks.count != textbooksCount)
		{
			let query = PFQuery(className: "Textbook")
			addSellerConstraintToQuery(query)
			query.limit = textbooksCount
			query.includeKey("user")
			query.includeKey("course")
			query.findObjectsInBackgroundWithBlock{(results, error) in
				self.loadEnd()
				if (results != nil && error == nil)
				{
					self.textbooks = (results as! [PFObject]).map { Textbook(object: $0, forClass: Class(object: $0["course"] as! PFObject, subjectCode: ($0["course"] as! PFObject)["subject"] as! String)) }.filter { $0 != nil} .map { $0! }
					self.subController.reloadTextbooks()
				}
				else
				{
					let alertController = UIAlertController.errorAlertController(title: "An Error Occurred While Loading Textbooks", message: nil, error: error)
					self.presentViewController(alertController, animated: true, completion: nil)
				}
			}
		}
		else
		{
			loadEnd()
		}
	}
	func loadEnd()
	{
		if UIApplication.sharedApplication().isIgnoringInteractionEvents()
		{
			UIApplication.sharedApplication().endIgnoringInteractionEvents()
		}
		self.activityView.stopAnimating()
		self.activityView.removeFromSuperview()
	}
	func loadReviews()
	{
		if (reviews.count != reviewsCount)
		{
			let query = PFQuery(className: "Review")
			addCourseConstraintToQuery(query)
			query.limit = reviewsCount
			query.includeKey("user")
			query.includeKey("course")
			query.findObjectsInBackgroundWithBlock{(results, error) in
				if (results != nil && error == nil)
				{
					self.reviews = (results as! [PFObject]).map { Review(object: $0, forClass: Class(object: $0["course"] as! PFObject, subjectCode: ($0["course"] as! PFObject)["subject"] as! String)) }.filter { $0 != nil }.map { $0! }
					if (self.course != nil) && (self.reviews.count > 0)
					{
						self.reviews.insert(Review.createAverageReview(self.reviews), atIndex: 0)
						self.reviewsCount! += 1
					}
					self.subController.reloadReviews()
				}
				else
				{
					let alertController = UIAlertController.errorAlertController(title: "An Error Occurred While Loading Reviews", message: nil, error: error)
					self.presentViewController(alertController, animated: true, completion: nil)
				}
			}
		}
	}
	func addCourseConstraintToQuery(query: PFQuery!)
	{
		if (course != nil)
		{
			let courseObj = PFObject(withoutDataWithClassName: "Classes", objectId: course!.objectId)
			query.whereKey("course", equalTo: courseObj)
		}
		
	}
	func addSellerConstraintToQuery(query: PFQuery!)
	{
		if (sellerOnly != nil)
		{
			query.whereKey("selling", equalTo: sellerOnly)
		}
		addCourseConstraintToQuery(query)
	}
	//MARK: - Actions
	@IBAction func searchButton(_: UIBarButtonItem)
	{
		let searchController = storyboard!.instantiateViewControllerWithIdentifier("SearchAndComposeViewController") as! SearchAndComposeViewController
		searchController.composing = false
		navigationController?.pushViewController(searchController, animated: true)
	}
	@IBAction func composeButton(_: UIBarButtonItem)
	{
		let composeController = storyboard!.instantiateViewControllerWithIdentifier("SearchAndComposeViewController") as! SearchAndComposeViewController
		composeController.composing = true
		navigationController?.pushViewController(composeController, animated: true)
	}
	@IBAction func profileButton(_: UIBarButtonItem)
	{
		
	}
}

extension HomeViewController : CollectionsViewControllerDelegate
{
	func numberOfTextbooks() -> Int?
	{
		return textbooksCount
	}
	func numberOfReviews() -> Int?
	{
		return reviewsCount
	}
	func textbookForIndex(index: Int) -> Textbook?
	{
		if (index >= 0 && index < textbooks.count)
		{
			return textbooks[index]
		}
		else
		{
			return nil
		}
	}
	func reviewForIndex(index: Int) -> Review?
	{
		if (index >= 0 && index < reviews.count)
		{
			return reviews[index]
		}
		else
		{
			return nil
		}
	}
}