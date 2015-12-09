//
//  EmailCollectorUITests.swift
//  EmailCollectorUITests
//
//  Created by Tayal, Rishabh on 12/9/15.
//  Copyright © 2015 Rishabh Tayal. All rights reserved.
//

import XCTest

class EmailCollectorUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let app = XCUIApplication()
        let enterDomainCompanyComSearchField = app.tables["Start searching for a company name."].searchFields["Enter domain (company.com)"]
        
        snapshot("0EmptyTableView")
        enterDomainCompanyComSearchField.tap()
        enterDomainCompanyComSearchField.tap()
        enterDomainCompanyComSearchField.typeText("google.com")
        app.typeText("\r")
        sleep(2)
        snapshot("1Emails", waitForLoadingIndicator: true)
    }
    
}
