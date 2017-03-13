//  
//  ViewController.swift
//  JHHSAN
//
//  Copyright © 2016 John Hersey High School. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    
    //Nav Bar Variables
    @IBOutlet weak var Open: UIBarButtonItem!
    
    //Calendar Variables
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    var todaysDate = ""
    var date = Date()
    var numberOfRows = 6
    let formatter = DateFormatter()
    var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    var generateInDates: InDateCellGeneration = .forAllMonths
    var generateOutDates: OutDateCellGeneration = .tillEndOfGrid
    let firstDayOfWeek: DaysOfWeek = .sunday
    var year = 2000
    var month = 1
    var day = 1
    
    
    let disabledColor = UIColor.lightGray
    let enabledColor = UIColor.blue
    let dateCellSize: CGFloat? = nil
    
    let thisMonthsDateColor = UIColor.orange
    let otherMonthsDateColor = UIColor.darkGray
    
    let thisSelectedMonthsDateColor = UIColor.white
    let otherSelectedMonthsDateColor = UIColor.black
    
    //Table View Variables
    var headerText = ""
    var assignmentArray = [Assignment]()
    var textField1 = UITextField()
    var textField2 = UITextField()
    
    @IBOutlet weak var mainTableView: UITableView!
    
    //Assignment Variables
    @IBOutlet weak var addAssignmentButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Open.target = self.revealViewController()
        //Open.action = #selector(SWRevealViewController.revealToggle(_:))
        Open.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        
        Thread.sleep(forTimeInterval: 0.25) //Increases launch screen time
        
        formatter.dateFormat = "yyyy MM dd"
        //calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        
        
        calendarView.delegate = self
        calendarView.dataSource = self
        
        calendarView.registerCellViewXib(file: "CellView")
        
        calendarView.registerHeaderView(xibFileNames: ["SectionHeaderView1"])
        
        
        calendarView.cellInset = CGPoint(x: 0, y: 0)
        calendarView.allowsMultipleSelection = true
        
        calendarView.visibleDates { (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
        //Get date
        //new code will be:
        
        date = Date()
        calendar = Calendar.current
        
        year = calendar.component(.year, from: date)
        month = calendar.component(.month, from: date)
        day = calendar.component(.day, from: date)
        
        formatter.dateFormat = "yyyy-MM-dd"
        todaysDate = self.formatter.string(from: Date())
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first else {
            return
        }
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        calendarView.registerCellViewXib(file: "CellView") // Registering your cell is manditory
        calendarView.cellInset = CGPoint(x: 0, y: 0)
        
        let month = calendar.dateComponents([.month], from: startDate).month!
        let monthName = DateFormatter().monthSymbols[(month-1) % 12]
        // 0 indexed array
        let year = calendar.component(.year, from: startDate)
        
        //Change month label attributes here
        monthLabel.font = UIFont(name: "Avenir", size: 50)
        monthLabel.textColor = UIColor.white
        
        headerText = monthLabel.text!
        
        monthLabel.text = monthName + " " + String(year)
        
        
    }
    
    //TableView Code
    
    //To exist: Sets how much cells are in the array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignmentArray.count
    }
    //To exist:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.textLabel?.text = assignmentArray[(indexPath as NSIndexPath).row].name
        return cell
    }

    //Alert Functions
    func addAssign(_ textField: UITextField!) {
        textField.placeholder = "Assignment"
        textField1 = textField
    }
    func addAssignClass(_ textField: UITextField!) {
        
        textField.placeholder = "Class"
        textField2 = textField
    }
    func saveAssign(_ textField: UIAlertAction!) {
        let newAssignment = Assignment(name: textField1.text!, className: textField2.text!, date: todaysDate)
        assignmentArray.append(newAssignment)
        mainTableView.reloadData()
        print(assignmentArray[0].dateDue)
    }
    
    
    @IBAction func addAssignmentButton(_ sender: Any) {
        let addAlert = UIAlertController(title: "Add Assignment", message: nil, preferredStyle:UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        addAlert.addAction(cancelAction)
        
        addAlert.addTextField(configurationHandler: addAssign)
        addAlert.addTextField(configurationHandler: addAssignClass)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: saveAssign)
        
        addAlert.addAction(okAction)
        
        self.present(addAlert, animated: true, completion: nil)
        mainTableView.reloadData()
        
    }
    
    
    
    
}

// MARK : JTAppleCalendarDelegate
extension ViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let startDate = formatter.date(from: "2017 3 1")!
        let endDate = formatter.date(from: "2020 12 30")!
        let parameters = ConfigurationParameters(
            startDate: startDate,
            endDate: endDate,
            numberOfRows: numberOfRows,
            //calendar: .gregorian,
            generateInDates: generateInDates,
            generateOutDates: generateOutDates,
            firstDayOfWeek: firstDayOfWeek
        )
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        (cell as? CellView)?.setupCellBeforeDisplay(cellState, date: date)
        
        let customCell = cell as! CellView
        
        // Setup Cell text
        customCell.dayLabel.text = cellState.text
        
        // Setup text color
        if cellState.dateBelongsTo == .thisMonth {
            customCell.dayLabel.textColor = thisMonthsDateColor
        } else {
            customCell.dayLabel.textColor = otherMonthsDateColor
        }
        
        
        
        customCell.todayColor = UIColor.lightGray
        
        customCell.normalDayColor = UIColor.white
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        let customCell = cell as! CellView
        
        (cell as? CellView)?.cellSelectionChanged(cellState)
        
        
        // Setup Cell text
        customCell.dayLabel.text = cellState.text
        
        // Setup text color
        if cellState.dateBelongsTo == .thisMonth {
            customCell.dayLabel.textColor = thisSelectedMonthsDateColor
        } else {
            customCell.dayLabel.textColor = otherSelectedMonthsDateColor
        }
        
        //Gives rounded corners to selected view
        (cell as? CellView)?.selectedView.layer.cornerRadius = 30
        
        //Changing cell label
        
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState)
        
        let customCell = cell as! CellView
        
        // Setup Cell text
        customCell.dayLabel.text = cellState.text
        
        // Setup text color
        if cellState.dateBelongsTo == .thisMonth {
            customCell.dayLabel.textColor = thisMonthsDateColor
        } else {
            customCell.dayLabel.textColor = otherMonthsDateColor
        }
        
        
    }
    
    
    //Function Not needed for iOS 10; will not be called
    func calendar(_ calendar: JTAppleCalendarView, willResetCell cell: JTAppleDayCellView) {
        (cell as? CellView)?.selectedView.isHidden = true
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.setupViewsOfCalendar(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView,
                  sectionHeaderIdentifierFor range: (start: Date, end: Date),
                  belongingTo month: Int) -> String {
        return "SectionHeaderView1"
    }
    
    func calendar(_ calendar: JTAppleCalendarView, sectionHeaderSizeFor range: (start: Date, end: Date), belongingTo month: Int) -> CGSize {
        return CGSize(width: 200, height: 50)
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplaySectionHeader header: JTAppleHeaderView, range: (start: Date, end: Date), identifier: String) {
        
        let headerCell = header as? SectionHeaderView1
        headerCell?.title.text = "Sunday          Monday          Tuesday          Wednesday           Thursday         Friday          Saturday" //Change for iPad 3
        
        headerCell?.title.textColor = UIColor.white
        
    }
    
}

func delayRunOnMainThread(_ delay: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() +
            Double(Int64(delay * Double(NSEC_PER_SEC))) /
            Double(NSEC_PER_SEC), execute: closure)
}
