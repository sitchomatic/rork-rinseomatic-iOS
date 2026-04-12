import SwiftUI

struct ToolsAndTestingView: View {
    private let proxyService = ProxyRotationService.shared

    var body: some View {
        NavigationStack {
            List {
                automationFlowSection
                testingToolsSection
                diagnosticsSection
                networkToolsSection
                settingsSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Tools & Testing")
        }
        .withMainMenuButton()
        .preferredColorScheme(.dark)
    }

    private var automationFlowSection: some View {
        Section {
            NavigationLink {
                FlowRecorderView()
            } label: {
                toolRow(icon: "record.circle", title: "Flow Recorder",
                        subtitle: "Record and replay browser automation flows", color: .red)
            }
            NavigationLink {
                SavedFlowsView(vm: FlowRecorderViewModel())
            } label: {
                toolRow(icon: "tray.full.fill", title: "Saved Flows",
                        subtitle: "Manage and export recorded flows", color: .pink)
            }
        } header: {
            Label("Automation Flow", systemImage: "record.circle")
        }
    }

    private var testingToolsSection: some View {
        Section {
            NavigationLink {
                SuperTestView()
            } label: {
                toolRow(icon: "bolt.horizontal.circle.fill", title: "Super Test",
                        subtitle: "Full infrastructure validation", color: .purple)
            }
            NavigationLink {
                IPScoreTestView()
            } label: {
                toolRow(icon: "network.badge.shield.half.filled", title: "IP Score Test",
                        subtitle: "8× concurrent IP quality analysis", color: .indigo)
            }
            NavigationLink {
                FingerprintTestView()
            } label: {
                toolRow(icon: "touchid", title: "Fingerprint Test",
                        subtitle: "Browser fingerprint detection analysis", color: .teal)
            }
            NavigationLink {
                TestDebugContainerView()
            } label: {
                toolRow(icon: "flask.fill", title: "Test & Debug",
                        subtitle: "Known account optimizer — multi-session testing", color: .mint)
            }
            NavigationLink {
                LoginDebugScreenshotsView(vm: LoginViewModel.shared)
            } label: {
                toolRow(icon: "camera.viewfinder", title: "Debug Screenshots",
                        subtitle: "App-wide debug screenshot gallery", color: .orange)
            }
        } header: {
            Label("Testing Tools", systemImage: "flask.fill")
        }
    }

    private var diagnosticsSection: some View {
        Section {
            NavigationLink {
                DebugLogView()
            } label: {
                toolRow(icon: "doc.text.magnifyingglass", title: "Debug Log",
                        subtitle: "Full debug log viewer", color: .purple)
            }
            NavigationLink {
                GrokAIStatusView()
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill((GrokAISetup.isConfigured ? Color.green : Color.orange).opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: "brain.head.profile.fill")
                            .font(.body)
                            .foregroundStyle(GrokAISetup.isConfigured ? .green : .orange)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Grok AI Status").font(.subheadline.bold())
                        Text(GrokAISetup.isConfigured ? "Connected — vision + reasoning active" : "Not configured — heuristic mode")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: GrokAISetup.isConfigured ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundStyle(GrokAISetup.isConfigured ? .green : .orange)
                        .font(.caption)
                }
            }
        } header: {
            Label("Diagnostics & AI", systemImage: "waveform.path.ecg")
        }
    }

    private var networkToolsSection: some View {
        Section {
            NavigationLink {
                NordLynxConfigView()
            } label: {
                toolRow(icon: "shield.checkered", title: "Nord Config",
                        subtitle: "WireGuard & OpenVPN generation", color: Color(red: 0.0, green: 0.78, blue: 1.0))
            }
            NavigationLink {
                NetworkRepairView()
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.body)
                            .foregroundStyle(.orange)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Repair Network").font(.subheadline.bold())
                        Text("Full restart of all network protocols")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if NetworkRepairService.shared.isRepairing {
                        ProgressView().controlSize(.mini)
                    } else if let result = NetworkRepairService.shared.lastRepairResult {
                        Image(systemName: result.overallSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(result.overallSuccess ? .green : .red)
                            .font(.caption)
                    }
                }
            }
        } header: {
            Label("Network Tools", systemImage: "network")
        } footer: {
            Text("Network configs are device-wide. Changes apply to Joe, Ignition & PPSR.")
        }
    }

    private var settingsSection: some View {
        Section {
            NavigationLink {
                AdvancedSettingsView()
            } label: {
                toolRow(icon: "gearshape.2.fill", title: "Advanced Settings",
                        subtitle: "Debug, diagnostics, data, app settings & about", color: .gray)
            }
        } header: {
            Label("Settings", systemImage: "gearshape.fill")
        }
    }

    private func toolRow(icon: String, title: String, subtitle: String, color: Color) -> some View {
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
                Text(title).font(.subheadline.bold())
                Text(subtitle).font(.caption2).foregroundStyle(.secondary)
            }
        }
    }
}
