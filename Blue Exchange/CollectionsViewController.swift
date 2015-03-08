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
	func reviewForIndex(index: Int) -> Review?
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
				cell.setDetails(textbook)
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
				cell.setDetails(review)
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