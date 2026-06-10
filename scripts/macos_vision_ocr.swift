#!/usr/bin/env swift
import Foundation
import Vision
import CoreGraphics

struct TextItem: Codable {
    let text: String
    let confidence: Float
    let box: [String: Double]
}

struct Output: Codable {
    let ok: Bool
    let engine: String
    let items: [TextItem]?
    let error: String?
}

func emit(_ output: Output) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted]
    if let data = try? encoder.encode(output), let s = String(data: data, encoding: .utf8) {
        print(s)
    }
}

func parseArgs() -> (path: String, languages: [String]) {
    var path: String?
    var langs: [String] = []
    var i = 1
    while i < CommandLine.arguments.count {
        let arg = CommandLine.arguments[i]
        if arg == "--languages" || arg == "-l" {
            i += 1
            if i < CommandLine.arguments.count {
                langs = CommandLine.arguments[i].split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            }
        } else if !arg.hasPrefix("-") && path == nil {
            path = arg
        }
        i += 1
    }
    if let p = path {
        return (p, langs)
    }
    emit(Output(ok: false, engine: "apple_vision", items: nil, error: "Usage: macos_vision_ocr.swift [--languages en-US,zh-Hans] <image_path>"))
    exit(1)
}

let (imagePath, userLanguages) = parseArgs()
let url = URL(fileURLWithPath: imagePath)

let request = VNRecognizeTextRequest()
request.recognitionLevel = .accurate
request.usesLanguageCorrection = true
if #available(macOS 13.0, *) {
    request.automaticallyDetectsLanguage = userLanguages.isEmpty
}
if userLanguages.isEmpty {
    request.recognitionLanguages = ["en-US", "zh-Hans", "zh-Hant"]
} else {
    request.recognitionLanguages = userLanguages
}

let handler = VNImageRequestHandler(url: url, options: [:])

do {
    try handler.perform([request])
    var items: [TextItem] = []
    for obs in request.results ?? [] {
        guard let candidate = obs.topCandidates(1).first else { continue }
        let box = obs.boundingBox
        items.append(TextItem(
            text: candidate.string,
            confidence: candidate.confidence,
            box: [
                "x": Double(box.origin.x),
                "y": Double(box.origin.y),
                "width": Double(box.width),
                "height": Double(box.height)
            ]
        ))
    }
    emit(Output(ok: true, engine: "apple_vision", items: items, error: nil))
} catch {
    emit(Output(ok: false, engine: "apple_vision", items: nil, error: String(describing: error)))
    exit(1)
}
