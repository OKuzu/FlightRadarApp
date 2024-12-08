import SwiftUI
import MapKit

struct MapView: View {
    @Binding var region: MKCoordinateRegion // The map's region
    var flights: [FlightState]              // Flight data to display

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: flights) { flight in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: flight.latitude ?? 0.0, longitude: flight.longitude ?? 0.0)) {
                VStack {
                    Image(systemName: "airplane")
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(flight.trueTrack ?? 0))
                    Text(flight.callsign ?? "Unknown")
                        .font(.caption)
                        .foregroundColor(.black)
                }
            }
        }
    }
}
