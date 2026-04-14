import Foundation
import UIKit

@MainActor
final class GeminiAIService {
    static let shared = GeminiAIService()

    private let logger = DebugLogger.shared
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/"
    private let maxRetries = 3

    private var apiKey: String? {
        GeminiKeychain.shared.getAPIKey()
    }

    // MARK: - Core Execution
    
    func generateContent(prompt: String, images: [UIImage] = [], model: String = "gemini-1.5-pro-latest", jsonMode: Bool = false) async -> String? {
        guard let key = apiKey, !key.isEmpty else {
            logger.log("GeminiAI: no API key — Please call GeminiAISetup.configure(apiKey:)", category: .automation, level: .error)
            return nil
        }

        var parts: [[String: Any]] = [["text": prompt]]
        
        for image in images {
            if let base64 = encodeImage(image) {
                parts.append([
                    "inline_data": [
                        "mime_type": "image/jpeg",
                        "data": base64
                    ]
                ])
            }
        }

        var body: [String: Any] = [
            "contents": [
                ["parts": parts]
            ],
            "generationConfig": [
                "temperature": 0.1
            ]
        ]
        
        if jsonMode {
            body["generationConfig"] = [
                "temperature": 0.1,
                "response_mime_type": "application/json"
            ]
        }

        return await callWithRetry(endpoint: "\(model):generateContent", body: body, key: key)
    }

    // MARK: - Generic JSON Extraction Bridge
    
    func extractJSON<T: Decodable>(prompt: String, images: [UIImage] = [], model: String = "gemini-1.5-flash-latest", type: T.Type) async -> T? {
        guard let responseStr = await generateContent(prompt: prompt, images: images, model: model, jsonMode: true),
              let data = responseStr.data(using: .utf8) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch {
            logger.log("GeminiAI: JSON extraction failed to decode to \(T.self) — \(error.localizedDescription) \nRaw Response: \(responseStr)", category: .automation, level: .error)
            return nil
        }
    }

    // MARK: - Validation API (Task 3)
    
    private struct TransitionResult: Decodable {
        let transitioned: Bool
    }

    func validateNavigationViaFlash(beforeImage: UIImage, afterImage: UIImage) async -> Bool {
        let prompt = """
        I am attempting to click a button to navigate forward or close a modal.
        Here are two screenshots: First is BEFORE the click, Second is AFTER the click.
        Did the UI completely transition? (Did a modal close or a page load?)
        Respond in JSON with a single key `transitioned: true/false`.
        """
        
        let result = await extractJSON(prompt: prompt, images: [beforeImage, afterImage], type: TransitionResult.self)
        return result?.transitioned ?? false
    }

    // MARK: - Network Request

    private func callWithRetry(endpoint: String, body: [String: Any], key: String) async -> String? {
        var lastError = ""
        for attempt in 0..<maxRetries {
            if attempt > 0 {
                let delay = pow(2.0, Double(attempt - 1)) * 0.5
                try? await Task.sleep(for: .seconds(delay))
            }

            guard let url = URL(string: "\(baseURL)\(endpoint)?key=\(key)") else {
                return nil
            }

            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")

            guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
                return nil
            }
            req.httpBody = httpBody

            do {
                let (data, response) = try await URLSession.shared.data(for: req)
                guard let http = response as? HTTPURLResponse else { continue }

                if http.statusCode == 429 || http.statusCode >= 500 {
                    lastError = "HTTP \(http.statusCode)"
                    continue
                }

                if http.statusCode != 200 {
                    let bodyStr = String(data: data, encoding: .utf8) ?? ""
                    lastError = "HTTP \(http.statusCode): \(bodyStr.prefix(120))"
                    logger.log("GeminiAI: \(lastError)", category: .automation, level: .error)
                    return nil
                }

                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let first = candidates.first,
                   let content = first["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let firstPart = parts.first,
                   let text = firstPart["text"] as? String {
                    return text
                }
            } catch {
                lastError = error.localizedDescription
            }
        }

        logger.log("GeminiAI: all attempts failed — \(lastError)", category: .automation, level: .error)
        return nil
    }

    // MARK: - Utilities
    
    private func encodeImage(_ image: UIImage) -> String? {
        let targetSize = CGSize(width: 1024, height: 1024)
        let scale = min(targetSize.width / image.size.width, targetSize.height / image.size.height, 1.0)
        let resized: UIImage
        if scale < 1.0 {
            let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        } else {
            resized = image
        }
        return resized.jpegData(compressionQuality: 0.7)?.base64EncodedString()
    }
}
