//
//  MasterViewController.swift
//  MovingHelper
//
//  Created by Ellen Shapiro on 6/7/15.
//  Copyright (c) 2015 Razeware. All rights reserved.
//

import UIKit

//MARK: - Main view controller class
open class MasterViewController: UITableViewController {
  
  //MARK: Properties
  
  fileprivate var movingDate: Date?
  fileprivate var sections = [[Task]]()
  fileprivate var allTasks = [Task]() {
    didSet {
      sections = SectionSplitter.sectionsFromTasks(allTasks)
    }
  }
  
  //MARK: View Lifecycle
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = LocalizedStrings.taskListTitle
    
    movingDate = movingDateFromUserDefaults()
    if let storedTasks = TaskLoader.loadSavedTasksFromJSONFile(FileName.SavedTasks) {
      allTasks = storedTasks
    } //else case handled in view did appear
  }
  
  override open func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if allTasks.count == 0 {
      showChooseMovingDateVC()
    } //else we're already good to go.
  }
  
  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      let segueIdentifier: SegueIdentifier = SegueIdentifier(rawValue: identifier)!
      switch segueIdentifier {
      case .ShowDetailVCSegue:
        if let indexPath = self.tableView.indexPathForSelectedRow {
          let task = taskForIndexPath(indexPath)
          (segue.destination as! DetailViewController).detailTask = task
        }
        
      case .ShowMovingDateVCSegue:
        (segue.destination as! MovingDateViewController).delegate = self
      default:
        NSLog("Unhandled identifier \(identifier)")
        //Do nothing.
      }
    }
  }
  
  //MARK: Task Handling
  
  func addOrUpdateTask(_ task: Task) {
    let index = task.dueDate.getIndex()
    let dueDateTasks = sections[index]
    var tasksWithDifferentID = dueDateTasks.filter{ $0.taskID != task.taskID }
    tasksWithDifferentID.append(task)
    tasksWithDifferentID.sorted(by: { $0.taskID > $1.taskID })
    
    sections[index] = tasksWithDifferentID
    tableView.reloadData()
  }
  
  //MARK: IBActions
  
  @IBAction func calendarIconTapped() {
    showChooseMovingDateVC()
  }
  
  fileprivate func showChooseMovingDateVC() {
    performSegue(withIdentifier: SegueIdentifier.ShowMovingDateVCSegue.rawValue, sender: nil)
  }
  
  //MARK: File Writing
  
  fileprivate func saveTasksToFile() {
    TaskSaver.writeTasksToFile(allTasks, fileName: FileName.SavedTasks)
  }
  
  //MARK: Moving Date Handling
  
  fileprivate func movingDateFromUserDefaults() -> Date? {
    return UserDefaults.standard
      .value(forKey: UserDefaultKey.MovingDate.rawValue) as? Date
  }
}

//MARK: - Task Updated Delegate Extension

extension MasterViewController: TaskUpdatedDelegate {
  public func taskUpdated(_ task: Task) {
    addOrUpdateTask(task)
    saveTasksToFile()
  }
}

//MARK: - Moving Date Delegate Extension

extension MasterViewController: MovingDateDelegate {
  public func createdMovingTasks(_ tasks: [Task]) {
    allTasks = tasks
    saveTasksToFile()
  }
  
  public func updatedMovingDate() {
    movingDate = movingDateFromUserDefaults()
    tableView.reloadData()
  }
}

//MARK: - Table View Data Source Extension

extension MasterViewController  {
  
  fileprivate func taskForIndexPath(_ indexPath: IndexPath) -> Task {
    let tasks = tasksForSection(indexPath.section)
    return tasks[indexPath.row]
  }
  
  fileprivate func tasksForSection(_ section: Int) -> [Task] {
    let currentSection = sections[section]
    return currentSection
  }
  
  override open func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  override open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }
  
  override open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableCell(withIdentifier: TaskSectionHeaderView.cellIdentifierFromClassName()) as! TaskSectionHeaderView
    let dueDate = TaskDueDate.fromIndex(section)
    
    if let moveDate = movingDate {
      header.configureForDueDate(dueDate, moveDate: moveDate)
    }
    
    return header
  }
  
  override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let tasks = tasksForSection(section)
    return tasks.count
  }
  
  override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.cellIdentifierFromClassName(), for: indexPath) as! TaskTableViewCell
    let task = taskForIndexPath(indexPath)
    cell.delegate = self
    cell.configureForTask(task)
    
    return cell
  }
}

