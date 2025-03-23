import CoreData
//
//  PuterAIService.swift
//  ResilientMe
//
//  Created by Sayed Mohamed on 21.03.25.
//

import Foundation
import WebKit
import Combine

// MARK: - AI Service

class PuterAIService: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    private var webView: WKWebView?
    private var completion: ((Result<String, Error>) -> Void)?
    private var pendingQueries = [String: (Result<String, Error>) -> Void]()
    private let initializationSubject = PassthroughSubject<Bool, Never>()
    var isInitialized: AnyPublisher<Bool, Never> {
        return initializationSubject.eraseToAnyPublisher()
    }
    
    private var queryCounter = 0
    
    enum PuterAIError: Error {
        case notInitialized
        case requestFailed(String)
    }
    
    override init() {
        super.init()
        setupWebView()
    }
    
    private func setupWebView() {
        // Create configuration with content controller
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        // Add script message handlers
        contentController.add(self, name: "puterAICallback")
        contentController.add(self, name: "puterAIError")
        contentController.add(self, name: "puterAIInitialized")
        
        configuration.userContentController = contentController
        
        // Create invisible webview
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView?.navigationDelegate = self
        
        // Load the HTML with Puter script
        let html = """
        <html>
        <head>
            <script src="https://js.puter.com/v2/"></script>
            <script>
                // Tell Swift when Puter is initialized
                window.addEventListener('load', function() {
                    // Small delay to ensure Puter JS is loaded
                    setTimeout(function() {
                        if (typeof puter !== 'undefined' && puter.ai && puter.ai.chat) {
                            window.webkit.messageHandlers.puterAIInitialized.postMessage(true);
                        } else {
                            window.webkit.messageHandlers.puterAIError.postMessage("Puter API not loaded");
                        }
                    }, 500);
                });
                
                // Function to send AI queries from Swift
                async function sendAIQuery(queryId, prompt, options) {
                    try {
                        const parsedOptions = JSON.parse(options);
                        const response = await puter.ai.chat(prompt, parsedOptions);
                        window.webkit.messageHandlers.puterAICallback.postMessage({
                            queryId: queryId,
                            response: response.message?.content || JSON.stringify(response)
                        });
                    } catch (error) {
                        window.webkit.messageHandlers.puterAIError.postMessage({
                            queryId: queryId,
                            error: error.toString()
                        });
                    }
                }
            </script>
        </head>
        <body>
            <div id="status">Initializing Puter AI...</div>
        </body>
        </html>
        """
        
        webView?.loadHTMLString(html, baseURL: nil)
    }
    
    // WKNavigationDelegate methods
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("WebView loaded")
    }
    
    // WKScriptMessageHandler method
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "puterAIInitialized":
            print("Puter AI initialized")
            initializationSubject.send(true)
            
        case "puterAICallback":
            if let response = message.body as? [String: Any],
               let queryId = response["queryId"] as? String,
               let result = response["response"] as? String {
                pendingQueries[queryId]?(.success(result))
                pendingQueries.removeValue(forKey: queryId)
            }
            
        case "puterAIError":
            if let errorData = message.body as? [String: Any],
               let queryId = errorData["queryId"] as? String,
               let errorMessage = errorData["error"] as? String {
                pendingQueries[queryId]?(.failure(PuterAIError.requestFailed(errorMessage)))
                pendingQueries.removeValue(forKey: queryId)
            } else if let errorMessage = message.body as? String {
                // General error during initialization
                initializationSubject.send(false)
                print("Puter AI error: \(errorMessage)")
            }
            
        default:
            break
        }
    }
    
    // Analyze mood patterns and return AI-generated recommendations
    func analyzeMoodPatterns(moodData: [MoodData], completion: @escaping (Result<String, Error>) -> Void) {
        // Create a unique ID for this query
        queryCounter += 1
        let queryId = "query_\(queryCounter)"
        pendingQueries[queryId] = completion
        
        // Prepare the data in a format suitable for AI analysis
        var moodDataForAI: [[String: Any]] = []
        for entry in moodData {
            var entryDict: [String: Any] = [
                "date": ISO8601DateFormatter().string(from: entry.date),
                "mood": entry.mood,
                "intensity": entry.intensity
            ]
            if let note = entry.note {
                entryDict["note"] = note
            }
            if entry.rejectionRelated {
                entryDict["rejectionRelated"] = true
                if let trigger = entry.rejectionTrigger {
                    entryDict["rejectionTrigger"] = trigger
                }
            }
            if let strategy = entry.copingStrategy {
                entryDict["copingStrategy"] = strategy
            }
            moodDataForAI.append(entryDict)
        }
        
        // Create the prompt for the AI
        let prompt = """
        As an AI wellness assistant for the ResilientMe app, analyze the following mood tracking data to identify patterns and provide personalized recommendations:
        
        \(String(describing: moodDataForAI))
        
        Focus on:
        1. Identifying emotional patterns after rejection experiences
        2. Recognizing recurring triggers for negative moods
        3. Determining which coping strategies have been most effective
        4. Suggesting new personalized coping strategies based on the user's data
        
        Format your response as a JSON object with the following structure:
        {
            "recommendations": [
                {
                    "title": "Recommendation title",
                    "description": "Detailed explanation",
                    "triggerPattern": "Pattern identified",
                    "confidenceLevel": 0.75,
                    "strategies": [
                        {
                            "title": "Strategy title",
                            "description": "How this helps",
                            "timeToComplete": "5 minutes",
                            "steps": ["Step 1", "Step 2", "Step 3"],
                            "category": "mindfulness"
                        }
                    ],
                    "resources": [
                        {
                            "title": "Resource title",
                            "type": "article",
                            "description": "What this resource offers"
                        }
                    ]
                }
            ]
        }
        """
        
        // Set AI model options
        let options = ["model": "claude-3-5-sonnet"] // Using Claude for this task
        
        // Execute the JavaScript
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let webView = self.webView else {
                completion(.failure(PuterAIError.notInitialized))
                return
            }
            
            // Convert the options to JSON
            let optionsJson = try? JSONSerialization.data(withJSONObject: options, options: [])
            let optionsString = String(data: optionsJson ?? Data(), encoding: .utf8) ?? "{}"
            
            // Call the JavaScript function
            let jsCall = "sendAIQuery('\(queryId)', \(prompt.jsonEscaped), '\(optionsString)')"
            webView.evaluateJavaScript(jsCall) { _, error in
                if let error = error {
                    completion(.failure(error))
                    self.pendingQueries.removeValue(forKey: queryId)
                }
            }
        }
    }
    
    // Function to generate coping strategies for a specific mood/trigger
    func generateCopingStrategies(mood: String, trigger: String?, completion: @escaping (Result<[String], Error>) -> Void) {
        // Create a unique ID for this query
        queryCounter += 1
        let queryId = "query_\(queryCounter)"
        
        // Store completion handler
        pendingQueries[queryId] = { result in
            switch result {
            case .success(let jsonString):
                do {
                    if let data = jsonString.data(using: .utf8),
                       let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let strategies = json["strategies"] as? [String] {
                        completion(.success(strategies))
                    } else {
                        // If not valid JSON with strategies array, parse line by line
                        let lines = jsonString.split(separator: "\n").map { String($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
                        let strategies = lines.filter { !$0.isEmpty }
                        completion(.success(strategies))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        // Create the prompt
        let triggerInfo = trigger != nil ? "The rejection trigger was: \(trigger!)" : "No specific rejection trigger was identified."
        
        let prompt = """
        Generate 5 effective coping strategies for someone experiencing the mood: "\(mood)".
        \(triggerInfo)
        
        Return only the list of strategies, one per line. Each strategy should be specific, actionable, and achievable within 15 minutes.
        Format as JSON with a single "strategies" array containing the strategies as strings.
        """
        
        // Set AI model options (using a lighter model for this simpler task)
        let options = ["model": "gpt-4o-mini"]
        
        // Execute the JavaScript
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let webView = self.webView else {
                completion(.failure(PuterAIError.notInitialized))
                return
            }
            
            // Convert the options to JSON
            let optionsJson = try? JSONSerialization.data(withJSONObject: options, options: [])
            let optionsString = String(data: optionsJson ?? Data(), encoding: .utf8) ?? "{}"
            
            // Call the JavaScript function
            let jsCall = "sendAIQuery('\(queryId)', \(prompt.jsonEscaped), '\(optionsString)')"
            webView.evaluateJavaScript(jsCall) { _, error in
                if let error = error {
                    completion(.failure(error))
                    self.pendingQueries.removeValue(forKey: queryId)
                }
            }
        }
    }
    
    // Function to generate a journal prompt based on mood
    func generateJournalPrompt(mood: String, trigger: String?, completion: @escaping (Result<String, Error>) -> Void) {
        // Create a unique ID for this query
        queryCounter += 1
        let queryId = "query_\(queryCounter)"
        pendingQueries[queryId] = completion
        
        // Create the prompt
        let triggerInfo = trigger != nil ? "The rejection trigger was: \(trigger!)" : "No specific rejection trigger was identified."
        
        let prompt = """
        Generate a reflective journal prompt for someone experiencing the mood: "\(mood)".
        \(triggerInfo)
        
        The prompt should encourage self-reflection, emotional awareness, and building resilience.
        Keep it concise (2-3 sentences maximum) and compassionate.
        Focus specifically on helping process rejection experiences and building resilience.
        """
        
        // Set AI model options
        let options = ["model": "gpt-4o-mini"]
        
        // Execute the JavaScript
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let webView = self.webView else {
                completion(.failure(PuterAIError.notInitialized))
                return
            }
            
            // Convert the options to JSON
            let optionsJson = try? JSONSerialization.data(withJSONObject: options, options: [])
            let optionsString = String(data: optionsJson ?? Data(), encoding: .utf8) ?? "{}"
            
            // Call the JavaScript function
            let jsCall = "sendAIQuery('\(queryId)', \(prompt.jsonEscaped), '\(optionsString)')"
            webView.evaluateJavaScript(jsCall) { _, error in
                if let error = error {
                    completion(.failure(error))
                    self.pendingQueries.removeValue(forKey: queryId)
                }
            }
        }
    }
}

// MARK: - AI Response Models
// 
// struct AIRecommendationsResponse: Codable {
//     let recommendations: [AIRecommendation]
// }
// 
// struct AIRecommendation: Codable {
//     let title: String
//     let description: String
//     let trigger_pattern: String
//     let confidence_level: Double
//     let strategies: [AIStrategy]
//     let resources: [AIResource]
// }
// 
// struct AIStrategy: Codable {
//     let title: String
//     let description: String
//     let category: String
//     let time_to_complete: String
//     let steps: [String]
// }
// 
// struct AIResource: Codable {
//     let title: String
//     let type: String
//     let description: String
//     let url: String?

// Extension to help with JSON escaping
extension String {
    var jsonEscaped: String {
        let data = self.data(using: .utf8)!
        let escaped = String(data: data, encoding: .utf8)!
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
        return "\"\(escaped)\""
    }
} 
// Use models from MoodAnalysisEngine.swift instead
import Foundation
