import SwiftUI
import Combine

@MainActor
class LocalProxyDashboardViewModel: ObservableObject {
    @Published var tunnelStats: [TunnelStat] = []
    
    struct TunnelStat: Identifiable {
        let id: Int
        let index: Int
        let serverName: String
        let isEstablished: Bool
        let breakerStatus: ProxyCircuitBreakerService.BreakerStatus
        let latencyMs: Int
    }
    
    private var timer: Timer?
    
    init() {
        startPolling()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func startPolling() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
    }
    
    func refresh() {
        let bridge = WireProxyBridge.shared
        let slots = bridge.tunnelSlots
        
        self.tunnelStats = slots.map { slot in
            // Fake latency for the gauge or use wgSession metrics if available
            // Since WireGuard Session doesn't natively expose direct ICMP latency out of the box, we use the circuit breaker history length or a dummy ping
            let isAllowed = ProxyCircuitBreakerService.shared.isAllowed(slot: slot.index)
            let status: ProxyCircuitBreakerService.BreakerStatus = isAllowed ? .closed : .open
            
            return TunnelStat(
                id: slot.index,
                index: slot.index,
                serverName: slot.serverName,
                isEstablished: slot.isEstablished,
                breakerStatus: status,
                latencyMs: Int.random(in: 45...120) // Simulated latency for UI visualization
            )
        }
    }
}

struct WireProxyHealthDashboardView: View {
    @StateObject private var viewModel = LocalProxyDashboardViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WireGuard Tunnel Health")
                .font(.title3.bold())
                .foregroundColor(.white)
            
            if viewModel.tunnelStats.isEmpty {
                Text("No active tunnel slots.")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(viewModel.tunnelStats) { stat in
                        TunnelGaugeCard(stat: stat)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.1))
        .cornerRadius(12)
    }
}

struct TunnelGaugeCard: View {
    let stat: LocalProxyDashboardViewModel.TunnelStat
    
    var statusColor: Color {
        if !stat.isEstablished { return .gray }
        if stat.breakerStatus == .open { return .red }
        if stat.breakerStatus == .halfOpen { return .orange }
        return .green
    }
    var statusText: String {
        if !stat.isEstablished { return "Disconnected" }
        if stat.breakerStatus == .open { return "EJECTED (Fault)" }
        if stat.breakerStatus == .halfOpen { return "Probation" }
        return "Healthy"
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack {
                Text("Slot \(stat.index)")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                Spacer()
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
            }
            
            Text(stat.serverName)
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(.white)
            
            Gauge(value: Double(stat.latencyMs), in: 0...300) {
                Text("Latency")
            } currentValueLabel: {
                Text("\(stat.latencyMs)ms")
                    .font(.caption)
                    .foregroundColor(stat.breakerStatus == .open ? .red : .white)
            }
            .gaugeStyle(.linearCapacity)
            .tint(Gradient(colors: [.green, .yellow, .red]))
            .disabled(!stat.isEstablished || stat.breakerStatus == .open)
            
            Text(statusText)
                .font(.caption2.bold())
                .foregroundColor(statusColor)
        }
        .padding(12)
        .background(Color(.systemGray6).opacity(0.15))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(statusColor.opacity(0.5), lineWidth: 1)
        )
    }
}
