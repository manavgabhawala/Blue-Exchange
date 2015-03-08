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
	var classPickerCells = [UITableViewCell]()
	var buyCells = [UITableViewCell]()
	var sellCells = [UITableViewCell]()
	var reviewCells = [UITableViewCell]()
	
	var allCells = [TableSectionCells]()
	
	var schools = [School]()
	
	var schoolCell = CustomDetailCell()
	var subjectCell = CustomDetailCell()
	var classCell = CustomDetailCell()
	
	var currentSchoolIndex = 0
	var currentSubjectIndex = 0
	var currentClassIndex = 0
	
	var backgroundView : UIView!
	
	var titleCell : TextFieldCell!
	var versionCell : TextFieldCell!
	var professorCell : TextFieldCell!
	
	weak var courseLoadPicker : UIPickerView?
	
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
	weak var sender : HomeViewController?
	
	//MARK: - ViewController Lifecycle
	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: "UIKeyboardWillShowNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHidden:", name: "UIKeyboardWillHideNotification", object: nil)
		
		let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done:")
		navigationItem.setRightBarButtonItem(doneButton, animated: true)
		if schools.count <= 0
		{
			schools = [School()]
		}
		loadCells()
		setCells(selectedSegmentIndex: 0)
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
	override func viewWillDisappear(animated: Bool)
	{
		super.viewWillDisappear(animated)
		sender?.schools = schools
	}
	/**
	This is a helper function that dims the labels of the other cells so that when selecting from the picker it is evident what you are selecting for.
	*/
	func dimCells ()
	{
		if allCells.count > 0
		{
			if allCells[0].count > 0
			{
				allCells[0].filter { $0 is PickerCell } .map { ($0 as! PickerCell).picker.reloadAllComponents() }
				var valueExists = false
				let _ : [Void] = allCells[0].filter { $0 == self.selectedCell }.map { ($0 as! CustomDetailCell).valueLabel.alpha = 1.0; valueExists = true }
				allCells[0].filter { $0 is CustomDetailCell && $0 != self.selectedCell }.map { ($0 as! CustomDetailCell).valueLabel.alpha = self.selectedCell != nil ? 0.3 : 1.0 }
			}
		}
	}
	//MARK: - Actions
	func segmentChange(segmentControl: UISegmentedControl)
	{
		setCells(selectedSegmentIndex: segmentControl.selectedSegmentIndex)
	}
	func switchComposing(_ : UIBarButtonItem)
	{
		composing = !composing
		if composing
		{
			oppositeItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "switchComposing:")
			tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
		}
		else
		{
			oppositeItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "switchComposing:")
			tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Left)
		}
		var items = navigationController?.toolbar.items!
		items?.removeLast()
		items?.append(oppositeItem!)
		navigationController?.toolbar.setItems(items, animated: true)
	}
	func done(_: UIBarButtonItem)
	{
		if (composing && allCells.count > 1)
		{
			var error = false
			if currentClass.catalogNumber == nil
			{
				classCell.shakeForInvalidInput()
				error = true
			}
			let user = PFUser.currentUser()
			if (segmentControl.selectedSegmentIndex == 2)
			{
				let review = PFObject(className: "Review")
				review["user"] = user
				review["course"] = PFObject(withoutDataWithClassName: "Classes", objectId: currentClass.objectId)
				review["rating"] = (allCells[1].filter { $0 is RatingCell }.first! as! RatingCell).ratingView.rating
				let descriptionCell = (allCells[1].filter { $0 is DescriptionCell }.first! as! DescriptionCell)
				let description = descriptionCell.textView.text.isEmpty ? nil : descriptionCell.textView.text
				if description != nil { review["text"] = description }
				let load = (allCells[1].filter { $0 is PickerCell }.first! as! PickerCell).picker.selectedRowInComponent(0)
				if load != CourseLoad.Nil.rawValue
				{
					review["workload"] = load
				}
				let professor = professorCell.textField.text.isEmpty ? nil : professorCell.textField.text
				if professor != nil { review["professor"] = professor }
				review.saveInBackgroundWithBlock {(result, error) in
					if (result && error == nil)
					{
						self.composing = false
						self.done(UIBarButtonItem())
					}
					else
					{
						let alert = UIAlertController.errorAlertController(title: "Error Saving Textbook", message: "An error occurred while trying to save your textbook to our servers. Please check your internet connection and try again.", error: error)
						self.presentViewController(alert, animated: true, completion: nil)
					}
				}
				println("Will save object here")
			}
			else
			{
				let priceCell = (allCells[1].filter {$0 is PriceCell }.first! as! PriceCell)
				let price = priceCell.textField.text.floatValue()
				if (price == nil || abs(price!) == HUGE || price <= 0.0)
				{
					(priceCell.contentView.subviews as! [UIView]).map { $0.shakeForInvalidInput() }
					error = true
				}
				let title = titleCell.textField.text.isEmpty ? nil : titleCell.textField.text
				var condition : String?
				if let cell = (allCells[1].filter{ $0 is ConditionCell }).first as? ConditionCell
				{
					let index = cell.segmentControl.selectedSegmentIndex
					condition = cell.segmentControl.titleForSegmentAtIndex(index) ?? nil
				}
				let showPhoneNumber = (allCells[1].filter { $0 is ShowPhoneNumber }.first! as! ShowPhoneNumber).numberSwitch.on
				let selling = Bool(segmentControl.selectedSegmentIndex)
				segmentControl.selectedSegmentIndex = Int(!Bool(segmentControl.selectedSegmentIndex))
				let version = versionCell.textField.text.isEmpty ? nil : versionCell.textField.text
				let descriptionCell = (allCells[1].filter { $0 is DescriptionCell }.first! as! DescriptionCell)
				let description = descriptionCell.textView.text.isEmpty ? nil : descriptionCell.textView.text
				if (!error)
				{
					let textbook = PFObject(className: "Textbook")
					textbook["user"] = user
					textbook["course"] = PFObject(withoutDataWithClassName: "Classes", objectId: currentClass.objectId)
					textbook["class"] = "\(currentClass.subject?.code ?? currentClass.subjectCode)\(currentClass.catalogNumber)"
					textbook["showPhoneNumber"] = showPhoneNumber
					textbook["price"] = price
					textbook["selling"] = selling
					if (version != nil) { textbook["edition"] = version }
					if title != nil { textbook["title"] = title }
					if description != nil { textbook["description"] = description }
					if condition != nil { textbook["condition"] = condition }
					textbook.saveInBackgroundWithBlock({(result, error) in
						if (result && error == nil)
						{
							self.composing = false
							self.done(UIBarButtonItem())
						}
						else
						{
							let alert = UIAlertController.errorAlertController(title: "Error Saving Textbook", message: "An error occurred while trying to save your textbook to our servers. Please check your internet connection and try again.", error: error)
							self.presentViewController(alert, animated: true, completion: nil)
						}
					})
				}
				
			}
			//TODO: Save object here
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
	func loadCells()
	{
		let buySellCell = tableView.dequeueReusableCellWithIdentifier("buySell") as! BuySellCell
		segmentControl = buySellCell.segmentControl
		segmentControl.addTarget(self, action: "segmentChange:", forControlEvents: UIControlEvents.ValueChanged)
		
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
		
		classPickerCells.append(buySellCell)
		classPickerCells.append(schoolCell)
		classPickerCells.append(pickerCell)
		classPickerCells.append(subjectCell)
		classPickerCells.append(classCell)
		
		let priceCell = tableView.dequeueReusableCellWithIdentifier("priceCell") as! PriceCell
		priceCell.setup(self, placeholder: "")
		buyCells.append(priceCell)
		sellCells.append(priceCell)
		
		let textbookTitle = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
		textbookTitle.setup(self, placeholder: "Textbook Title")
		self.titleCell = textbookTitle
		buyCells.append(textbookTitle)
		sellCells.append(textbookTitle)
		
		let conditionCell = tableView.dequeueReusableCellWithIdentifier("conditionCell") as! ConditionCell
		sellCells.append(conditionCell)
		
		let versionCell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
		versionCell.setup(self, placeholder: "Version")
		versionCell.textField.keyboardType = UIKeyboardType.DecimalPad
		self.versionCell = versionCell
		buyCells.append(versionCell)
		sellCells.append(versionCell)
		
		let phoneNumberCell = tableView.dequeueReusableCellWithIdentifier("phoneNumberCell") as! ShowPhoneNumber
		buyCells.append(phoneNumberCell)
		sellCells.append(phoneNumberCell)
		
		let ratingCell = tableView.dequeueReusableCellWithIdentifier("ratingCell") as! RatingCell
		ratingCell.setup()
		reviewCells.append(ratingCell)
		
		let courseLoad = tableView.dequeueReusableCellWithIdentifier("pickerCell") as! PickerCell
		courseLoad.setup(self, delegate: self)
		courseLoadPicker = courseLoad.picker
		
		reviewCells.append(courseLoad)
				
		let professorCell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
		professorCell.setup(self, placeholder: "Professor")
		self.professorCell = professorCell
		reviewCells.append(professorCell)
		
		let descriptionCell = tableView.dequeueReusableCellWithIdentifier("descriptionCell") as! DescriptionCell
		descriptionCell.setup()
		buyCells.append(descriptionCell)
		sellCells.append(descriptionCell)
		reviewCells.append(descriptionCell)
		
		loadAllSchools()
	}
	func getCells(selectedSegmentIndex index: Int) -> [UITableViewCell]
	{
		if index == 0
		{
			return buyCells
		}
		else if index == 1
		{
			return sellCells
		}
		else if index == 2
		{
			return reviewCells
		}
		else
		{
			assert(false)
			return []
		}
	}
	func setCells(selectedSegmentIndex index: Int)
	{
		if (allCells.count <= 0)
		{
			allCells.append(classPickerCells)
			tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: .Left)
			allCells.append(getCells(selectedSegmentIndex: index))
			if (composing)
			{
				tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Left)
			}
		}
		else if (allCells.count == 1)
		{
			allCells.append(getCells(selectedSegmentIndex: index))
			if (composing)
			{
				tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Left)
			}
		}
		else if allCells.count == 2
		{
			let newCells = getCells(selectedSegmentIndex: index)
			allCells.removeLast()
			if (composing)
			{
				tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
			}
			allCells.append(newCells)
			if (composing)
			{
				tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
			}
		}
		else
		{
			allCells.removeAll(keepCapacity: false)
			setCells(selectedSegmentIndex: index)
		}
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
		return composing ? (allCells.count >= 2 ? 2 : allCells.count) : (allCells.count >= 1 ? 1 : allCells.count)
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return (allCells[section]).count
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		return allCells[indexPath.section][indexPath.row]
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		var newIndexPath = indexPath
		selectedCell = nil
		dimCells()
		if (allCells.count > 0)
		{
			for (i,cell) in enumerate(allCells[0])
			{
				if cell is PickerCell
				{
					allCells[0].removeAtIndex(i)
					classPickerCells.removeAtIndex(i)
					tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
					if (newIndexPath.row == i-1 && newIndexPath.section == 0)
					{
						return
					}
					if (i < newIndexPath.row && newIndexPath.section == 0)
					{
						newIndexPath = NSIndexPath(forRow: newIndexPath.row - 1, inSection: newIndexPath.section)
					}
				}
			}
		}
		if let selectedCell = tableView.cellForRowAtIndexPath(newIndexPath)
		{
			if let cell = selectedCell as? TextFieldCell
			{
				if cell.textField.isFirstResponder()
				{
					cell.textField.resignFirstResponder()
				}
				else
				{
					cell.textField.becomeFirstResponder()
				}
			}
			if let cell = selectedCell as? DescriptionCell
			{
				if cell.textView.isFirstResponder()
				{
					cell.textView.resignFirstResponder()
				}
				else
				{
					cell.textView.becomeFirstResponder()
				}
			}
			if let cell = selectedCell as? BuySellCell
			{
				cell.segmentControl.selectedSegmentIndex = cell.segmentControl.numberOfSegments > cell.segmentControl.selectedSegmentIndex + 1 ? cell.segmentControl.selectedSegmentIndex + 1 : 0
				segmentChange(segmentControl)
			}
			if let cell = selectedCell as? ConditionCell
			{
				cell.segmentControl.selectedSegmentIndex = cell.segmentControl.numberOfSegments > cell.segmentControl.selectedSegmentIndex + 1 ? cell.segmentControl.selectedSegmentIndex + 1 : 0
			}
			if let cell = selectedCell as? CustomDetailCell
			{
				let pickerCell = tableView.dequeueReusableCellWithIdentifier("pickerCell") as! PickerCell
				pickerCell.setup(self, delegate: self)
				self.selectedCell = cell
				var index : Int = 0
				if (self.selectedCell == schoolCell)
				{
					index = currentSchoolIndex
				}
				else if (self.selectedCell == subjectCell)
				{
					index = currentSubjectIndex
				}
				else if (self.selectedCell == classCell)
				{
					index = currentClassIndex
				}
				pickerCell.picker.selectRow(index, inComponent: 0, animated: true)
				pickerCell.picker.reloadAllComponents()
				allCells[0].insert(pickerCell, atIndex: newIndexPath.row + 1)
				classPickerCells.insert(pickerCell, atIndex: newIndexPath.row + 1)
				tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: newIndexPath.row + 1, inSection: newIndexPath.section)], withRowAnimation: UITableViewRowAnimation.Left)
			}
		}
		dimCells()
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		if (allCells[indexPath.section][indexPath.row] is PickerCell || allCells[indexPath.section][indexPath.row] is DescriptionCell)
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
		if pickerView == courseLoadPicker
		{
			return CourseLoad.Nil.rawValue + 1
		}
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
		if (pickerView == courseLoadPicker)
		{
			if let load = CourseLoad(rawValue: row)
			{
				string = load.description
			}
		}
		else
		{
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
		if (pickerView == courseLoadPicker)
		{
			return
		}
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
		if allCells.count > 1
		{
			for cells in allCells
			{
				let filteredCells = cells.filter{ ($0 is TextFieldCell && ($0 as! TextFieldCell).textField.isFirstResponder()) || ($0 is DescriptionCell && ($0 as! DescriptionCell).textView.isFirstResponder()) }
				if filteredCells.count > 0
				{
					return filteredCells.first
				}
			}
		}
		return nil
	}
	
	func keyboardShown (notification: NSNotification)
	{
		var info = notification.userInfo!
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
		{
			var contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
			tableView.contentInset = contentInsets
			tableView.scrollIndicatorInsets = contentInsets
			var rect = self.view.frame
			rect.size.height -= keyboardSize.height
			if let activeField = findActiveField()
			{
				if (!rect.contains(CGPoint(x: activeField.frame.midX, y: activeField.frame.maxY)))
				{
					tableView.scrollRectToVisible(activeField.frame, animated: true)
				}
			}
		}
	}
	func keyboardHidden (notification: NSNotification)
	{
		var contentInsets = UIEdgeInsetsZero
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
		if allCells.count > 1
		{
			for (i, cell) in enumerate(allCells[1])
			{
				if (cell is TextFieldCell)
				{
					if (cell as! TextFieldCell).textField.isFirstResponder()
					{
						for j in i+1..<allCells[1].count
						{
							(allCells[1][j] as? TextFieldCell)?.textField.becomeFirstResponder()
							break
						}
						break
					}
				}
			}
		}
		return true
	}
}