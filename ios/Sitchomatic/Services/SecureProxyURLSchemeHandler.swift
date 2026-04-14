import Foundation
import WebKit

@MainActor
class SecureProxyURLSchemeHandler: NSObject, WKURLSchemeHandler {
    private let target: ProxyRotationService.ProxyTarget
    private let networkConfig: ActiveNetworkConfig
    private let credentialId: String?
    
    // Maintain a map of active tasks to URLSessionDataTasks
    private var activeTasks: [Int: URLSessionDataTask] = [:]
    private var activeSchemeTasks: [Int: WKURLSchemeTask] = [:]
    
    private lazy var urlSession: URLSession = {
        let config = NetworkSessionFactory.shared.buildURLSessionProxyConfiguration(
            for: networkConfig,
            target: target,
            credentialId: credentialId
        )
        // Enable pipelining for multiplexing within the SOCKS tunnel
        config.httpShouldUsePipelining = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    init(target: ProxyRotationService.ProxyTarget, networkConfig: ActiveNetworkConfig, credentialId: String? = nil) {
        self.target = target
        self.networkConfig = networkConfig
        self.credentialId = credentialId
        super.init()
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let originalURL = urlSchemeTask.request.url else { return }
        
        // Custom scheme fallback: translate `sitch-https` to `https` 
        // Or if the system allowed overriding `https`, the scheme will already be correct.
        var components = URLComponents(url: originalURL, resolvingAgainstBaseURL: false)
        if components?.scheme == "sitch-https" {
            components?.scheme = "https"
        } else if components?.scheme == "sitch-http" {
            components?.scheme = "http"
        }
        
        guard let finalURL = components?.url, let host = finalURL.host else { return }
        
        let blocklist = ["doubleclick.net", "facebook.com", "google-analytics.com", "hotjar.com"]
        let lowerHost = host.lowercased()
        
        if blocklist.contains(where: { lowerHost.contains($0) }) {
            let error = NSError(domain: "ZeroTrustPolicy", code: 403, userInfo: [NSLocalizedDescriptionKey: "Origin blocked by Zero-Trust policy"])
            urlSchemeTask.didFailWithError(error)
            return
        }
        
        var request = urlSchemeTask.request
        request.url = finalURL
        
        let dataTask = urlSession.dataTask(with: request)
        activeTasks[urlSchemeTask.hash] = dataTask
        activeSchemeTasks[dataTask.taskIdentifier] = urlSchemeTask
        
        dataTask.resume()
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        if let dataTask = activeTasks.removeValue(forKey: urlSchemeTask.hash) {
            dataTask.cancel()
            activeSchemeTasks.removeValue(forKey: dataTask.taskIdentifier)
        }
    }
}

extension SecureProxyURLSchemeHandler: URLSessionDataDelegate {
    
    private func getSchemeTask(for task: URLSessionTask) -> WKURLSchemeTask? {
        return activeSchemeTasks[task.taskIdentifier]
    }
    
    nonisolated func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        Task { @MainActor in
            guard let schemeTask = self.getSchemeTask(for: dataTask) else {
                completionHandler(.cancel)
                return
            }
            schemeTask.didReceive(response)
            completionHandler(.allow)
        }
    }
    
    nonisolated func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        Task { @MainActor in
            guard let schemeTask = self.getSchemeTask(for: dataTask) else { return }
            schemeTask.didReceive(data)
        }
    }
    
    nonisolated func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Task { @MainActor in
            guard let schemeTask = self.getSchemeTask(for: task) else { return }
            self.activeTasks.removeValue(forKey: schemeTask.hash)
            
            if let error = error {
                guard (error as NSError).code != NSURLErrorCancelled else { return }
                schemeTask.didFailWithError(error)
            } else {
                schemeTask.didFinish()
            }
        }
    }
    
    nonisolated func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        Task { @MainActor in
            guard let schemeTask = self.getSchemeTask(for: task) else {
                completionHandler(request)
                return
            }
            // WKURLSchemeTask doesn't have a direct redirection handler, 
            // but we must send the response to trigger WebKit's internal redirection follow.
            schemeTask.didReceive(response)
            completionHandler(request)
        }
    }
}
