//
//  CollectionsViewController.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 3/5/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import UIKit

protocol CollectionsViewControllerDelegate
{
	func numberOfTextbooks() -> Int?
	func numberOfReviews() -> Int?
	func textbookForIndex(index: Int) -> Textbook?
	func removeTextbookAtIndex(index: Int)
	func removeReviewAtIndex(index: Int)
	func reviewForIndex(index: Int) -> Review?
	func getDeleteMode() -> Bool
}
class CollectionsViewController: UIViewController
{
	@IBOutlet var textbookCollections : UICollectionView!
	@IBOutlet var reviewCollections : UICollectionView!
	var delegate : CollectionsViewControllerDelegate?
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func reloadTextbooks()
	{
		textbookCollections.reloadSections(NSIndexSet(index: 0))
	}
	func reloadReviews()
	{
		reviewCollections.reloadSections(NSIndexSet(index: 0))
	}
	
}
extension CollectionsViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		if (collectionView == textbookCollections)
		{
			let numberOfTextbooks = (delegate?.numberOfTextbooks() ?? 1)
			return numberOfTextbooks == 0 ? 1 : numberOfTextbooks
		}
		else if (collectionView == reviewCollections)
		{
			let numberOfReviews = (delegate?.numberOfReviews() ?? 1)
			return numberOfReviews == 0 ? 1 : numberOfReviews
		}
		assert(false)
		return 0
	}
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		if (collectionView == textbookCollections)
		{
			if let textbook = delegate?.textbookForIndex(indexPath.row)
			{
				let cell = collectionView.dequeueReusableCellWithReuseIdentifier("textbookCell", forIndexPath: indexPath) as! TextbookCell
				cell.setDetails(textbook, delegate: self, deleteMode: delegate?.getDeleteMode() ?? false)
				return cell
			}
			else
			{
				var text = "Loading..."
				if (delegate == nil || delegate!.numberOfTextbooks() == nil || delegate!.numberOfTextbooks() == 0)
				{
					text = "No Results Found"
				}
				let cell = collectionView.dequeueReusableCellWithReuseIdentifier("emptyCell", forIndexPath: indexPath) as! EmptyCell
				cell.label.text = text
				cell.setup()
				return cell
			}
		}
		else if (collectionView == reviewCollections)
		{
			if let review = delegate?.reviewForIndex(indexPath.row)
			{
				let cell = collectionView.dequeueReusableCellWithReuseIdentifier("reviewCell", forIndexPath: indexPath) as! ReviewCell
				cell.setDetails(review, delegate: self, deleteMode: delegate?.getDeleteMode() ?? false)
				return cell
			}
			else
			{
				var text = "Loading..."
				if (delegate == nil || delegate!.numberOfReviews() == nil || delegate!.numberOfReviews() == 0)
				{
					text = "No Results Found"
				}
				let cell = collectionView.dequeueReusableCellWithReuseIdentifier("emptyCell", forIndexPath: indexPath) as! EmptyCell
				cell.label.text = text
				cell.setup()
				return cell
			}
		}
		assert(false)
		return UICollectionViewCell()
	}
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
	{
		return CGSize(width: 280, height: collectionView.frame.height * 0.8)
	}
}
extension CollectionsViewController : TextbookCellDelegate, ReviewCellDelegate
{
	func callNumber(number: Double?)
	{
		if let phoneNumber = Int("\(number)")
		{
			let phoneNumberString = "\(phoneNumber)".returnMaskedPhoneText()
			let alertController = UIAlertController(title: "Make a Phone Call", message: "Would you like to make a phone call to \(phoneNumberString)", preferredStyle: UIAlertControllerStyle.Alert)
			alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
			alertController.addAction(UIAlertAction(title: "Call", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
				_ = UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(phoneNumber)")!)
			}))
			presentViewController(alertController, animated: true, completion: nil)
		}
		else
		{
			presentViewController(UIAlertController.errorAlertController(title: "Phone Number Unrecognizable", message: "The phone number was not recognized. Please try emailing or calling instead", error: nil), animated: true, completion: nil)
		}
	}
	func textNumber(number: Double?)
	{
		if let phoneNumber = number
		{
			UIApplication.sharedApplication().openURL(NSURL(string: "SMS:\(phoneNumber)")!)
		}
		else
		{
			presentViewController(UIAlertController.errorAlertController(title: "Phone Number Unrecognizable", message: "The phone number was not recognized. Please try emailing or calling instead", error: nil), animated: true, completion: nil)
		}
	}
	func email(id: String?)
	{
		if let emailID = id
		{
			UIApplication.sharedApplication().openURL(NSURL(string: "mailto:\(emailID)")!)
		}
		else
		{
			presentViewController(UIAlertController.errorAlertController(title: "Email Address Unrecognizable", message: "The email address was not recognized. Please try calling or sending a message instead", error: nil), animated: true, completion: nil)
		}
	}
	func description(textbook: Textbook)
	{
		let alertController = UIAlertController(title: "Textbook for \(textbook.forClass.description)", message: "Title: \(textbook.title)\nVersion: \(textbook.version)\nDescription: \(textbook.description)", preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}
	func description(review: Review)
	{
		let alertController = UIAlertController(title: "Review for \(review.forClass.description)", message: "Description: \(review.description)", preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}
	func flag(objectId: String?, className: String, sender: UIButton)
	{
		if let id = objectId
		{
			if !(delegate?.getDeleteMode() ?? true)
			{
				let alertController = UIAlertController(title: "Flag Post as Inappropriate", message: "Are you sure you want to flag this post as inappropriate? This post would be considered inapporpriate either if the data is invalid or may offend someone.", preferredStyle: UIAlertControllerStyle.ActionSheet)
				alertController.popoverPresentationController?.sourceView = sender
				alertController.popoverPresentationController?.sourceRect = sender.superview!.frame
				alertController.addAction(UIAlertAction(title: "Flag as Inappropriate", style: UIAlertActionStyle.Destructive, handler: {(action) in
					let flagObject = PFObject(className: "FlaggedObjects")
					flagObject["flaggedObjectId"] = objectId
					flagObject["flaggedBy"] = PFUser.currentUser()
					flagObject.saveEventually(nil)
				}))
				alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
				presentViewController(alertController, animated: true, completion: nil)
			}
			else
			{
				let alertController = UIAlertController(title: "Delete This Post", message: "Are you sure you want to delete this post? This action is not reversible.", preferredStyle: UIAlertControllerStyle.ActionSheet)
				alertController.popoverPresentationController?.sourceView = sender
				alertController.popoverPresentationController?.sourceRect = sender.superview!.frame
				alertController.addAction(UIAlertAction(title: "Delete Post", style: UIAlertActionStyle.Destructive, handler: {(action) in
					let object = PFObject(withoutDataWithClassName: className, objectId: objectId!)
					object.deleteInBackgroundWithBlock {(result, error) in
						if (error == nil && result)
						{
							if (className == "Textbook")
							{
								for i in 0..<(self.delegate?.numberOfTextbooks() ?? 0)
								{
									if (self.delegate?.textbookForIndex(i)?.objectId == objectId)
									{
										self.delegate?.removeTextbookAtIndex(i)
										self.textbookCollections.deleteItemsAtIndexPaths([NSIndexPath(forItem: i, inSection: 0)])
										self.textbookCollections.reloadData()
										break
									}
								}
							}
							else if (className == "Review")
							{
								for i in 0..<(self.delegate?.numberOfReviews() ?? 0)
								{
									if (self.delegate?.reviewForIndex(i)?.objectId == objectId)
									{
										self.delegate?.removeReviewAtIndex(i)
										self.reviewCollections.deleteItemsAtIndexPaths([NSIndexPath(forItem: i, inSection: 0)])
										self.reviewCollections.reloadData()
										break
									}
								}
							}
							else
							{
								assert(false)
							}
							
						}
						else
						{
							let alertController = UIAlertController.errorAlertController(title: nil, message: nil, error: error)
						}
					}
				}))
				alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
				presentViewController(alertController, animated: true, completion: nil)
			}
		}
		else
		{
			let alertController = UIAlertController.errorAlertController(title: "An Unknown Error Occurred.", message: "Something went wrong while trying to identify the object you wanted to perform this action on.", error: nil)
			presentViewController(alertController, animated: true, completion: nil)
		}
	}
	
}