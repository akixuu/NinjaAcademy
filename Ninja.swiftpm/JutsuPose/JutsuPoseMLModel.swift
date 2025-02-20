//
//  JutsuPoseMLModel.swift
//  Ninja
//
//  Created by Aki Xu on 2025-02-19.
//

import Foundation
import CoreML

class JutsuPoseMLModel: NSObject, Identifiable {

    let name: String
    let mlModel: MLModel
    let url: URL

    init(name: String, mlModel: MLModel, url: URL) {
        self.name = name
        self.mlModel = mlModel
        self.url = url
    }

    func predict(poses: JutsuPoseClassifierInput) throws -> JutsuPoseClassifierOutput? {
        let features = try mlModel.prediction(from: poses)
        let output = JutsuPoseClassifierOutput(features: features)
        return output
    }
    
    private var classLabels: [Any] {
        mlModel.modelDescription.classLabels ?? []
    }
}

extension JutsuPoseMLModel {
    
    static func loadMLModel(from url: URL, as name: String) async throws -> JutsuPoseMLModel? {
        let model = try MLModel(contentsOf: url)
        return JutsuPoseMLModel(name: name, mlModel: model, url: url)
    }

    static func getDefaultMLModel() async -> JutsuPoseMLModel? {
        let compiledModelUrl = JutsuPoseClassifier.urlOfModelInThisBundle
        do {
            let jutsuMLModel = try await JutsuPoseMLModel.loadMLModel(from: compiledModelUrl, as: "Jutsu Pose ML Model")
            return jutsuMLModel
        }
        catch {
            print("Could not load default ML model: \(error.localizedDescription)")
            return nil
        }
    }
}

extension JutsuPoseClassifierOutput {
    
    func getOutputProbabilities() -> [String : Double] {
        return self.provider.featureValue(for: "labelProbabilities")?.dictionaryValue as? [String : Double] ?? [:]
    }
    
    func getOutputLabel() -> String {
        return self.provider.featureValue(for: "label")?.stringValue ?? ""
    }
}

extension JutsuPoseClassifierInput: @unchecked Sendable {}
extension JutsuPoseClassifierOutput: @unchecked Sendable {}
