//
//  TaskCellTests.swift
//  MovingHelper
//
//  Created by Shabir Jan on 31/03/2017.
//  Copyright © 2017 Razeware. All rights reserved.
//

import UIKit
import XCTest
import MovingHelper

class TaskCellTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    func testCheckingCheckboxMarksTaskDone() {
        let cell = TaskTableViewCell()
        
        //1
        let expectations = expectation(description: "Task update")
       
        
        //2
        struct TestDelegate: TaskUpdatedDelegate {
            let testExpectation: XCTestExpectation
            let expectedDone: Bool
            
            init(updatedExpectation: XCTestExpectation,
                 expectedDoneStateAfterToggle: Bool) {
                testExpectation = updatedExpectation
                expectedDone = expectedDoneStateAfterToggle
            }
            
            func taskUpdated(_ task: Task) {
                XCTAssertEqual(expectedDone, task.done, "Task done state did not match expected!")
                testExpectation.fulfill()
            }
        }
        
        //3
        let testTask = Task(aTitle: "TestTask", aDueDate: .OneMonthAfter)
        XCTAssertFalse(testTask.done, "Newly created task is already done!")
        cell.delegate = TestDelegate(updatedExpectation: expectations,
                                     expectedDoneStateAfterToggle: true)
        cell.configureForTask(testTask)
        
        //4
        XCTAssertFalse(cell.checkbox.isChecked, "Checkbox checked for not-done task!")
        
        //5
        cell.checkbox.sendActions(for: .touchUpInside)
        
        //6
        XCTAssertTrue(cell.checkbox.isChecked, "Checkbox not checked after tap!")
        waitForExpectations(timeout: 1, handler: nil)
    }
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
