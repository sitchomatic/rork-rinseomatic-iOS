import SwiftUI

struct CCTVDashboardView: View {
    @StateObject private var screenshotManager = UnifiedScreenshotManager.shared
    
    // Group active sessions by drawing the absolute most recent screenshot per sessionId
    private var activeSessions: [UnifiedScreenshot] {
        let allScreenshots = screenshotManager.screenshots
        var latestPerSession: [String: UnifiedScreenshot] = [:]
        
        let recentCutoff = Date().addingTimeInterval(-180) // 3 minutes activity window
        
        for shot in allScreenshots where shot.timestamp > recentCutoff {
            let sessionId = shot.credentialEmail // Using email as session identifier for CCTV
            if let existing = latestPerSession[sessionId] {
                if shot.timestamp > existing.timestamp {
                    latestPerSession[sessionId] = shot
                }
            } else {
                latestPerSession[sessionId] = shot
            }
        }
        
        return Array(latestPerSession.values).sorted { $0.timestamp > $1.timestamp }
    }
    
    private var columns: [GridItem] {
        let count = max(1, activeSessions.count)
        if count <= 2 {
            return [GridItem(.flexible())]
        } else if count <= 4 {
            return [GridItem(.flexible()), GridItem(.flexible())]
        } else {
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("LIVE CCTV")
                    .font(.title3.bold())
                    .foregroundColor(.red)
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .opacity(activeSessions.isEmpty ? 0.3 : 1.0)
                    .symbolEffect(.pulse, isActive: !activeSessions.isEmpty)
                
                Spacer()
                Text("\(activeSessions.count) Active Automation(s)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            if activeSessions.isEmpty {
                ContentUnavailableView("No Active Sessions", systemImage: "video.slash", description: Text("Start an automation engine to view live layout feeds."))
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(activeSessions, id: \.id) { shot in
                            CCTVCameraCard(screenshot: shot)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
        .background(Color(.systemGroupedBackground))
    }
}

struct CCTVCameraCard: View {
    let screenshot: UnifiedScreenshot
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(uiImage: screenshot.displayImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minHeight: 180, maxHeight: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Camera Overlay
            VStack(alignment: .leading) {
                HStack {
                    Text("REC")
                        .font(.caption2.bold())
                        .foregroundColor(.red)
                        .padding(4)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Text(screenshot.site.uppercased())
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(screenshot.credentialEmail)
                        .font(.caption2)
                        .lineLimit(1)
                        .foregroundColor(.white)
                    
                    Text("\(screenshot.timestamp, formatter: Self.timeFormatter)")
                        .font(.caption2.monospaced())
                        .foregroundColor(.green)
                }
                .padding(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.7))
            }
            .padding(8)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .medium
        return df
    }()
}
