///
///DataModel layer for this app
///
///It contains a published variable of User type,  the published variable's content can be updated by the user of this app
///It also contains a variabled of Rules type, it's preset and fixed.
///
///
import Foundation

class DataModel:ObservableObject {
    @Published var user: User {
        didSet {
            saveUser()
        }
    }
    var rules: Rules = Rules()
    
    ///initializer
    init() {
        user = User.getASampleUser()
        if let data = UserDefaults.standard.data(forKey: "user") {
            do {
                let decoded = try JSONDecoder().decode(User.self, from: data)
                user = decoded
                print(decoded)
            } catch {
                print(error)
            }
        }
    }

    ///Calculate percentage of today's todo completion
    var userToDoCompletionStatus: CGFloat {
        var total: Int = 0
        var completed: Int = 0
        
        user.toDoList.forEach{ toDo in
            //look for due_date is today's to do item, only calculate those
            if toDo.due_date.isWithInToday() {
                total += rules.getAward(taskLevel: toDo.difficulty).coin
                completed += getFractionCoinsFromAToDo(toDo: toDo)
            }
        }
        
        if total == 0 {
            return 0.0
        }
        else {
            return Double(completed) / Double(total)
        }
    }
    
    
    ///Get # of coins earned for a todo
    ///if it's overdue todo, no award is earned regardless it's complete or not
    ///In parameter -- `toDo`: the todo to be evaluated
    ///Return --`Int`: the # of coins earned fron the todo.  If a todo is not complete,
    ///and it has a non-empty checklist, some checklist is marked as completed, then the
    ///coin is earned propotionally
    func getFractionCoinsFromAToDo (toDo: Todo) -> Int {
        guard !toDo.due_date.isOverDue()
        else {
            return 0
        }
        
        var result = 0;
        if toDo.isComplete {
            result += rules.getAward(taskLevel: toDo.difficulty).coin
        }
        else {
            let toDoItemCoin = rules.getAward(taskLevel: toDo.difficulty).coin
            if toDo.checkList.count > 0  {
                let toDoItemCheckItemCoin = toDoItemCoin/toDo.checkList.count
                toDo.checkList.forEach{ checkItem in
                    if checkItem.isComplete {
                        result += toDoItemCheckItemCoin
                    }
                }
            }
        }
        
        return result
    }
    
    ///force a view to update comes from this post:
    ///https://stackoverflow.com/questions/56561630/swiftui-forcing-an-update
    func updateView(){
        self.objectWillChange.send()
        saveUser()
    }
    
    ///Persist user to UserDefaults
    func saveUser() {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "user")
        }
    }
    
    ///Remove a todo from user's todo list
    ///In parameter --`whichIs`: the totdo to be deleted
    func removeToDo(whichIs: Todo) -> Void{
        // guard user.toDoList != nil else { return }
        if let idx = user.toDoList.firstIndex(where: { $0 === whichIs }) {
            user.toDoList.remove(at: idx)
        }
        updateView()
    }
    
    ///Sort todo list based on due date
    func sortToDoListByDueDate() {
        user.toDoList.sort{$0.due_date < $1.due_date}
    }
}
