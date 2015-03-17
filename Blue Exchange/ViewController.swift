//
//  ViewController.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 3/4/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import UIKit

private enum Fields : Int
{
	case FirstName = 0
	case LastName, Email, PhoneNumber, Password, ConfirmPassword
}
class ViewController: UIViewController {

	var textFields = [UITextField]()
	var signUpMode = false
	@IBOutlet var scrollView : UIScrollView!
	@IBOutlet var switchButton : UIButton!
	@IBOutlet var actionButton : UIButton!
	var backgroundView : UIView!
	
	
	//MARK: ViewController Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: "UIKeyboardWillShowNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHidden:", name: "UIKeyboardWillHideNotification", object: nil)
		setupLoginFields()
		if let _ = PFUser.currentUser()
		{
			dismissViewControllerAnimated(true, completion: nil)
		}
	}
	override func viewDidDisappear(animated: Bool)
	{
		super.viewDidDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: "UIKeyboardWillShowNotification", object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: "UIKeyboardWillHideNotification", object: nil)
	}
	override func viewDidLayoutSubviews()
	{
		if (backgroundView == nil)
		{
			backgroundView = generateRandomBackground(view.frame.size)
			view.addSubview(backgroundView)
			view.sendSubviewToBack(backgroundView)
		}
	}
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

//MARK: Actions
extension ViewController
{
	func fieldsAreEmpty() -> Bool
	{
		var shouldReturn = false
		for textField in textFields
		{
			textField.resignFirstResponder()
			if (textField.text.isEmpty)
			{
				textField.shakeForInvalidInput()
				shouldReturn = true
			}
		}
		return shouldReturn
	}
	@IBAction func loginWithFacebook(_ : UIButton)
	{
		PFFacebookUtils.logInWithPermissions(["public_profile", "email"], block: {(user, error) in
			if (user != nil && error == nil)
			{
				FBRequestConnection.startForMeWithCompletionHandler({(connection, result, error) in
					if (error == nil)
					{
						user["fbId"] = result.objectForKey("id")
						if let firstName = result.objectForKey("first_name") as? String
						{
							user["firstName"] = firstName
						}
						if let lastName = result.objectForKey("last_name") as? String
						{
							user["lastName"] = lastName
						}
						if let email = result.objectForKey("email") as? String
						{
							user["email"] = email
						}
						let currentInstallation = PFInstallation.currentInstallation()
						currentInstallation["user"] = user
						user.saveInBackgroundWithBlock(nil)
						currentInstallation.saveInBackgroundWithBlock(nil)
						self.dismissViewControllerAnimated(true, completion: nil)
					}
					else
					{
						let controller = UIAlertController.errorAlertController(title: "Facebook Sign Up Error", message: nil, error: error)
					}
				})
			}
			else
			{
				let controller = UIAlertController.errorAlertController(title: "Facebook Sign Up Error", message: "An error occurred while trying to contact our servers to sign you up. Please check your network connection and try again.", error: error)
				self.presentViewController(controller, animated: true, completion: nil)
			}
		})
	}
	@IBAction func signupButton(_ : UIButton)
	{
		if signUpMode
		{
			var shouldReturn = false
			if (fieldsAreEmpty())
			{
				return
			}
			if (!textFields[Fields.Email.rawValue].text.isValidEmail())
			{
				textFields[Fields.Email.rawValue].shakeForInvalidInput()
				shouldReturn = true
			}
			if (Array(textFields[Fields.Password.rawValue].text).count < 6)
			{
				textFields[Fields.Password.rawValue].shakeForInvalidInput()
				shouldReturn = true
			}
			if (textFields[Fields.Password.rawValue].text != textFields[Fields.ConfirmPassword.rawValue].text)
			{
				textFields[Fields.ConfirmPassword.rawValue].shakeForInvalidInput()
				shouldReturn = true
			}
			if (shouldReturn)
			{
				return
			}
			var user = PFUser()
			user.username = textFields[Fields.Email.rawValue].text
			user.password = textFields[Fields.Password.rawValue].text
			user.email = textFields[Fields.Email.rawValue].text
			user["phone"] = textFields[Fields.PhoneNumber.rawValue].text.returnActualNumber().toInt() ?? 0
			user["firstName"] = textFields[Fields.FirstName.rawValue].text
			user["lastName"] = textFields[Fields.LastName.rawValue].text
			user.signUpInBackgroundWithBlock {(completed, error) in
				if (completed && error == nil)
				{
					let currentInstallation = PFInstallation.currentInstallation()
					currentInstallation["user"] = PFUser.currentUser()
					currentInstallation.saveEventually(nil)
					self.dismissViewControllerAnimated(true, completion: nil)
				}
				else
				{
					let controller = UIAlertController.errorAlertController(title: "Sign Up Error", message: "An error occurred while trying to contact our servers to sign you up. Please check your network connection and try again.", error: error)
					self.presentViewController(controller, animated: true, completion: nil)
				}
			}
		}
		else
		{
			if (fieldsAreEmpty())
			{
				return
			}
			var shouldReturn = false
			if (!textFields.first!.text.isValidEmail())
			{
				textFields[Fields.Email.rawValue].shakeForInvalidInput()
				shouldReturn = true
			}
			PFUser.logInWithUsernameInBackground(textFields.first!.text, password: textFields.last!.text)
			{ (user: PFUser!, error: NSError!) -> Void in
				if user != nil && error == nil
				{
					let currentInstallation = PFInstallation.currentInstallation()
					currentInstallation["user"] = user
					currentInstallation.saveEventually(nil)
					self.dismissViewControllerAnimated(true, completion: nil)
				}
				else
				{
					if (error != nil)
					{
						let controller = UIAlertController.errorAlertController(title: "An Error Occurred While Logging In", message: nil, error: error)
					}
					self.textFields.last!.shakeForInvalidInput()
				}
			}
		}
	}
	@IBAction func switchToLogin(_: UIButton)
	{
		signUpMode = !signUpMode
		if signUpMode
		{
			setupSignupFields()
			actionButton.setTitle("Sign Up", forState: .Normal)
			switchButton.setTitle("Have an account? Login Here", forState: .Normal)
		}
		else
		{
			setupLoginFields()
			actionButton.setTitle("Login", forState: .Normal)
			switchButton.setTitle("I don't have an account yet", forState: .Normal)
		}
	}
}

//MARK: Sign Up Table
extension ViewController
{
	func emptyScrollViewTowardsRight(right: Bool)
	{
		let _ :[Void] = scrollView.subviews.filter { !($0 is UIImageView) }.map {
			let view = $0 as UIView
			UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: {
				if (right)
				{
					view.frame.origin.x = self.view.frame.width
				}
				else
				{
					view.frame.origin.x = -view.frame.width
				}
			}, completion: {(completed) in
				if (completed) {
					view.removeFromSuperview() }
			})
		}
	}
	func animateTextFieldsMoveIn()
	{
		let _ :[Void] = textFields.map { (field) in
			UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: { field.center.x = self.view.frame.width / 2 - self.scrollView.frame.origin.x }, completion: nil)
		}
	}
	func setupSignupFields()
	{
		let numberOfFields = 6
		emptyScrollViewTowardsRight(true)
		scrollView.keyboardDismissMode = .Interactive
		let contentView = UIView()
		scrollView.bouncesZoom = false
		let totalHeight = scrollView.frame.height
		let width = view.frame.width * 0.75
		let centerX = view.frame.width / 2 - scrollView.frame.origin.x
		let attributes : [NSObject: AnyObject] = [NSForegroundColorAttributeName: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.6)]
		let textFieldHeight : CGFloat = 30
		let textFieldSpace : CGFloat = (totalHeight - (CGFloat(numberOfFields) * textFieldHeight)) / CGFloat(numberOfFields)
		textFields = (0..<numberOfFields).map{
			let textField = UITextField()
			textField.textAlignment = .Center
			textField.textColor = UIColor.whiteColor()
			textField.autocapitalizationType = UITextAutocapitalizationType.None
			textField.autocorrectionType = UITextAutocorrectionType.No
			textField.borderStyle = UITextBorderStyle.None
			textField.layer.cornerRadius = 8.0
			textField.layer.masksToBounds = true
			textField.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.4).CGColor
			textField.layer.borderWidth = 0.5
			textField.backgroundColor = UIColor.clearColor()
			textField.keyboardAppearance = UIKeyboardAppearance.Dark
			textField.keyboardType = UIKeyboardType.ASCIICapable
			textField.clearButtonMode = UITextFieldViewMode.WhileEditing
			textField.returnKeyType = UIReturnKeyType.Next
			textField.frame.size = CGSize(width: width, height: textFieldHeight)
			textField.frame.origin.x = -width
			textField.frame.origin.y = (CGFloat($0) * (textFieldHeight + (textFieldSpace))) + textFieldSpace / 2
			textField.font = UIFont(name: "HelveticaNeue-Light", size: 17)
			textField.delegate = self
			contentView.addSubview(textField)
			return textField
		}
		textFields[Fields.FirstName.rawValue].attributedPlaceholder = NSAttributedString(string: "First Name", attributes: attributes)
		textFields[Fields.FirstName.rawValue].autocapitalizationType = UITextAutocapitalizationType.Words
		
		textFields[Fields.LastName.rawValue].attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: attributes)
		textFields[Fields.LastName.rawValue].autocapitalizationType = UITextAutocapitalizationType.Words
		
		textFields[Fields.Email.rawValue].attributedPlaceholder = NSAttributedString(string: "Email ID or UM Uniqname", attributes: attributes)
		textFields[Fields.Email.rawValue].keyboardType = UIKeyboardType.EmailAddress
		
		textFields[Fields.PhoneNumber.rawValue].attributedPlaceholder = NSAttributedString(string: "Phone Number", attributes: attributes)
		textFields[Fields.PhoneNumber.rawValue].keyboardType = UIKeyboardType.PhonePad
		textFields[Fields.PhoneNumber.rawValue].autocapitalizationType = UITextAutocapitalizationType.None
		textFields[Fields.PhoneNumber.rawValue].keyboardAppearance = UIKeyboardAppearance.Dark
		textFields[Fields.PhoneNumber.rawValue].returnKeyType = UIReturnKeyType.Default
		textFields[Fields.PhoneNumber.rawValue].addTarget(self, action: "phoneNumberMask:", forControlEvents: UIControlEvents.EditingChanged)
		
		textFields[Fields.Password.rawValue].attributedPlaceholder = NSAttributedString(string: "Password", attributes: attributes)
		textFields[Fields.Password.rawValue].secureTextEntry = true
		
		textFields[Fields.ConfirmPassword.rawValue].attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: attributes)
		textFields[Fields.ConfirmPassword.rawValue].returnKeyType = UIReturnKeyType.Go
		textFields[Fields.ConfirmPassword.rawValue].secureTextEntry = true
		contentView.frame.size = CGSize(width: scrollView.frame.width, height: CGFloat(numberOfFields) * (textFieldHeight + textFieldSpace))
		
		scrollView.contentSize = contentView.frame.size
		scrollView.addSubview(contentView)
		animateTextFieldsMoveIn()
	}
	func setupLoginFields()
	{
		textFields.removeAll(keepCapacity: false)
		let numberOfFields = 2
		emptyScrollViewTowardsRight(false)
		let attributes : [NSObject: AnyObject] = [NSForegroundColorAttributeName: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.6)]
		let width = view.frame.width * 0.75
		let textFieldHeight : CGFloat = 30
		let contentView = UIView()
		for i in 0..<numberOfFields
		{
			let textField : UITextField = UITextField()
			textField.textAlignment = .Center
			textField.textColor = UIColor.whiteColor()
			textField.autocapitalizationType = .None
			textField.autocorrectionType = .No
			textField.borderStyle = .None
			textField.layer.cornerRadius = 8.0
			textField.layer.masksToBounds = true
			textField.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.4).CGColor
			textField.layer.borderWidth = 0.5
			textField.backgroundColor = UIColor.clearColor()
			textField.keyboardAppearance = UIKeyboardAppearance.Dark
			textField.keyboardType = .ASCIICapable
			textField.clearButtonMode = .WhileEditing
			textField.returnKeyType = .Next
			textField.frame.size = CGSize(width: width, height: textFieldHeight)
			textField.frame.origin.x = view.frame.width
			textField.frame.origin.y = (CGFloat(i) * 100) + 50
			textField.font = UIFont(name: "HelveticaNeue-Light", size: 17)
			textField.delegate = self
			textFields.append(textField)
			contentView.addSubview(textField)
		}
		textFields.first!.attributedPlaceholder = NSAttributedString(string: "Email ID or UM Uniqname", attributes: attributes)
		textFields.first!.keyboardType = .EmailAddress
		textFields.last!.attributedPlaceholder = NSAttributedString(string: "Password", attributes: attributes)
		textFields.last!.secureTextEntry = true
		textFields.last!.returnKeyType = .Go
		contentView.frame.size = CGSize(width: scrollView.frame.width, height: 150 + textFieldHeight)
		scrollView.contentSize = contentView.frame.size
		scrollView.addSubview(contentView)
		animateTextFieldsMoveIn()
	}
}
extension ViewController : UITextFieldDelegate
{
	/**
	This is a callback function that is called when the user hits the return key on the keyboard
	
	:param: textField The textfield on which has the first responder when the return key is pressed
	
	:returns: Returns whether this should result in normal behaviour or not.
	*/
	func textFieldShouldReturn(textField: UITextField) -> Bool
	{
		textField.resignFirstResponder()
		for i in 0..<(textFields.count-1)
		{
			if (textField == textFields[i])
			{
				textFields[i + 1].becomeFirstResponder()
				return true
			}
		}
		signupButton(UIButton())
		return true
	}
	
	/**
	This is a callback function that is called when the user finishes editing a text field.
	
	:param: textField The textfield which just finished editing.
	:discussion: This manages validating and formatting the uniqname after the user finishes writing to the text field.
	*/
	func textFieldDidEndEditing(textField: UITextField)
	{
		if (signUpMode && textField == textFields[Fields.Email.rawValue]) || (!signUpMode && textField == textFields[0])
		{
			if (!textField.text.isValidEmail())
			{
				textField.text.makeUMichID()
			}
		}
	}
	/**
	This is a callback function that is called when the user finishes editing a text field.
	
	:param: textField The textfield which just finished editing.
	:discussion: This manages scrolling the view to the right amount so that the field being edited is always shown to the user.
	
	*/
	func textFieldDidBeginEditing(textField: UITextField)
	{
		if (!scrollView.frame.contains(textField.frame.origin))
		{
			self.scrollView.scrollRectToVisible(textField.frame, animated: true)
		}
	}
	/**
	A registered notification callback for when the keyboard is shown because the user tapped on a textfield.
	
	:param: notification The notification that the keyboard is now shown.
	:discussion: This function deals with creating an offset for the scroll view whenever the keyboard is shown so that the view does not think that it has the entire screen to draw in rather it has the screen minus the height of the keyboard.
	*/
	func keyboardShown (notification: NSNotification)
	{
		var info = notification.userInfo!
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
		{
			let maxY = scrollView.frame.height + scrollView.frame.origin.y
			let heightIntersect = maxY - (view.frame.height - keyboardSize.height)
			if heightIntersect > 0
			{
				var contentInsets = UIEdgeInsetsMake(0.0, 0.0, heightIntersect, 0.0)
				scrollView.contentInset = contentInsets
				scrollView.scrollIndicatorInsets = contentInsets
			}
			var rect = view.frame
			rect.size.height -= keyboardSize.height
			var activeField = UIView()
			for textField in textFields
			{
				if textField.isFirstResponder()
				{
					activeField = textField
					break
				}
			}
			if (!rect.contains(activeField.frame.origin))
			{
				scrollView.scrollRectToVisible(activeField.frame, animated: true)
			}
		}
	}
	
	/**
	A registered notification callback for when the keyboard is shown because the textfields lost responder.
	
	:param: notification The notification that the keyboard is now hidden.
	:discussion: This function deals with removing the offset created for the scroll view whenever the keyboard is hidden so that now the view knows that it has the entire screen to draw on again.
	*/
	func keyboardHidden (notification: NSNotification)
	{
		var contentInsets = UIEdgeInsetsZero
		scrollView.contentInset = contentInsets
		scrollView.scrollIndicatorInsets = contentInsets
	}
	/**
	This function handles callbacks for when the phone number field is being edited and is called each time a button on the keyboard is pressed.
	
	:param: sender The phone number text field.
	*/
	func phoneNumberMask(textField: UITextField)
	{
		if textField == textFields[Fields.PhoneNumber.rawValue]
		{
			//Setting cursor position.
			if let currentCursorPosition = textFields[Fields.PhoneNumber.rawValue].selectedTextRange
			{
				var isEndOfString = false
				let currentCurserPositionInteger = textField.offsetFromPosition(textField.beginningOfDocument, toPosition: currentCursorPosition.start)
				if currentCurserPositionInteger == countElements(textField.text)
				{
					isEndOfString = true
				}
				textFields[Fields.PhoneNumber.rawValue].text = textField.text.returnMaskedPhoneText()
				
				if isEndOfString == false
				{
					textFields[Fields.PhoneNumber.rawValue].selectedTextRange = currentCursorPosition
				}
			}
			else
			{
				textFields[Fields.PhoneNumber.rawValue].text = textField.text.returnMaskedPhoneText()
			}
		}
	}
}
