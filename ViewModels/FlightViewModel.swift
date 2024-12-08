import Foundation
import Combine
import MapKit

class FlightViewModel: ObservableObject {
    @Published var flights: [FlightState] = []

    private var cancellables = Set<AnyCancellable>()
    var inactivityTimer: Timer?

    private let session: URLSession // Injected URLSession instance

    init(session: URLSession = .shared) { // Default to URLSession.shared
        self.session = session
    }

    // MARK: - API Call
    func fetchFlights() {
        let url = APIConstants.flightsURL

        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }

        session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: FlightResponse.self, decoder: JSONDecoder())
            .map { response in
                response.states.compactMap { FlightState(from: $0) }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error fetching flights: \(error)")
                }
            }, receiveValue: { [weak self] flights in
                self?.flights = flights
                print("Fetched \(flights.count) flights")
            })
            .store(in: &cancellables)
    }

    // MARK: - Timer Management
    func restartInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.fetchFlights()
        }
    }
}
