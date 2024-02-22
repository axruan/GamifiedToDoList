//
//ToDoDetailsView.swift
//
///This view displays details for a todo.  It's used as a new todo screen and edit an existing todo screen
///It accepts 2 parameters:
///         -- `existingToDo`:  If this is Edit type, this parameter represents the existing todo to be edited.
///                     If this is New type, this paramter is passed in a dummy todo, not used.
///         -- `type`: enum type of DetailsType.
///               Edit means this screen is for an existing todo editing,
///               New means this screen is invoked when user clicks "+" button on ToDoView screen
///
import SwiftUI

let checkListSignSize = 12.0

enum DetailsType: String {
    case Edit
    case New
}

struct ToDoDetailsView: View {
    @EnvironmentObject var dataModel : DataModel
    @Environment(\.dismiss) private var dismiss
    var existingToDo: Todo
    @State private var datePopOverPresented = false
    @StateObject var localToDo: Todo = Todo.getAnEmptyToDo()
    @State var hiddenTrigger = false
    var type: DetailsType
    
    init(toDo: Todo, type: DetailsType) {
        self.existingToDo = toDo
        self.type = type
    }
    
    var body: some View {
        VStack {
            Form {
                //notes
                Section (header: Text("Title")){
                    TextField("",
                              text: $localToDo.title)
                }
                
                Section (header: Text("Notes")){
                    TextField("",
                              text:$localToDo.notes)
                }
                
                //checklist
                Section (header: Text("Checklist (Swipe to delete)")){
                    CheckListView(checkList: $localToDo.checkList, hiddenFlag: $hiddenTrigger)
                }
                
                //difficulty
                Section (header: Text("Difficulty Level")){
                    HStack {
                        ForEach(DifficultyLevel.allCases) { level in
                            Button(action: {
                                
                            }) {
                                Image(localToDo.difficulty == level ? "\(level.rawValue)_filled": level.rawValue)
                                    .resizable()
                                    .frame(width: 60,
                                           height: 50)
                            }
                            .padding()
                            .onTapGesture {
                                localToDo.difficulty = level
                                hiddenTrigger.toggle()
                            }
                        }
                    }
                }
                
                //scheduling -  due date
                Section (header: Text("Due Date")){
                    HStack{
                        Text(localToDo.dueDateString)
                        Spacer()
                        
                        //date
                        Button(action: {
                            datePopOverPresented = true
                        },
                               label: {
                            Image(systemName: "calendar")
                                .foregroundColor(.black)
                        })
                        //date selection popover
                        .popover(isPresented: $datePopOverPresented) {
                            DateSelectionView(dateIn: $localToDo.due_date,
                                              isShowing: $datePopOverPresented,
                                              localDate: localToDo.due_date)
                        }
                    }
                }
                
                //Tags
                Section (header: Text("Tags")){
                    VStack (spacing: 0){
                        ForEach(Tag.allCases) {tag in
                            HStack (alignment: .center){
                                Image(systemName: localToDo.tags.contains(tag) ? "checkmark.square.fill": "square")
                                    .frame(maxHeight: .infinity)
                                    .padding()
                                    .foregroundColor(.black)
                                    .onTapGesture {
                                        //adjust tags
                                        if localToDo.tags.contains(tag) {
                                            let index = localToDo.tags.firstIndex { $0 == tag }
                                            localToDo.tags.remove(at:index!)
                                        }
                                        else {
                                            localToDo.tags.append(tag)
                                        }
                                        
                                        hiddenTrigger.toggle()
                                    }
                                Text(tag.rawValue)
                                    .padding(.top, 10)
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }//end of form
        }//end of vstack
        .toolbar{
            ToolbarItemGroup(placement: ToolbarItemPlacement.navigationBarTrailing,
                             content: {
                //show SAVE button only when todo is not complete
                if !existingToDo.isComplete || type == .New {
                    HStack{
                        Button(action: {
                            if type == .Edit {
                                existingToDo.copy(from:localToDo)
                                dataModel.sortToDoListByDueDate()
                            }
                            else {
                                dataModel.user.toDoList.append(localToDo)
                                dataModel.sortToDoListByDueDate()
                            }
                            
                            //this line is required to see newly added/edited todo reflected on the main screen
                            //force a view to update comes from this post:
                            //https://stackoverflow.com/questions/56561630/swiftui-forcing-an-update
                            dataModel.updateView()
                            
                            dismiss()
                            
                        }, label: {
                            Text("SAVE")
                                .bold()
                        })
                        //does not allow to save without a title
                        .disabled(localToDo.title == "")
                    }
                }
            })
        }
        //this is the way to set value for a @StateObject
        //referenced from this post:
        //https://stackoverflow.com/questions/58327013/swift-5-whats-escaping-closure-captures-mutating-self-parameter-and-how-t
        .onAppear{
            if type == .Edit {
                localToDo.copy(from: existingToDo)
            }
        }
    }
}

///
///This view allows user to add new checklist to todo.
///On this screen, user can
///1. add a new checklist
///2. mark a checklist as complete by check the box next to the checklist
///3. swipe to delete a checklist
///
struct CheckListView: View {
    @Binding var checkList: [Task]
    @State var localEntry: String = ""
    @Binding var hiddenFlag: Bool
    var body: some View{
        List{
            HStack {
                TextField("Enter new item...", text: $localEntry)
                Button(action: {
                    if !localEntry.isEmpty {
                        let newItem = Task(title: localEntry,
                                           difficulty: .easy,
                                           notes: "",
                                           tags: [],
                                           isComplete: false)
                        checkList.append(newItem)
                        localEntry = ""
                    }
                }, label: {
                    Text("Add")
                })
            }
            
            Section {
                ForEach ($checkList) {checkItem in
                    VStack(alignment: .leading) {
                        Label(title: {Text(checkItem.title.wrappedValue)},
                              icon: { Image(systemName: checkItem.isComplete.wrappedValue ? "checkmark.square.fill" : "square")
                        })
                        .onTapGesture {
                            checkItem.isComplete.wrappedValue.toggle()
                            hiddenFlag.toggle()
                        }
                    }
                }
                .onDelete(perform: { indexSet in
                    guard let index = indexSet.first else {
                        return
                    }
                    checkList.remove(at: index)
                })
            }
        }
    }
}

struct ToDoDetailsView_Previews: PreviewProvider {
    @StateObject static var user = User.getASampleUser()
    static var previews: some View {
        ToDoDetailsView(toDo: user.toDoList[0],type: .Edit)
        //ToDoDetailsView(toDo: $toDo, type: .New)
    }
}
