import Foundation

struct PredictionMetric: Identifiable {
    var id: String { category }
    let category: String
    let value: Double
}

class PredictionMetrics: ObservableObject, Identifiable {
    var data = [PredictionMetric]()
    var dictionary: [String : Double] = [:]
    init() {}
    
    func getNewPredictions(from probabilities: [String: Double]) {
        var tempData = [PredictionMetric]()
        dictionary = probabilities
        
        _ = dictionary.map { (key: String, value: Double) in
            tempData.append(PredictionMetric(category: key, value: value))
        }
        data = tempData.sorted(by: { $0.category > $1.category })
    }
}

extension PredictionMetric: Equatable {
    static func == (lhs: PredictionMetric, rhs: PredictionMetric) -> Bool {
        return lhs.id == rhs.id &&
               lhs.category == rhs.category &&
               lhs.value == rhs.value
    }
}
