///
///Main entrance to the app
///
///It puts a new DataModel object as an enviornment object, the environment object is shared among all screens
///
import SwiftUI

struct ContentView: View {
    var body: some View {
        Overview()
            .environmentObject(DataModel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(DataModel())
    }
}
