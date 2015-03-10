//
//  Generic Extensions.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 3/4/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import Foundation
import SystemConfiguration

extension UIView
{
	/**
	This is an extension to UIView which will create a standard shake animation to indicate to the user that something went wrong.
	
	:see: shake:
	*/
	func shakeForInvalidInput()
	{
		shake(iterations: 7, direction: 1, currentTimes: 0, size: 25, interval: 0.1)
		if let textField = self as? UITextField
		{
			if textField.secureTextEntry
			{
				textField.text = ""
			}
		}
	}
	
	/**
	This function shakes a UIView with a spring timing curve using the parameters to create the animations.
	
	:param: iterations   The number of times to shake the view back and forth before stopping
	:param: direction    The direction in which to move the view for the first time
	:param: currentTimes The number of times the function has been performed. Use 0 to begin with.
	:param: size         The size of the shake. i.e. how much to move the view
	:param: interval     The amount of time for each 'shake'.
	*/
	func shake(#iterations: Int, direction: Int, currentTimes: Int, size: CGFloat, interval: NSTimeInterval)
	{
		UIView.animateWithDuration(interval, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 10, options: .allZeros, animations: {() in
			self.transform = CGAffineTransformMakeTranslation(size * CGFloat(direction), 0)
			}, completion: {(finished) in
				if (currentTimes >= iterations)
				{
					UIView.animateWithDuration(interval, animations: {() in
						self.transform = CGAffineTransformIdentity
					})
					return
				}
				self.shake(iterations: iterations - 1, direction: -direction, currentTimes: currentTimes + 1, size: size, interval: interval)
		})
	}
}

extension String
{
	/**
	*  This subscript function gives quick access to a String's character with the position passed in by the substring.
	:Code: var myString = "Hello World"
	myString[4] //returns "o"
	:Returns: A string with the character at the index passed in through the subscript.
	:Warning: This function returns an empty String if the index is out of bounds.
	*/
	subscript (i: Int) -> String
	{
		if countElements(self) > i
		{
			return String(Array(self)[i])
		}
		return ""
	}
	
	/**
	A quick access function that creates a String.Index object which is required in Swift instead of just an index.
	
	:param: theInt The index value that you want the String.Index to refer to.
	
	:returns: The return value is a String.Index object which has the index you would like.
	*/
	func indexAt(theInt: Int) -> String.Index
	{
		return advance(self.startIndex, theInt)
	}
	
	/**
	This function is performed on a string and removes all the formatting/unnecessary characters and returns a String with just numbers in it. This is useful for formatting prices, phone numbers, etc.
	
	:returns: The string with just numbers in it.
	*/
	func returnActualNumber() -> String
	{
		var returnString = stringByTrimmingCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
		returnString = returnString.stringByReplacingOccurrencesOfString(" ", withString: "")
		returnString = returnString.stringByReplacingOccurrencesOfString("-", withString: "")
		returnString = returnString.stringByReplacingOccurrencesOfString("(", withString: "")
		returnString = returnString.stringByReplacingOccurrencesOfString(")", withString: "")
		returnString = returnString.stringByReplacingOccurrencesOfString("+", withString: "")
		return returnString
	}
	/**
	This function can be performed on a string to make a masked string which has number formattings such as +, (, ) and -'s.
	
	:returns: Returns a string that contains the number masked to be in a correct format.
	*/
	func returnMaskedPhoneText() -> String
	{
		var returnString = self
		//Trims non-numerical characters
		returnString = returnString.returnActualNumber()
		
		//Formats mobile number with parentheses and spaces
		if (countElements(returnString) <= 10)
		{
			if (countElements(returnString) > 6)
			{
				returnString = returnString.stringByReplacingCharactersInRange(Range<String.Index>(start: returnString.indexAt(6), end: returnString.indexAt(6)), withString: "-")
			}
			if (countElements(returnString) > 3)
			{
				returnString = returnString.stringByReplacingCharactersInRange(Range<String.Index>(start: returnString.indexAt(3), end: returnString.indexAt(3)), withString: ") ")
			}
			if (countElements(returnString) > 0)
			{
				returnString = returnString.stringByReplacingCharactersInRange(Range<String.Index>(start: returnString.indexAt(0), end: returnString.indexAt(0)), withString: "(")
			}
		}
		else
		{
			returnString = "+" + ((returnString as NSString).substringToIndex(countElements(returnString) - 10) as String) + " " + ((returnString as NSString).substringFromIndex(countElements(returnString) - 10) as String).returnMaskedPhoneText()
		}
		return returnString
	}
	/**
	This function changes the string its called on to make it a valid UM ID. It does this by appending @umich.edu and removing any text after and including an @ sign in the original String.
	*/
	mutating func makeUMichID()
	{
		var text = lowercaseString
		var uniqname = ""
		for character in text
		{
			if (character == "@")
			{
				break
			}
			else
			{
				uniqname = "\(uniqname)\(character)"
			}
		}
		text = uniqname
		if !(text.hasSuffix("@umich.edu") || text.isEmpty)
		{
			text = text + "@umich.edu"
		}
		self = text
	}
	/**
	Check's if self contains a valid email address.
	
	:returns: returns true if the email address provided was valid. False otherwise.
	*/
	func isValidEmail() -> Bool
	{
		if (self.isEmpty)
		{
			return false;
		}
		let regex = NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: .CaseInsensitive, error: nil)
		return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, countElements(self))) != nil
	}
	
	/**
	Converts a string to a native Float type if one exists else it returns nil
	
	:returns: Returns a Float or nil from the string the function is called on.
	*/
	func floatValue () -> Float?
	{
		let number = (self as NSString).floatValue
		if (number == 0.0 || number == HUGE || number == -HUGE)
		{
			return nil
		}
		return number
	}
	
	/**
	Capitalizes a string using sentence case.
	
	:returns: A sentence cased copy of self.
	*/
	func sentenceCapitalizedString() -> String
	{
		var formattedString = ""
		let range = Range(start: self.startIndex, end: self.endIndex)
		self.enumerateSubstringsInRange(range, options: .BySentences, {(sentence, sentenceRange, enclosingRange, stop) in
			formattedString += sentence.stringByReplacingCharactersInRange(Range(start: self.startIndex, end: advance(self.startIndex, 1)), withString: sentence[0].uppercaseString)
		})
		if (formattedString[countElements(formattedString) - 1] != ".")
		{
			formattedString += "."
		}
		return formattedString
	}
}

extension UIAlertController
{
	/**
	A quick access function that returns an instance of a UIAlertController with the generic title an Error occured.
	:param: title
	:param: message An optional string which is the message that will be displayed. If the string is a nil the default message: "An error occurred while loading the data from the internet. Please check your internet connection and try again." will be displayed.
	:param: error An optional error whose value will take precedence over the message specified.
	:return: This function returns a UIAlertController instance with a dismiss action provided and can directly be displayed using the presentViewController function.
	*/
	class func errorAlertController(title tit: String?, message msg: String?, error: NSError?) -> UIAlertController
	{
		let title = tit ?? "An Error Occurred"
		let message = error?.userInfo?["error"] as? String ?? msg ?? "An error occurred while communicating with our servers. Please check that you have a valid internet connection and try again."
		let alertController = UIAlertController(title: title.sentenceCapitalizedString(), message: message.sentenceCapitalizedString(), preferredStyle: UIAlertControllerStyle.Alert)
		alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
		return alertController
	}
}
extension UIImage
{
	/**
	Returns an randomly generated, instantiated UIImage from the background images available to the app.
	
	:returns: The UIImage object that was generated and can be used as if the Image was made.
	*/
	class func generateRandomBackground() -> UIImage
	{
		let numberOfBackgrounds : UInt32 = 2
		let background = "Background\((arc4random() % numberOfBackgrounds) + 1).jpg"
		return UIImage(named: background)!
	}
}
extension UIColor
{
	/**
	This function returns the UM Maize color
	
	:returns: An initialized UIColor
	*/
	class func umMaizeColor() -> UIColor
	{
		return UIColor(red: 1.0, green: 0.811, blue: 0.0, alpha: 1.0)
	}
	/**
	This function returns the UM Blue color.
	
	:returns: An initialized UIColor
	*/
	class func umBlueColor() -> UIColor
	{
		return UIColor(red: 0.0, green: 0.15, blue: 0.28, alpha: 1.0)
	}
}

extension Array
{
	mutating func append(array: Array<T>)
	{
		array.map { self.append($0) }
	}
}
/**
A quick access function that opens a twitter page for a given user. If the app is installed, the twitter app will open with that user's page otherwise it will open in Safari.

:param: user The user's twitter handle name.
*/
func openTwitterPage(user: String)
{
	let URL = NSURL(string: "twitter:///user?screen_name=\(user))")!
	if (UIApplication.sharedApplication().canOpenURL(URL))
	{
		UIApplication.sharedApplication().openURL(URL)
	}
	else
	{
		UIApplication.sharedApplication().openURL(NSURL(string: "https://twitter.com/\(user)")!)
	}
}

/**
Returns an randomly generated, instantiated UIImage from the background images available to the app.
:param: size The size of the frame that the background image should be.
:returns: The a background view that with a random image and blur on top if it.
*/
func generateRandomBackground(size: CGSize) -> UIView
{
	let numberOfBackgrounds : UInt32 = 2
	let background = "Background\((arc4random() % numberOfBackgrounds) + 1).jpg"
	let imageView = UIImageView(image: UIImage(named: background) ?? UIImage(named: "Background0.jpg")!)
	imageView.frame.size = size
	imageView.contentMode = .ScaleAspectFill
	imageView.clipsToBounds = true
	let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
	blurView.frame.size = size
	let containerView = UIView(frame: CGRect(origin: CGPointZero, size: size))
	containerView.addSubview(imageView)
	containerView.addSubview(blurView)
	return containerView
}

func isConnectedToInternet() -> Bool
{
	let zero : Int8 = 0
	var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
	zeroAddress.sin_len = UInt8(sizeof(sockaddr_in.Type))
	zeroAddress.sin_family = UInt8(AF_INET)
	zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
	zeroAddress.sin_family = sa_family_t(AF_INET)
	
	let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
		SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
	}
	
	var flags : SCNetworkReachabilityFlags = 0
	if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
		return false
	}
	
	let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
	let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
	return (isReachable && !needsConnection)
}

typealias TableSectionCells = [UITableViewCell]

func allKeysForValue<K, V : Equatable>(dict: [K : V], val: V) -> [K]
{
	return map(filter(dict) { $1 == val }) { $0.0 }
}