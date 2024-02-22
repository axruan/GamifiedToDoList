//
//  DateSelectionView.swift
//  EmoComponent
//
//  Created by Scarlett Ruan on 12/4/22.
//
/// The view displays a calendar to allow users to select a date.  The view shows up in its parent view only when `isShowing` is true
///
/// The parameters are:
///- `dateIn`:  Date type, passed in from parent view.
/// Upon entering the view, the view highlights the initial value of dateIn in caldendar. When users choose a new date,
/// the newly selected date is then saved as dateIn (because of @Binding modifier) and highlighted.
///- `isShowing`:  Bool value;  only when it's true this view shows up in its parent view
///
import SwiftUI

struct DateSelectionView: View {
    @Binding var dateIn : Date
    @Binding var isShowing : Bool
    @State var localDate: Date
    
    var body: some View {
        VStack {
            Button(action: {
                isShowing = false
                dateIn = localDate
            },
                   label: {
                Text("Done")
                    .bold()
                    .foregroundColor(.black)
            })
            DatePicker("",
                       selection: $localDate,
                       in: Date()...,
                       displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .onChange(of: dateIn, perform: { value in
                localDate = value
                //isShowing = false
            })
            .padding(.all, 20)
        }.frame(width: 400, height: 400, alignment: .center)
    }
}

struct DateSelectionView_Previews: PreviewProvider {
    @State static private var dateIn: Date = Date().addingTimeInterval(-4 * 24 * 60 * 60)
    @State static private var isShowing: Bool = true
    static var previews: some View {
        DateSelectionView(dateIn: $dateIn, isShowing: $isShowing, localDate: dateIn)
    }
}

