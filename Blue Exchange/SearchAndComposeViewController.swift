//
//  SearchAndComposeViewController.swift
//  Blue Exchange
//
//  Created by Manav Gabhawala on 3/6/15.
//  Copyright (c) 2015 Manav Gabhawala. All rights reserved.
//

import UIKit

class SearchAndComposeViewController: UIViewController
{
	var composing = false
	var tableCells = [UITableViewCell]()
	
	var schools = [School]()
	
	var schoolCell = CustomDetailCell()
	var subjectCell = CustomDetailCell()
	var classCell = CustomDetailCell()
	
	var titleCell : TextFieldCell!
	var versionCell : TextFieldCell!
	var professorCell : TextFieldCell!
	
	var currentSchoolIndex = 0
	var currentSubjectIndex = 0
	var currentClassIndex = 0
	
	var backgroundView : UIView!
	
	var currentSchool : School
	{
		get
		{
			return schools[currentSchoolIndex]
		}
	}
	var currentSubject : Subject
	{
		get
		{
			return currentSchool.subjects[currentSubjectIndex]
		}
	}
	var currentClass : Class
	{
		get
		{
			return currentSchool.subjects[currentSubjectIndex].classes[currentClassIndex]
		}
	}
	var selectedCell : CustomDetailCell?
	
	@IBOutlet var tableView: UITableView!
	var oppositeItem : UIBarButtonItem? = nil
	
	var segmentControl = UISegmentedControl()
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: "UIKeyboardWillShowNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHidden:", name: "UIKeyboardWillHideNotification", object: nil)
		
		let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done:")
		navigationItem.setRightBarButtonItem(doneButton, animated: true)
		schools = [School()]
		loadCells(0)
	}
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		if oppositeItem == nil
		{
			if composing
			{
				oppositeItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "switchComposing:")
			}
			else
			{
				oppositeItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "switchComposing:")
			}
			var items = navigationController?.toolbar.items!
			items?.append(oppositeItem!)
			navigationController?.toolbar.setItems(items, animated: true)
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
	}
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	/**
	This is a helper function that dims the labels of the other cells so that when selecting from the picker it is evident what you are selecting for.
	*/
	func dimCells ()
	{
		tableCells.filter { $0 is PickerCell } .map { ($0 as! PickerCell).picker.reloadAllComponents() }
		if (selectedCell != nil)
		{
			for cell in tableCells
			{
				if (cell is CustomDetailCell && cell != selectedCell)
				{
					(cell as! CustomDetailCell).valueLabel.alpha = 0.3
				}
				else if (cell is CustomDetailCell)
				{
					(cell as! CustomDetailCell).valueLabel.alpha = 1.0
				}
			}
		}
		else
		{
			for cell in tableCells
			{
				if (cell is CustomDetailCell)
				{
					(cell as! CustomDetailCell).valueLabel.alpha = 1.0
				}
			}
		}
	}
	func segmentChange(segmentControl: UISegmentedControl)
	{
		if (composing)
		{
			loadCells(segmentControl.selectedSegmentIndex)
		}
	}
	func switchComposing(_ : UIBarButtonItem)
	{
		composing = !composing
		if composing
		{
			oppositeItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "switchComposing:")
		}
		else
		{
			oppositeItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "switchComposing:")
		}
		var items = navigationController?.toolbar.items!
		items?.removeLast()
		items?.append(oppositeItem!)
		navigationController?.toolbar.setItems(items, animated: true)
		loadCells(segmentControl.selectedSegmentIndex)
	}
	func done(_: UIBarButtonItem)
	{
		if (composing)
		{
			
		}
		else
		{
			let results = storyboard!.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
			results.course = currentClass
			if (segmentControl.selectedSegmentIndex != 2)
			{
				results.sellerOnly = Bool(segmentControl.selectedSegmentIndex)
			}
			results.title = "Search Results"
			results.navigationItem.leftBarButtonItem = results.navigationItem.backBarButtonItem
			results.navigationItem.rightBarButtonItem = nil
			navigationController?.pushViewController(results, animated: true)
		}
	}
}
//MARK: - Parse Database Interaction
extension SearchAndComposeViewController
{
	/**
	This function interacts with Parse to load all the schools in a local array. It calls loadSubjects to load the current subjects based on the selected school.
	*/
	func loadAllSchools()
	{
		if (schools.first?.code != nil)
		{
			setPickerCells(School)
			dimCells()
			return
		}
		let query = PFQuery(className: "Schools")
		for cell in [schoolCell, subjectCell, classCell]
		{
			addActivityIndicatorForCell(cell)
		}
		query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) in
			self.removeActivityIndicatorForCell(self.schoolCell)
			if (error == nil)
			{
				if (objects.count == 0)
				{
					self.schools.append(School())
				}
				else
				{
					self.schools = (objects as! [PFObject]).map {
						School(object: $0) }
				}
				self.setPickerCells(School)
				if (self.selectedCell == self.schoolCell)
				{
					let indexPath = NSIndexPath(forRow: self.tableView.indexPathForCell(self.schoolCell)!.row + 1, inSection: self.tableView.indexPathForCell(self.schoolCell)!.section)
					let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! PickerCell
					cell.picker.reloadAllComponents()
					self.dimCells()
				}
				self.loadSubjects()
			}
			else
			{
				let alertController = UIAlertController.errorAlertController(title: "Error While Loading Schools", message: "There was an error while loading the schools from our servers. Please check your network connection and try again", error: error)
				self.presentViewController(alertController, animated: true, completion: nil)
			}
		}
	}
	
	/**
	This function interacts with Parse to load the current subjects. It checks if a local cache exists, and if it does it uses that otherwise it calls Parse to load the subjects for the current school and saves it to the local cache.
	*/
	func loadSubjects()
	{
		if (currentSchool.subjects.first?.code == nil)
		{
			setPickerCells(Subject)
			if let schoolCode = currentSchool.code
			{
				for cell in [subjectCell, classCell]
				{
					addActivityIndicatorForCell(cell)
				}
				let query = PFQuery(className: "Subjects")
				query.whereKey("school", equalTo: schoolCode)
				query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) in
					self.removeActivityIndicatorForCell(self.subjectCell)
					if (error == nil)
					{
						self.currentSchool.addSubjects(objects as! [PFObject])
						self.setPickerCells(Subject)
						self.loadClasses()
					}
					else
					{
						let alertController = UIAlertController.errorAlertController(title: "Error While Loading Subjects", message: "There was an error while loading the subjects from our servers. Please check your network connection and try again", error: error)
						self.presentViewController(alertController, animated: true, completion: nil)
					}
				}
			}
			else
			{
				currentSchool.setSubjectsToNil()
				self.setPickerCells(Subject)
			}
		}
		else
		{
			removeActivityIndicatorForCell(subjectCell)
			setPickerCells(Subject)
			loadClasses()
		}
	}
	/**
	This function interacts with Parse to load the current classes. It checks if a local cache exists, and if it does it uses that. Otherwise it calls Parse to load the classes for the current school and current subject and saves it to the local cache.
	*/
	func loadClasses()
	{
		if (currentSubject.classes.first?.catalogNumber == nil)
		{
			setPickerCells(Class)
			if let schoolCode = currentSubject.school?.code
			{
				if let subjectCode = currentSubject.code
				{
					addActivityIndicatorForCell(classCell)
					let query = PFQuery(className: "Classes")
					query.whereKey("school", equalTo: schoolCode)
					query.whereKey("subject", equalTo: subjectCode)
					query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) in
						self.removeActivityIndicatorForCell(self.classCell)
						if (error == nil)
						{
							self.currentSubject.addClasses(objects as! [PFObject])
							self.setPickerCells(Class)
						}
						else
						{
							let alertController = UIAlertController.errorAlertController(title: "Error While Loading Classes", message: "There was an error while loading the classes from our servers. Please check your network connection and try again", error: error)
							self.presentViewController(alertController, animated: true, completion: nil)
						}
					}
				}
				else
				{
					setPickerCells(Class)
				}
			}
			else
			{
				setPickerCells(Class)
			}
		}
		else
		{
			removeActivityIndicatorForCell(classCell)
			setPickerCells(Class)
		}
	}
	
	func addActivityIndicatorForCell(cell: UITableViewCell)
	{
		if cell.accessoryView == nil
		{
			let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
			cell.accessoryView = activityIndicator
			activityIndicator.startAnimating()
		}
	}
	func removeActivityIndicatorForCell(cell: UITableViewCell)
	{
		if let indicator = cell.accessoryView as? UIActivityIndicatorView
		{
			indicator.stopAnimating()
			indicator.removeFromSuperview()
		}
		cell.accessoryView = nil
	}
	
}
//MARK: - TableView Stuff
extension SearchAndComposeViewController : UITableViewDataSource, UITableViewDelegate
{
	func loadCells(segmentIndex: Int)
	{
		tableCells.removeAll(keepCapacity: false)
		let buySellCell = tableView.dequeueReusableCellWithIdentifier("buySell") as! BuySellCell
		segmentControl = buySellCell.segmentControl
		segmentControl.addTarget(self, action: "segmentChange:", forControlEvents: UIControlEvents.ValueChanged)
		segmentControl.selectedSegmentIndex = segmentIndex
		
		schoolCell = tableView.dequeueReusableCellWithIdentifier("detailCell") as! CustomDetailCell
		schoolCell.valueLabel.text = "School"
		subjectCell = tableView.dequeueReusableCellWithIdentifier("detailCell") as! CustomDetailCell
		subjectCell.valueLabel.text = "Subject"
		classCell = tableView.dequeueReusableCellWithIdentifier("detailCell") as! CustomDetailCell
		classCell.valueLabel.text = "Class"
		
		let pickerCell = tableView.dequeueReusableCellWithIdentifier("pickerCell") as! PickerCell
		pickerCell.setup(self, delegate: self)
		selectedCell = schoolCell
		pickerCell.picker.selectRow(currentSchoolIndex, inComponent: 0, animated: true)
		
		tableCells.append(buySellCell)
		tableCells.append(schoolCell)
		tableCells.append(pickerCell)
		tableCells.append(subjectCell)
		tableCells.append(classCell)
		if (composing)
		{
			if (segmentControl.selectedSegmentIndex != 2)
			{
				let priceCell = tableView.dequeueReusableCellWithIdentifier("priceCell") as! PriceCell
				priceCell.setup(self, placeholder: "")
				tableCells.append(priceCell)
				
				let textbookTitle = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
				textbookTitle.setup(self, placeholder: "Textbook Title")
				self.titleCell = textbookTitle
				tableCells.append(textbookTitle)
				
				if (segmentControl.selectedSegmentIndex == 1)
				{
					let conditionCell = tableView.dequeueReusableCellWithIdentifier("conditionCell") as! ConditionCell
					tableCells.append(conditionCell)
				}
				let versionCell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
				versionCell.setup(self, placeholder: "Version")
				versionCell.textField.keyboardType = UIKeyboardType.DecimalPad
				self.versionCell = versionCell
				tableCells.append(versionCell)
				
				let phoneNumberCell = tableView.dequeueReusableCellWithIdentifier("phoneNumberCell") as! ShowPhoneNumber
				tableCells.append(phoneNumberCell)
				
			}
			else
			{
				let ratingCell = tableView.dequeueReusableCellWithIdentifier("ratingCell") as! RatingCell
				ratingCell.setup()
				tableCells.append(ratingCell)
				
				let courseLoad = tableView.dequeueReusableCellWithIdentifier("conditionCell") as! ConditionCell
				courseLoad.segmentControl.removeAllSegments()
				courseLoad.segmentControl.frame.size.width = courseLoad.frame.size.width * 0.9
				for i in 0..<CourseLoad.Nil.rawValue
				{
					courseLoad.segmentControl.insertSegmentWithTitle(CourseLoad(rawValue: i)!.description, atIndex: i, animated: true)
				}
				courseLoad.segmentControl.sizeToFit()
				tableCells.append(courseLoad)
				
				let professorCell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
				professorCell.setup(self, placeholder: "Professor")
				self.professorCell = professorCell
				tableCells.append(professorCell)
			}
			let descriptionCell = tableView.dequeueReusableCellWithIdentifier("descriptionCell") as! DescriptionCell
			descriptionCell.setup()
			descriptionCell.textView.returnKeyType = UIReturnKeyType.Done
			tableCells.append(descriptionCell)
		}
		loadAllSchools()
		tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
	}
	func setPickerCells(theClass: AnyClass?)
	{
		if theClass == nil
		{
			return
		}
		if theClass! is School.Type
		{
			currentSchoolIndex = 0
			schools.sort { $0.description < $1.description }
			schoolCell.valueLabel.text = currentSchool.description
			setPickerCells(Subject)
		}
		else if theClass! is Subject.Type
		{
			currentSubjectIndex = 0
			currentSchool.sortSubjects()
			subjectCell.valueLabel.text = currentSubject.description
			setPickerCells(Class)
		}
		else if theClass! is Class.Type
		{
			currentClassIndex = 0
			currentSubject.sortClasses()
			classCell.valueLabel.text = currentClass.description
		}
		else
		{
			assert(false)
		}
	}
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return tableCells.count
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		return tableCells[indexPath.row]
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		var newIndexPath = indexPath
		selectedCell = nil
		dimCells()
		for (i,cell) in enumerate(tableCells)
		{
			if (cell is PriceCell)
			{
				if ((cell as! PriceCell).textField.isFirstResponder())
				{
					(cell as! PriceCell).textField.resignFirstResponder()
					if (newIndexPath.row == i)
					{
						return
					}
				}
			}
			if (cell is PickerCell)
			{
				tableCells.removeAtIndex(i)
				tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: newIndexPath.section)], withRowAnimation: UITableViewRowAnimation.Left)
				
				if (newIndexPath.row == i-1)
				{
					return
				}
				if (i < newIndexPath.row)
				{
					newIndexPath = NSIndexPath(forRow: newIndexPath.row - 1, inSection: newIndexPath.section)
				}
			}
		}
		if let cell = tableView.cellForRowAtIndexPath(newIndexPath)
		{
			if (cell is PriceCell)
			{
				(cell as! PriceCell).textField.becomeFirstResponder()
			}
			if (cell is BuySellCell)
			{
				segmentControl.selectedSegmentIndex = segmentControl.numberOfSegments > segmentControl.selectedSegmentIndex + 1 ? segmentControl.selectedSegmentIndex + 1 : 0
				segmentChange(segmentControl)
			}
			if (cell is CustomDetailCell)
			{
				let pickerCell = tableView.dequeueReusableCellWithIdentifier("pickerCell") as! PickerCell
				
				pickerCell.picker.layer.borderWidth = 1.0
				pickerCell.picker.layer.borderColor = UIColor.umMaizeColor().CGColor
				pickerCell.picker.layer.cornerRadius = 12.0
				
				pickerCell.picker.dataSource = self
				pickerCell.picker.delegate = self
				if (cell == schoolCell)
				{
					selectedCell = schoolCell
					pickerCell.picker.selectRow(currentSchoolIndex, inComponent: 0, animated: true)
				}
				if (cell == subjectCell)
				{
					selectedCell = subjectCell
					pickerCell.picker.selectRow(currentSubjectIndex, inComponent: 0, animated: true)
				}
				if (cell == classCell)
				{
					selectedCell = classCell
					pickerCell.picker.selectRow(currentClassIndex, inComponent: 0, animated: true)
				}
				pickerCell.picker.reloadAllComponents()
				tableCells.insert(pickerCell, atIndex: newIndexPath.row+1)
				tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: newIndexPath.row + 1, inSection: newIndexPath.section)], withRowAnimation: UITableViewRowAnimation.Left)
			}
		}
		dimCells()
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		if (tableCells[indexPath.row] is PickerCell || tableCells[indexPath.row] is DescriptionCell)
		{
			return 178.0
		}
		return 60.0
	}
}
//MARK: - PickerView Stuff
extension SearchAndComposeViewController : UIPickerViewDataSource, UIPickerViewDelegate
{
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
	{
		return 1
	}
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
	{
		if (selectedCell == schoolCell)
		{
			return schools.count
		}
		if (selectedCell == subjectCell)
		{
			return currentSchool.subjects.count
		}
		if (selectedCell == classCell)
		{
			return currentSubject.classes.count
		}
		return 0
	}
	func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView
	{
		var string = "No data found."
		if (selectedCell == schoolCell)
		{
			string = schools[row].description
		}
		else if (currentSchool.subjects.count > row && selectedCell == subjectCell)
		{
			string = currentSchool.subjects[row].description
		}
		else if (currentSubject.classes.count > row && selectedCell == classCell)
		{
			string = currentSubject.classes[row].description
		}
		if (string.isEmpty)
		{
			string = "No data found."
		}
		if let label = view as? UILabel
		{
			label.text = string
			label.center = pickerView.center
			label.textAlignment = .Center
			label.textColor = UIColor.whiteColor()
			label.font = UIFont(name: "HelveticaNeue-Light", size: 21.0)
			return label
		}
		else
		{
			let label = UILabel()
			label.text = string
			label.center = pickerView.center
			label.textAlignment = .Center
			label.textColor = UIColor.whiteColor()
			label.font = UIFont(name: "HelveticaNeue-Light", size: 21.0)
			return label
		}
		
	}
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
	{
		
		if (selectedCell == schoolCell)
		{
			selectedCell?.valueLabel?.text = schools[row].description
			currentSchoolIndex = row
			loadSubjects()
		}
		else if (currentSchool.subjects.count > row && selectedCell == subjectCell)
		{
			selectedCell?.valueLabel?.text = currentSchool.subjects[row].description
			currentSubjectIndex = row
			loadClasses()
		}
		else if (currentSubject.classes.count > row && selectedCell == classCell)
		{
			currentClassIndex = row
			selectedCell?.valueLabel?.text = currentSubject.classes[row].description
		}
	}
}
//MARK: - TextField Stuff
extension SearchAndComposeViewController : UITextFieldDelegate
{
	func findActiveField() -> UITableViewCell?
	{
		return tableCells.filter { ($0 is TextFieldCell && ($0 as! TextFieldCell).textField.isFirstResponder()) || ($0 is DescriptionCell && ($0 as! DescriptionCell).textView.isFirstResponder()) }.first
	}
	func keyboardShown (notification: NSNotification)
	{
		var info = notification.userInfo!
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
		{
			var contentInsets = UIEdgeInsetsMake(navigationController?.navigationBar.frame.height ?? 0, 0.0, max(keyboardSize.height, (navigationController?.toolbar.frame.height ?? 0)), 0.0)
			tableView.contentInset = contentInsets
			tableView.scrollIndicatorInsets = contentInsets
			var rect = self.view.frame
			rect.size.height -= keyboardSize.height
			if let activeField = findActiveField()
			{
				if (!rect.contains(activeField.frame.origin))
				{
					tableView.scrollRectToVisible(activeField.frame, animated: true)
				}
			}
		}
	}
	func keyboardHidden (notification: NSNotification)
	{
		var contentInsets = UIEdgeInsets(top: navigationController?.navigationBar.frame.height ?? 0, left: 0, bottom: navigationController?.toolbar.frame.height ?? 0, right: 0)
		tableView.contentInset = contentInsets
		tableView.scrollIndicatorInsets = contentInsets
	}
	/**
	This is a callback function that is called when the user hits the return key on the keyboard
	
	:param: textField The textfield on which has the first responder when the return key is pressed
	
	:returns: Returns whether this should result in normal behaviour or not.
	*/
	func textFieldShouldReturn(textField: UITextField) -> Bool
	{
		for (i, cell) in enumerate(tableCells)
		{
			if (cell is TextFieldCell)
			{
				if (cell as! TextFieldCell).textField.isFirstResponder()
				{
					for j in i+1..<tableCells.count
					{
						(tableCells[j] as? TextFieldCell)?.textField.becomeFirstResponder()
						break
					}
					break
				}
			}
		}
		return true
	}
}