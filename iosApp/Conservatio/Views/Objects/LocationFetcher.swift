import CoreLocation

/// One-shot "where am I" helper for the object form. Asks for when-in-use
/// permission on first use and resolves with a single fix, or an error when
/// permission is denied or no fix arrives. Nothing keeps running afterwards.
final class LocationFetcher: NSObject, CLLocationManagerDelegate {
    enum FetchError: LocalizedError {
        case denied
        case unavailable

        var errorDescription: String? {
            switch self {
            case .denied: return "Location access is off. Allow it in Settings to use your current location."
            case .unavailable: return "Your current location could not be determined."
            }
        }
    }

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    func currentCoordinate() async throws -> CLLocationCoordinate2D {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                resume(.failure(FetchError.denied))
            default:
                manager.requestLocation()
            }
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard continuation != nil else { return }
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            resume(.failure(FetchError.denied))
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            resume(.failure(FetchError.unavailable))
            return
        }
        resume(.success(location.coordinate))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resume(.failure(FetchError.unavailable))
    }

    private func resume(_ result: Result<CLLocationCoordinate2D, Error>) {
        guard let continuation else { return }
        self.continuation = nil
        continuation.resume(with: result)
    }
}
