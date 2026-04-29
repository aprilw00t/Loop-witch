import SwiftUI
import Vision

struct ContentView: View {
    @State private var fingerTips: [CGPoint] = []
    @State private var viewSize: CGSize = .zero

    
    private var pointsView: some View {
        ForEach(fingerTips.indices, id: \.self) { index in

            let pointWork = fingerTips[index]
            let screenSize = UIScreen.main.bounds.size
            let point = CGPoint(x:  (pointWork.y) * screenSize.width, y: pointWork.x * screenSize.height)

            Circle()
                .fill(.orange)
                .frame(width: 15)
                .position(x: point.x, y: point.y)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {

                CameraView { points in
                    fingerTips = points
                }

                pointsView

            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}



#Preview {
    ContentView()
}
