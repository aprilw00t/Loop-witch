import SwiftUI

struct ButtonView: View {
    let items = ["A", "B", "C", "1", "2", "3"]

    var body: some View {
        NavigationView {
            List(items, id: \.self) { item in
                HStack {
                    Text(item)

                    Spacer()

                    Menu {
                        Button("Option 1") {
                            print("Option 1 tapped for \(item)")
                        }
                        Button("Option 2") {
                            print("Option 2 tapped for \(item)")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("Symbol assignment")
        }
    }
}

#Preview {
    ButtonView()
}
