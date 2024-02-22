//
//ToDoView.swift
//
///This view presents a list of todos.  It divides the screen into 3 parts:
///The very top portion shows user's avatar, today's date, greetings, a sort button and a "+" button to add new todo
///The middle portion shows 2 things:  today's todo completion status and user's total coins
///The last part shows a list of todos.  By default, it shows all todos without any filters.
///
///On this screen, user can:
///1. Sort todos by clicking on sort button at the top right
///2. Add a new todo by clicking on "+" button at the top right
///3. Swipe any todo to delete it.
///4. Click on the checkbox next to the todo to mark the todo item as complete or not complete
///
///This view uses @EnvironmentObject dataModel to get interact with model layer
///
import SwiftUI

let shadeAreaWidth = UIScreen.main.bounds.width - 20
let shadeAreaBackgroundColor = Color.gray.opacity(0.15)
let cornerRadiusValue = CGFloat(15)
let blueColor = Color(uiColor: UIColor(rgb: 0x638CEB))
let orangeColor = Color(uiColor: UIColor(rgb: 0xFFCC99))
let pinkColor = Color(uiColor: UIColor(rgb: 0xFF6666))
let statusCircleHeight = 45.0
let middleViewBackgroundColor = UIColor(red:11/255.0, green: 15/255.0, blue: 128/255.0, alpha: 1)
let roundButtonWidth = 35.0

struct ToDoView: View {
    @EnvironmentObject var dataModel : DataModel
    @State var selectedCategory = ToDoCategory.All
    @State var selectedTags = [Tag]()
    
    var body: some View {
        NavigationView {
            VStack (alignment: .center){
                //avatar
                HeaderToDoView(selectedCategory: $selectedCategory, selectedTags: $selectedTags)
                    .frame(width: shadeAreaWidth)
                    .offset(y:5)
                
                //award
                MiddleView()
                    .frame(width: shadeAreaWidth, height: 70)
                
                //list of todos
                BottomToDoView(selectedCategory: selectedCategory, selectedTags: selectedTags)
                    .frame(width: shadeAreaWidth)
                
                Spacer()
            }
        }
    }
}

///
///Header view for ToDoView
///It displays user's avatar, today's date, greetings, a sort button and a "+" button
///
struct HeaderToDoView: View {
    @EnvironmentObject var dataModel : DataModel
    @State private var showingSheet = false
    @Binding var selectedCategory: ToDoCategory
    @Binding var selectedTags: [Tag]
    
    var body: some View {
        HStack {
            AvatarView(avatar: dataModel.user.avatar)
                .frame(width:80, height:80)
                .background(.yellow.opacity(0.2))
            
            VStack (alignment: .leading, spacing: 10){
                Text("\(Date().greetings()) \(dataModel.user.name)!")
                Text(Date().today())
                    .font(.system(size: 10))
            }
            Spacer()
            
            //sort button
            Button(action: {
                showingSheet.toggle()
            }, label: {
                Image("sort_down")
                    .resizable()
                    .font(.system(.largeTitle))
                    .frame(width: roundButtonWidth, height: roundButtonWidth)
                    .foregroundColor(Color.white)
            })
            .background( Color.yellow.opacity(0.6))
            .cornerRadius(roundButtonWidth/2)
            .shadow(color: Color.black.opacity(0.3),
                    radius: 3,
                    x: 3,
                    y: 3)
            .sheet(isPresented: $showingSheet) {
                FilterSheet(showingSheet: $showingSheet, selectedCategory: $selectedCategory, selectedTags: $selectedTags)
                    .presentationDetents([.medium])
            }
            
            //add button
            NavigationLink(destination: {
                ToDoDetailsView(toDo: dataModel.user.toDoList[0], type: .New)
            }, label: {
                Text("+")
                    .font(.system(.largeTitle))
                    .frame(width: roundButtonWidth, height: roundButtonWidth)
                    .foregroundColor(Color(middleViewBackgroundColor))
            })
            .background( Color.yellow.opacity(0.6))
            .cornerRadius(roundButtonWidth/2)
            .shadow(color: Color.black.opacity(0.3),
                    radius: 3,
                    x: 3,
                    y: 3)
        }
    }
}

///This view presents middle portion of ToDoView
///It displays today's todo completion status, when 100% today's todos are completed, the status shows 100% and there is a firework animation to celebrate it.
///It also displays user's total coins.
///
struct MiddleView: View {
    @EnvironmentObject var dataModel : DataModel
    var body: some View {
        ZStack {
            Color(middleViewBackgroundColor)
            HStack {
                HStack (spacing:0){
                    Text("Today's completion")
                        .foregroundColor(.white)
                        .font(.system(size:12))
                        .padding()
                    ZStack {
                        //track circle
                        Circle()
                            .stroke(.white.opacity(0.3),
                                    style: StrokeStyle(lineWidth: 10))
                            .frame(width: statusCircleHeight, height: statusCircleHeight)
                        
                        //Animation circle
                        Circle()
                            .trim(from:0, to: dataModel.userToDoCompletionStatus)
                            .stroke(.yellow,
                                    style: StrokeStyle(lineWidth: 10))
                            .rotationEffect(.init(degrees: -90))
                            .animation(Animation.linear(duration:0.8), value: dataModel.userToDoCompletionStatus)
                            .frame(width: statusCircleHeight, height: statusCircleHeight)
                        
                        
                        Text( String(format: "%.1f", dataModel.userToDoCompletionStatus * 100))
                            .foregroundColor(.white)
                            .font(.system(size:14))
                    }
                }
                Spacer()
                HStack (spacing: 0) {
                    Image("Coin")
                        .resizable()
                        .frame(width: 25, height: 25)
                    
                    Text(String(format: "coin %i", dataModel.user.award.coin))
                        .foregroundColor(.white)
                        .font(.system(size:18))
                        .padding(.trailing, 10)
                        .padding(.leading, 5)
                }
            }
            
            //fireworks animation
            if dataModel.userToDoCompletionStatus == 1.0 {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)
                    .modifier(ParticlesModifier())
                    .offset(x: -100, y : -50)
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
                    .modifier(ParticlesModifier())
                    .offset(x: 60, y : 70)
            }
        }
    }
}

///
///This views displays a list of todos for ToDoView.
///For each individual todo, user can swipe to delete a todo, toggle complete/not-complete status of a todo
///
struct BottomToDoView: View {
    @EnvironmentObject var dataModel : DataModel
    var selectedCategory: ToDoCategory
    var selectedTags: [Tag]
    var body: some View {
        List {
            ForEach(dataModel.user.toDoList) { toDo in
                if shouldShowToDo(toDo: toDo, selectedCategory: selectedCategory, selectedTags: selectedTags){
                    HStack{
                        CheckToDoView(toDo: toDo)
                            .cornerRadius(cornerRadiusValue)
                    }
                }
            }
            .onDelete(perform: { indexSet in
                guard let index = indexSet.first else {
                    return
                }
                dataModel.user.toDoList.remove(at: index)
                //this line is not needed, deleting a todo does not affect coin or completion status
                // dataModel.updateView()
            })
            .listRowInsets(.init(top: 5, leading: 0, bottom: 5, trailing: 0))
            .listRowSeparator(.hidden)
        }
        // remove space at the top of List comes from this post:
        //https://developer.apple.com/forums/thread/662544
        .listStyle(PlainListStyle())
    }
    
    ///
    ///This function determines if a todo should be shown based on filter selection
    ///
    ///It accepts 3 parameters:
    ///         -- `toDo`: the subject to be judged
    ///         -- `selectedCategory`: of Enum type ToDoCategory, possible values are Active, All, Completed and Today
    ///                        Active means to display those todos whose due date is not past past due
    ///                        All means to display every todo, this is the default setting.
    ///                        Completed means to display those todos who is marked as complete
    ///                        Today means to display those todos whose due date is within today.
    ///         -- `selectedTags`: array of Tag,  if more than 2 tags are selected, e.g. work and school, then either work OR work
    ///                     todos are displayed.  If no tags are selected, it means there is no filter for tags.
    ///it returns a `Bool`, true means the toDo should be displayed
    ///
    func shouldShowToDo(toDo: Todo, selectedCategory: ToDoCategory, selectedTags: [Tag] ) -> Bool {
        var shouldDisplay = false
        
        switch selectedCategory {
        case .Active:
            if toDo.due_date > Date.now.endOfDay && !toDo.isComplete {
                shouldDisplay = true
            }
        case .All :
            shouldDisplay = true
            
        case .Completed :
            shouldDisplay = toDo.isComplete
            
        case .Today :
            shouldDisplay = toDo.due_date.isWithInToday()
        }
        
        if !shouldDisplay {
            return false
        }
        
        guard selectedTags.count > 0
        else {
            return shouldDisplay
        }
        
        shouldDisplay = false
        //if multiple tags are checked in the filter, it's OR relationship
        for tag in selectedTags {
            if toDo.tags.contains(tag) {
                shouldDisplay = true
                break
            }
        }
        
        return shouldDisplay
    }
}

///Utility extension for UIColor
///Use rgb to represent a UIColor, it comes from this post:
///https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

///
///This view presents a circle with animation
///In parameter: `percent` is a @State variable, its value is from 0.0 to 1.0
///
struct StatusCircle : View {
    @State var percent: CGFloat
    var body: some View {
        VStack{
            ZStack {
                Color(UIColor(red:11/255.0,
                              green: 15/255.0,
                              blue: 128/255.0,
                              alpha: 1))
                ZStack {
                    //track circle
                    Circle()
                        .stroke(.white.opacity(0.3),
                                style: StrokeStyle(lineWidth: 30))
                    //Andimation circle
                    Circle()
                        .trim(from:0, to: percent)
                        .stroke(.yellow,
                                style: StrokeStyle(lineWidth: 30))
                        .rotationEffect(.init(degrees: -90))
                        .animation(Animation.linear(duration:0.8), value: percent)
                    Text("\(Int(self.percent * 100.0))%")
                        .foregroundColor(.white)
                        .font(.system(size:52))
                }.padding()
            }
        }
    }
}

///This view presetns a firework effect
///Firework effect comes from this post:
///https://betterprogramming.pub/creating-confetti-particle-effects-using-swiftui-afda4240de6b
struct FireworkParticlesGeometryEffect : GeometryEffect {
    var time : Double
    var speed = Double.random(in: 20 ... 200)
    var direction = Double.random(in: -Double.pi ...  Double.pi)
    
    var animatableData: Double {
        get { time }
        set { time = newValue }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        let xTranslation = speed * cos(direction) * time
        let yTranslation = speed * sin(direction) * time
        let affineTranslation =  CGAffineTransform(translationX: xTranslation, y: yTranslation)
        return ProjectionTransform(affineTranslation)
    }
}

///
///This view works together with FireworkParticlesGeometryEffect to present a firework effect on the entire screen
///The code comes from this post:
///https://betterprogramming.pub/creating-confetti-particle-effects-using-swiftui-afda4240de6b
struct ParticlesModifier: ViewModifier {
    @State var time = 0.0
    @State var scale = 0.1
    let duration = 5.0
    func body(content: Content) -> some View {
        ZStack {
            ForEach(0..<80, id: \.self) { index in
                content
                    .hueRotation(Angle(degrees: time * 80))
                    .scaleEffect(scale)
                    .modifier(FireworkParticlesGeometryEffect(time: time))
                    .opacity(((duration-time) / duration))
            }
        }
        .onAppear {
            withAnimation (.easeOut(duration: duration)) {
                self.time = duration
                self.scale = 1.0
            }
        }
    }
}

struct ToDoView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoView().environmentObject(DataModel())
    }
}
