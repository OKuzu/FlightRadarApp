import Foundation

struct AnyDecodable: Decodable {
    let value: Any?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            self.value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            self.value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            self.value = boolValue
        } else {
            self.value = nil
        }
    }
}

// Basic FlightResponse model with `states` as raw data
struct FlightResponse: Decodable {
    let time: Int
    let states: [[Any?]]

    enum CodingKeys: String, CodingKey {
        case time
        case states
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.time = try container.decode(Int.self, forKey: .time)

        // Decode `states` manually using an intermediate container
        let rawStates = try container.decode([[AnyDecodable]].self, forKey: .states)
        self.states = rawStates.map { $0.map { $0.value } }
    }
}


// Individual flight state
struct FlightState: Identifiable {
    var id = UUID()
    let icao24: String
    let callsign: String?
    let originCountry: String
    let timePosition: Int?
    let lastContact: Int
    let longitude: Double?
    let latitude: Double?
    let baroAltitude: Double?
    let onGround: Bool
    let velocity: Double?
    let trueTrack: Double?
    let verticalRate: Double?
    let geoAltitude: Double?
    let squawk: String?
    let spi: Bool
    let positionSource: Int

    // Create a FlightState instance from raw data
    init?(from rawState: [Any?]) {
        guard rawState.count >= 17,
              let icao24 = rawState[0] as? String,
              let originCountry = rawState[2] as? String,
              let lastContact = rawState[4] as? Int,
              let onGround = rawState[8] as? Bool,
              let spi = rawState[15] as? Bool,
              let positionSource = rawState[16] as? Int else {
            return nil
        }

        self.icao24 = icao24
        self.callsign = rawState[1] as? String
        self.originCountry = originCountry
        self.timePosition = rawState[3] as? Int
        self.lastContact = lastContact
        self.longitude = rawState[5] as? Double
        self.latitude = rawState[6] as? Double
        self.baroAltitude = rawState[7] as? Double
        self.onGround = onGround
        self.velocity = rawState[9] as? Double
        self.trueTrack = rawState[10] as? Double
        self.verticalRate = rawState[11] as? Double
        self.geoAltitude = rawState[13] as? Double
        self.squawk = rawState[14] as? String
        self.spi = spi
        self.positionSource = positionSource
    }
}
