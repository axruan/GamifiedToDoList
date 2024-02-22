//
//Task.swift
//
import Foundation

///A task represents a piece of work.  It's a super class of Todo
class Task: Identifiable, ObservableObject, Codable {
    @Published var title: String
    @Published var difficulty: DifficultyLevel
    @Published var notes: String
    @Published var tags: [Tag] = [Tag]()
    @Published var isComplete: Bool = false
    
    ///Adding Codable conformance for @Published properties
    ///https://www.hackingwithswift.com/books/ios-swiftui/adding-codable-conformance-for-published-properties
    enum CodingKeys: CodingKey {
        case title
        case difficulty
        case notes
        case tags
        case isComplete
    }
    
    ///Adding Codable conformance for @Published properties
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        notes = try container.decode(String.self, forKey: .notes)
        isComplete = try container.decode(Bool.self, forKey: .isComplete)
        difficulty = try container.decode(DifficultyLevel.self, forKey: .difficulty)
        tags = try container.decode([Tag].self, forKey: .tags)
    }
    
    ///Adding Codable conformance for @Published properties
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(notes, forKey: .notes)
        try container.encode(isComplete, forKey: .isComplete)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(tags, forKey: .tags)
    }
    
    ///initializer
    init(title: String, difficulty: DifficultyLevel, notes: String, tags: [Tag], isComplete: Bool) {
        self.title = title
        self.difficulty = difficulty
        self.notes = notes
        self.tags = tags
        self.isComplete = isComplete
    }
}

///Subclass of Task, it represents a todo item in this app
class Todo: Task{
    @Published var due_date: Date = Date.now
    @Published var checkList: [Task] = [Task]()
    @Published var reminder: Date = Date.now
    
    ///computed property that returns total # of checklist of this todo
    var numberOfCheckList: Int {
        return checkList.count
    }
    
    ///computed property that returns # of completed checklist of this todo
    var numberofCompletedCheckList: Int {
        var count = 0
        for task in checkList {
            if task.isComplete {
                count += 1
            }
        }
        return count
    }
    
    ///computed property that returns a string formated due date
    var dueDateString : String {
        // Create Date Formatter
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = "MMM/dd/YYYY"

        // Convert Date to String
        return dateFormatter.string(from: due_date)
    }
    
    ///Adding Codable conformance for @Published properties
    enum CodingKeys: CodingKey {
        case due_date
        case checkList
        case reminder
    }
    
    ///Adding Codable conformance for @Published properties
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        due_date = try container.decode(Date.self, forKey: .due_date)
        checkList = try container.decode([Task].self, forKey: .checkList)
        reminder = try container.decode(Date.self, forKey: .reminder)
    }
    
    ///Adding Codable conformance for @Published properties
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(due_date, forKey: .due_date)
        try container.encode(checkList, forKey: .checkList)
        try container.encode(reminder, forKey: .reminder)
    }
    
    ///Initializer
    init(title: String, difficulty: DifficultyLevel, notes: String, tags: [Tag], due_date: Date, checkList: [Task], reminder: Date) {
        super.init(title: title, difficulty: difficulty, notes: notes, tags: tags,isComplete: false)
        self.due_date = due_date
        self.checkList = checkList
        self.reminder = reminder
    }
    
    ///Convenience function to copy from an existing todo item
    ///In parameter -- `from`  -- existing todo to copy from
    ///
    func copy(from:Todo) {
        self.due_date = from.due_date
        self.checkList = from.checkList
        self.reminder = from.reminder
        self.title  =  from.title
        self.isComplete = from.isComplete
        self.difficulty = from.difficulty
        self.tags = from.tags
        self.notes =  from.notes
    }
    
    ///Convenience function to get an empty todo
    static func getAnEmptyToDo() -> Todo {
        return Todo(title: "", difficulty: .easy, notes: "", tags: [Tag](), due_date: Date.now.endOfDay, checkList: [Task](), reminder: Date.now.endOfDay)
    }
    
    ///Check if todo's due date is within a time interval
    ///In parameter --`interval` :  # of days
    ///Return          --`Bool` true means todo's due date is within interval
    ///
    func isWithinDays(interval: Int) -> Bool {
        if Date.now.interval(ofComponent: .day, fromDate: due_date) < interval {
            return true
        }
        else {
            return false
        }
    }
    

}
enum DifficultyLevel: String, CaseIterable, Identifiable, Codable {
    var id: String { self.rawValue }
    case easy
    case medium
    case hard
}

enum Tag: String, CaseIterable, Identifiable, Codable {
    var id: String { self.rawValue }
    case work
    case school
    case health
    case chores
}

///
///Utitliy extensions for Date, all convenience functions
///
extension Date {
    init(_ dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        let date = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:date)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}

///Utitliy extensions for Date,
extension Date {
    ///Check if date is within today's range
    ///Return -- `Bool`: true means date is within today's range
    func isWithInToday() -> Bool {
        let startOfToday = Date.now.startOfDay
        let endOfToday = Date.now.endOfDay
        let range = startOfToday...endOfToday
        if range.contains(self) {
            return true
        }
        else {
            return false
        }
    }
    
    ///Check if date is earlier than today
    ///Return -- `Bool`: true means date is earlier than today
    func isOverDue() -> Bool {
        if self < Date.now.startOfDay {
            return true
        }
        else {
            return false
        }
    }
}

///Utitliy extensions for Date,
extension Date {
    ///find number of calendar days between two dates, referenced from
    ///https://stackoverflow.com/questions/40075850/swift-3-find-number-of-calendar-days-between-two-dates
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {

        let currentCalendar = Calendar.current

        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }

        return end - start
    }
    
    func today() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM/dd/yyyy"
        return dateFormatter.string(from: Date.now)
    }
    
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM/dd/yyyy"
        return dateFormatter.string(from: self)
    }
    
    
    //set a time-based dynamic greeting message, referenced from
    //https://freakycoder.com/ios-notes-51-how-to-set-a-time-based-dynamic-greeting-message-swift-5-6c629632ceb5
    func greetings() -> String {
      let hour = Calendar.current.component(.hour, from: Date())
      
      let NEW_DAY = 0
      let NOON = 12
      let SUNSET = 18
      let MIDNIGHT = 24
      
      var greetingText = "Hello" // Default greeting text
      switch hour {
      case NEW_DAY..<NOON:
          greetingText = "Good Morning"
      case NOON..<SUNSET:
          greetingText = "Good Afternoon"
      case SUNSET..<MIDNIGHT:
          greetingText = "Good Evening"
      default:
          _ = "Hello"
      }
      
      return greetingText
    }
}
