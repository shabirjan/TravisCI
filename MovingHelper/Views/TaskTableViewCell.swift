//
//  TaskTableViewCell.swift
//  MovingHelper
//
//  Created by Ellen Shapiro on 6/9/15.
//  Copyright (c) 2015 Razeware. All rights reserved.
//

import UIKit

open class TaskTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var notesLabel: UILabel!
    @IBOutlet open var checkbox: Checkbox!
    
    var currentTask : Task?
    public var delegate : TaskUpdatedDelegate?
    
    
    open func configureForTask(_ task: Task) {
        currentTask = task
        titleLabel.text = task.title
        notesLabel.text = task.notes
        configureForDoneState(task.done)
    }
    
    func configureForDoneState(_ done: Bool) {
        checkbox.isChecked = done
        if done {
            backgroundColor = .lightGray
            titleLabel.alpha = 0.5
            notesLabel.alpha = 0.5
        } else {
            backgroundColor = .white
            titleLabel.alpha = 1
            notesLabel.alpha = 1
        }
    }
    open override func prepareForReuse() {
        super.prepareForReuse()
        currentTask = nil
        delegate = nil
    }
    
    @IBAction func tappedCheckbox() {
        configureForDoneState(!checkbox.isChecked)
        
        //TODO: Actually mark task done
        if let task = currentTask {
            task.done = checkbox.isChecked
            delegate?.taskUpdated(task)
        }
        
    }
}
