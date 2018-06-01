import XCTest

class Six_Pack_AbsUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
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
        
        let tablesQuery = app.tables
        tablesQuery.cells.element(boundBy: 0).tap()
        tablesQuery.cells.element(boundBy: 1).tap()
        
        snapshot("screen")
    }
    
    func appScreens() {
        let app = XCUIApplication()
        snapshot("main")
        app.buttons["Start Workout ABS"].tap()
        snapshot("Start_Workout_ABS")
        app.navigationBars.element(boundBy: 0).buttons.element(boundBy: 0).tap()
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons.element(boundBy: 1).tap()
        snapshot("workouts")
        tabBarsQuery.buttons.element(boundBy: 0).tap()
        
        let tablesQuery = app.tables
        tablesQuery.cells.element(boundBy: 0).tap()
        tablesQuery.cells.element(boundBy: 1).tap()
        snapshot("Alternate_Heel_Touch")
        app.buttons.element(boundBy: 1).tap()
        app.buttons.element(boundBy: 0).tap()
        
        tabBarsQuery.buttons.element(boundBy: 1).tap()
        tablesQuery.cells.element(boundBy: 0).tap()
        tablesQuery.cells.element(boundBy: 1).tap()
        
        sleep(25)
        snapshot("exercise1")
        app.buttons.element(boundBy: 0).tap()
        app.buttons.element(boundBy: 0).tap()
        tablesQuery.cells.element(boundBy: 1).tap()
        tablesQuery.cells.element(boundBy: 2).tap()
        XCUIDevice.shared().orientation = .landscapeRight
        
        sleep(25)
        snapshot("exercise2")
    }
}
