//
//  FilterSheet.swift
//
///This view presents a filter for todos.  It's presented as a half sheet in ToDoView.  This view is invoked when user clicks on sort button on ToDoView
///
///The Filter has 2 parts, one is top 4 buttons: All, Active, Today and Complete.  User is allowed to select one button at a time
/// Second part is marked with Tags, user is allowed to selected more than 1 tag.
///
///The Reset button at the top right reset filter.
///
import SwiftUI

enum ToDoCategory: String, CaseIterable, Identifiable{
    var id: String { self.rawValue }
    case All
    case Active
    case Today
    case Completed
}

struct FilterSheet: View {
    @Binding var showingSheet: Bool
    @Binding var selectedCategory: ToDoCategory
    @Binding var selectedTags: [Tag]
    
    var body: some View {
        VStack {
            HStack{
                Text("Filters")
                    .bold()
                    .font(.system(size: 25))
                    .padding()
                
                Spacer()
                
                Button(action:{
                    selectedTags = [Tag]()
                    selectedCategory = .All
                }, label:{
                    Text("Reset")
                        .bold()
                })
                .padding()
            }
            
            HStack (spacing: 10){
                ForEach(ToDoCategory.allCases) {category in
                    Button(action:{selectedCategory = category},
                           label:{
                        ButtonText(isSelected: selectedCategory == category,
                                   title: category.rawValue)
                    })
                }
            }
            
            Spacer()
            Form{
                Section (header: Text("Tags")){
                    VStack (spacing: 0){
                        ForEach(Tag.allCases) {tag in
                            HStack (alignment: .center){
                                Image(systemName: selectedTags.contains(tag) ? "checkmark.square.fill": "square")
                                    .frame(maxHeight: .infinity)
                                    .padding()
                                    .foregroundColor(.black)
                                    .onTapGesture {
                                        //adjust selectedTags
                                         if selectedTags.contains(tag) {
                                         let index = selectedTags.firstIndex { $0 == tag }
                                             selectedTags.remove(at:index!)
                                         }
                                         else {
                                             selectedTags.append(tag)
                                         }
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
            }
            Spacer()
        }
    }
}

//Customize Text for Button
struct ButtonText: View {
    var isSelected: Bool = false
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size:15))
            .frame(width: shadeAreaWidth/4 - 15,
                   height: 50,
                   alignment: .center)
            .background(isSelected ? .blue : .gray.opacity(0.4))
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(8)
    }
}

struct FilterSheet_Previews: PreviewProvider {
    @State static var isShowing = true
    @State static var selectedCategory = ToDoCategory.All
    @State static var selectedTags = [Tag]()
    static var previews: some View {
        FilterSheet(showingSheet: $isShowing, selectedCategory: $selectedCategory, selectedTags: $selectedTags)
    }
}
