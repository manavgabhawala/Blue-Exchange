//
//  ProfileViewController.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 3/8/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController
{
	//MARK: - ViewController Lifecycle
	var background : UIView?
	@IBOutlet var profileImageView : UIImageView!
	@IBOutlet var nameLabel : UILabel!
	let user = PFUser.currentUser()
	override func viewDidLoad()
	{
		super.viewDidLoad()
		nameLabel.text = (user["firstName"] as? String ?? "John") + " " + (user["lastName"] as? String ?? "Doe")
		let someLayer = profileImageView.layer
		someLayer.cornerRadius = profileImageView.frame.width / 2
		someLayer.masksToBounds = true
		if let fbId = user["fbId"] as? String
		{
			let profilePictureURL = NSURL(string: "https://graph.facebook.com/\(fbId)/picture?type=large&return_ssl_resources=1")!
			let request = NSURLRequest(URL: profilePictureURL)
			NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {(response, data, error) in
				if (error == nil)
				{
					if let image = UIImage(data: data)
					{
						self.profileImageView.image = image
						self.profileImageView.setNeedsDisplay()
					}
				}
			})
		}
	}
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
	}
	override func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()
		if background == nil
		{
			background = generateRandomBackground(view.frame.size)
			tableView.backgroundView = background
		}
	}
	//MARK: - Actions
	@IBAction func doneButton(_: UIBarButtonItem)
	{
		dismissViewControllerAnimated(true, completion: nil)
	}
	@IBAction func showMyPosts(_: UIButton)
	{
		let homeViewController = storyboard!.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
		homeViewController.deleteMode = true
		homeViewController.navigationItem.rightBarButtonItem = nil
		homeViewController.navigationItem.leftBarButtonItem = nil
		self.navigationController?.pushViewController(homeViewController, animated: true)
	}
	@IBAction func changePassword(_ : UIButton)
	{
		if let username = PFUser.currentUser().username
		{
			PFUser.requestPasswordResetForEmailInBackground(username, target: self, selector: "passwordReset:")
		}
		else
		{
			presentViewController(UIAlertController.errorAlertController(title: "No User Found", message: "You have not been securely logged in. Please close the app and try logging in securely. Then reset your password from the login screen or here.", error: nil), animated: true, completion: nil)
		}
	}
	@IBAction func logout(_ : UIButton)
	{
		PFUser.logOut()
		self.dismissViewControllerAnimated(true, completion: nil)
	}
}

