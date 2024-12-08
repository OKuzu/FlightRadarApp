import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = FlightViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.913238,
                                       longitude: 29.042888),
        span: MKCoordinateSpan(latitudeDelta: 5.0,
                               longitudeDelta: 5.0) // Starting point
    )


    var body: some View {
        VStack {
            // Map View displaying flights
            MapView(region: $region, flights: viewModel.flights)

            // Refresh Button
            Button(action: {
                viewModel.fetchFlights()
            }) {
                Text("Refresh Flights")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onTapGesture {
            // When user interact with app, timer for fetching data will restart from 0 and count to 5 again
            viewModel.restartInactivityTimer()
        }
        .onAppear {
            // Fetch flights initially and start the timer fetch flight in 5 seconds
            viewModel.fetchFlights()
            viewModel.restartInactivityTimer()
        }
    }

}
