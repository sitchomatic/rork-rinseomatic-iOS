import SwiftUI

struct SettingsHubRootView: View {
    @State private var proxyService = ProxyRotationService.shared

    nonisolated enum Route: Hashable, Sendable {
        case automation
        case urlManagement
        case loginNetwork
        case deviceNetwork
        case proxyManager
        case nordConfig
        case networkRepair
        case ppsrSettings
        case importExport
        case vault
        case notices
        case debugLog
        case developerSettings
        case advancedSettings
    }

    var body: some View {
        NavigationStack {
            List {
                automationSection
                networkSection
                dataSection
                diagnosticsSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .automation:
                    AutomationSettingsRootView()
                case .urlManagement:
                    URLManagementView()
                case .loginNetwork:
                    LoginNetworkSettingsView(vm: LoginViewModel.shared)
                case .deviceNetwork:
                    DeviceNetworkSettingsView()
                case .proxyManager:
                    ProxyManagerView()
                case .nordConfig:
                    NordLynxConfigView()
                case .networkRepair:
                    NetworkRepairView()
                case .ppsrSettings:
                    PPSRSettingsView(vm: PPSRAutomationViewModel.shared)
                case .importExport:
                    ConsolidatedImportExportView()
                case .vault:
                    StorageFileBrowserView()
                case .notices:
                    NoticesView()
                case .debugLog:
                    DebugLogView()
                case .developerSettings:
                    DeveloperSettingsView()
                case .advancedSettings:
                    AdvancedSettingsView()
                }
            }
        }
        .withMainMenuButton()
        .preferredColorScheme(.dark)
    }

    private var automationSection: some View {
        Section {
            NavigationLink(value: Route.automation) {
                settingsRow(icon: "gearshape.2.fill", title: "Automation", subtitle: "Timing, detection, stealth, recovery, and concurrency", color: .red)
            }
            NavigationLink(value: Route.urlManagement) {
                settingsRow(icon: "link.circle.fill", title: "URL Management", subtitle: "Joe and Ignition endpoints and rotation lists", color: .green)
            }
            NavigationLink(value: Route.loginNetwork) {
                settingsRow(icon: "arrow.triangle.branch", title: "Login Network", subtitle: "Per-mode login network overrides and routing", color: .cyan)
            }
            NavigationLink(value: Route.ppsrSettings) {
                settingsRow(icon: "creditcard.fill", title: "Card Testing Settings", subtitle: "PPSR, BPOINT, and WA REGO controls", color: .teal)
            }
        } header: {
            Label("Automation & URLs", systemImage: "gearshape.2.fill")
        }
    }

    private var networkSection: some View {
        Section {
            NavigationLink(value: Route.deviceNetwork) {
                settingsRow(icon: "network.badge.shield.half.filled", title: "Device Network", subtitle: "Current mode: \(proxyService.unifiedConnectionMode.label)", color: .blue)
            }
            NavigationLink(value: Route.proxyManager) {
                settingsRow(icon: "arrow.triangle.branch", title: "Proxy Manager", subtitle: "Inspect and manage proxy pools", color: .indigo)
            }
            NavigationLink(value: Route.nordConfig) {
                settingsRow(icon: "shield.checkered", title: "Nord Config", subtitle: "WireGuard and OpenVPN generation", color: Color(red: 0.0, green: 0.78, blue: 1.0))
            }
            NavigationLink(value: Route.networkRepair) {
                settingsRow(icon: "wrench.and.screwdriver.fill", title: "Repair Network", subtitle: "Restart network layers and routing", color: .orange)
            }
        } header: {
            Label("Network & VPN", systemImage: "network")
        }
    }

    private var dataSection: some View {
        Section {
            NavigationLink(value: Route.importExport) {
                settingsRow(icon: "square.and.arrow.up.on.square.fill", title: "Import / Export", subtitle: "Backups, restore, and cross-app data movement", color: .mint)
            }
            NavigationLink(value: Route.vault) {
                settingsRow(icon: "externaldrive.fill", title: "Vault", subtitle: "Browse saved files, bundles, and generated assets", color: .purple)
            }
        } header: {
            Label("Data & Vault", systemImage: "externaldrive")
        }
    }

    private var diagnosticsSection: some View {
        Section {
            NavigationLink(value: Route.notices) {
                settingsRow(icon: "bell.badge.fill", title: "Notices", subtitle: "Review surfaced issues and automated notices", color: .yellow)
            }
            NavigationLink(value: Route.debugLog) {
                settingsRow(icon: "doc.text.magnifyingglass", title: "Debug Log", subtitle: "App-wide log stream and diagnostics", color: .orange)
            }
            NavigationLink(value: Route.developerSettings) {
                settingsRow(icon: "hammer.fill", title: "Developer Settings", subtitle: "Deep control over the full automation stack", color: .red)
            }
            NavigationLink(value: Route.advancedSettings) {
                settingsRow(icon: "gearshape.fill", title: "Advanced Settings", subtitle: "System tools, about, and low-level utilities", color: .gray)
            }
        } header: {
            Label("Diagnostics & Advanced", systemImage: "ellipsis.circle.fill")
        }
    }

    private func settingsRow(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
