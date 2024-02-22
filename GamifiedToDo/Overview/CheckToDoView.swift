//
//  CheckView.swift
//  unit 4 proj
//
//  Created by Scarlett Ruan on 11/7/22.
//
///This view display a check next to a text in one line
///
///Parameter name: title is a String type, it's get displayed next to the checkbox
///
///The code is referenced from this article:
///https://makeapppie.com/2019/10/16/checkboxes-in-swiftui/
///
///I reused this file from previous project
///
import SwiftUI

struct CheckToDoView: View {
    @EnvironmentObject var dataModel : DataModel
    @State var hiddenFlag:Bool = false
    var toDo: Todo
    
    ///Internal function to CheckToDoView
    ///This function has no in coming parater, it returns a Color object
    ///If toDo's difficulty level is hard, return color is pink
    ///If toDo's difficulty level is medium, return color is orange
    ///If toDo's difficulty level is easy, return color is green
    ///
    func checkColor() -> Color {
        return toDo.difficulty == .easy ? .green : toDo.difficulty == .medium ? .orange : pinkColor
    }
    
    ///Internal function to CheckToDoView
    ///When user toggles checkmark of a todo, it has impacts to user's total award
    ///Give award to a complete todo only when the todo is not overdue.   Overdue todo does not earn any award.
    ///
    ///When a not-ovedue todo is marked as complete, give user award based on todo's difficulty level
    ///When a not-overdue todo is marked as not complete, minuse award based on todo's difficulty level
    ///
    func calculateAward() {
        //adjust award only when toDo's is not overdue
        if toDo.due_date > Date.now.startOfDay {
            if toDo.isComplete{
                dataModel.user.award.add(award:dataModel.rules.getAward(taskLevel: toDo.difficulty))
            }
            else {
                dataModel.user.award.minus(award:dataModel.rules.getAward(taskLevel: toDo.difficulty))
            }
        }
    }
    
    var body: some View {
        HStack (alignment: .center){
            Image(systemName: toDo.isComplete ? "checkmark.circle.fill": "circle")
                .frame(maxHeight: .infinity)
                .padding()
                .foregroundColor(.black)
                .background(checkColor())
                .onTapGesture {
                    toDo.isComplete.toggle()
                    calculateAward()
                    
                    //without the following line, middle view's coin is not updated
                    //force a view to update comes from this post:
                    //https://stackoverflow.com/questions/56561630/swiftui-forcing-an-update
                    dataModel.updateView()
                    hiddenFlag.toggle()
                }
            
            VStack (alignment: .leading){
                NavigationLink(
                    destination: ToDoDetailsView(toDo: toDo, type: .Edit),
                    label: {
                        Text(toDo.title)
                            .font(.system(size: 18))
                            .strikethrough(toDo.isComplete )
                            .foregroundColor(toDo.isComplete  ? .gray : .black)
                            .multilineTextAlignment(.leading)
                    })
                
                Label(title: { Text(toDo.dueDateString)
                        .foregroundColor(toDo.isComplete  ? .gray : .black)
                        .font(.system(size: 14))
                            },
                      icon: {Image(systemName: "calendar")
                        .foregroundColor(toDo.isComplete ? .gray : .black)
                        .font(.system(size: 14))
                    
                })
            }
            .frame(maxHeight: .infinity)

            Spacer()
            
            //display fraction
            if toDo.numberOfCheckList != 0 {
                FractionView(numerator: toDo.numberofCompletedCheckList, denominator: toDo.numberOfCheckList)
                    .padding(.trailing, 5)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .cornerRadius(cornerRadiusValue)
        .background(.gray.opacity(0.15))
    }
}

///
///This view displays a fraction to reflect complete status of a todo
///If a todo has a non-empty checklist, which is a smaller task for the todo, user can mark individual checklist as complete
///this view shows a fraction, numerator is # of completed checklist items. denominator is the total number of checklist
///
struct FractionView: View {
    var numerator: Int
    var denominator: Int
    var body: some View {
        VStack (alignment: .center, spacing: 0){
            Text(String(numerator))
            Text("--")
            Text(String(denominator))
        }
        .font(.system(size: 10))
        .bold()
        
    }
}

struct CheckToDoView_Previews: PreviewProvider {
    @StateObject static var user = User.getASampleUser()
    
    static var previews: some View {
        CheckToDoView(toDo: user.toDoList[4])
    }
}
