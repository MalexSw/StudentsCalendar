//import Foundation
//
//struct StoredDataModel: Codable {
//    let exchangeRate: Double
//    let lastUpdate: Date
//}
//
//class DataStorage {
//    enum StorageKeys: String {
//        case lastFetchTime
//        case storedData
//    }
//    
//    static let shared = DataStorage()
//    
//    private init() {}
//
//    var storedData: StoredDataModel? {
//        get {
//            if let savedData = UserDefaults.standard.data(forKey: StorageKeys.storedData.rawValue),
//               let decodedObj = try? JSONDecoder().decode(StoredDataModel.self, from: savedData) {
//                return decodedObj
//            } else {
//                return nil
//            }
//        }
//        set {
//            if let newValue, let data = try? JSONEncoder().encode(newValue) {
//                UserDefaults.standard.set(data, forKey: StorageKeys.storedData.rawValue)
//            } else {
//                UserDefaults.standard.removeObject(forKey: StorageKeys.storedData.rawValue)
//            }
//        }
//    }
//
//    var lastFetchTime: Date? {
//        get {
//            return UserDefaults.standard.object(forKey: StorageKeys.lastFetchTime.rawValue) as? Date
//        }
//        set {
//            UserDefaults.standard.setValue(newValue, forKey: StorageKeys.lastFetchTime.rawValue)
//        }
//    }
//    
//    /// Fetch data only if one hour has passed since the last update
//    func fetchDataIfNeeded(fetchFunction: @escaping () async -> StoredDataModel?) async {
//        let oneHourAgo = Date().addingTimeInterval(-3600)
//        
//        if let lastFetch = lastFetchTime, lastFetch > oneHourAgo {
//            print("Using cached data: \(storedData?.exchangeRate ?? 0.0)")
//            return
//        }
//        
//        print("Fetching new data...")
//        if let newData = await fetchFunction() {
//            storedData = newData
//            lastFetchTime = Date()
//        }
//    }
//}
