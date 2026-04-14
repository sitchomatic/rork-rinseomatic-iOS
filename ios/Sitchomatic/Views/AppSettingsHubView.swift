import SwiftUI

// MARK: - Main Hub

struct AppSettingsHubView: View {
    @State private var urlService = LoginURLRotationService.shared
    @State private var proxyService = ProxyRotationService.shared

    var body: some View {
        NavigationStack {
            List {
                quickStatusSection
                automationSection
                urlsSection
                networkSection
                ppsrSection
                developerSection
                testingSection
                advancedSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings Hub")
        }
        .withMainMenuButton()
        .preferredColorScheme(.dark)
    }

    // MARK: - Quick Status Banner

    private var quickStatusSection: some View {
        Section {
            HStack(spacing: 16) {
                statusBadge(
                    label: "Network",
                    value: proxyService.unifiedConnectionMode.label,
                    color: .blue
                )
                Divider().frame(height: 28)
                let joeEnabled = urlService.joeURLs.filter(\.isEnabled).count
                let ignEnabled = urlService.ignitionURLs.filter(\.isEnabled).count
                statusBadge(
                    label: "Joe URLs",
                    value: "\(joeEnabled)/\(urlService.joeURLs.count)",
                    color: joeEnabled > 0 ? .green : .red
                )
                Divider().frame(height: 28)
                statusBadge(
                    label: "Ign URLs",
                    value: "\(ignEnabled)/\(urlService.ignitionURLs.count)",
                    color: ignEnabled > 0 ? .green : .red
                )
                Divider().frame(height: 28)
                statusBadge(
                    label: "AI",
                    value: GrokAISetup.isConfigured ? "ON" : "OFF",
                    color: GrokAISetup.isConfigured ? .green : .orange
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Automation

    private var automationSection: some View {
        Section {
            NavigationLink {
                AutomationSettingsRootView()
            } label: {
                hubRow(icon: "gearshape.2.fill", title: "Automation Settings",
                       subtitle: "Timing · True Detection · Submit · Patterns · Stealth · Delays", color: .red)
            }
            NavigationLink {
                TrueDetectionSettingsView()
            } label: {
                hubRow(icon: "scope", title: "True Detection",
                       subtitle: "Selectors · Cycles · Click delays · Recovery timeout · Cooldown", color: .orange)
            }
            NavigationLink {
                AllDelaysSettingsView()
            } label: {
                hubRow(icon: "timer", title: "All Timing & Delays",
                       subtitle: "Every ms value — pre/post typing, navigation, submit, recovery", color: .yellow)
            }
        } header: {
            Label("Automation", systemImage: "gearshape.2.fill")
        } footer: {
            Text("All settings are fully wired. Values load fresh at each run start.")
        }
    }

    // MARK: - URLs

    private var urlsSection: some View {
        Section {
            NavigationLink {
                URLManagementView()
            } label: {
                HStack(spacing: 12) {
                    iconCircle("arrow.triangle.2.circlepath", color: .green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("URL Management").font(.subheadline.bold())
                        let joeCount = urlService.joeURLs.filter(\.isEnabled).count
                        let ignCount = urlService.ignitionURLs.filter(\.isEnabled).count
                        Text("Joe: \(joeCount)/\(urlService.joeURLs.count) · Ignition: \(ignCount)/\(urlService.ignitionURLs.count) enabled")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Label("URLs & Endpoints", systemImage: "link.circle.fill")
        } footer: {
            Text("Manages Joe & Ignition login URLs. Active across all run modes.")
        }
    }

    // MARK: - Network

    private var networkSection: some View {
        Section {
            NavigationLink {
                DeviceNetworkSettingsView()
            } label: {
                HStack(spacing: 12) {
                    iconCircle("network.badge.shield.half.filled", color: .blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Device Network Settings").font(.subheadline.bold())
                        Text("Proxy, VPN, WireGuard, DNS — all modes")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(proxyService.unifiedConnectionMode.label)
                        .font(.system(.caption2, design: .monospaced, weight: .bold))
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(Color.blue.opacity(0.12)).clipShape(Capsule())
                }
            }
            NavigationLink {
                NordLynxConfigView()
            } label: {
                hubRow(icon: "shield.checkered", title: "Nord Config",
                       subtitle: "WireGuard & OpenVPN generation", color: Color(red: 0.0, green: 0.78, blue: 1.0))
            }
            NavigationLink {
                NetworkRepairView()
            } label: {
                HStack(spacing: 12) {
                    iconCircle("wrench.and.screwdriver.fill", color: .orange)
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
            Label("Network & VPN", systemImage: "lock.shield.fill")
        } footer: {
            Text("Network configs are device-wide and apply to Joe, Ignition & PPSR.")
        }
    }

    // MARK: - PPSR

    private var ppsrSection: some View {
        Section {
            NavigationLink {
                PPSRSettingsView(vm: PPSRAutomationViewModel.shared)
            } label: {
                hubRow(icon: "doc.text.magnifyingglass", title: "PPSR Settings",
                       subtitle: "Connection mode, batch, scheduling, email, stealth", color: .teal)
            }
        } header: {
            Label("PPSR", systemImage: "doc.text.magnifyingglass")
        }
    }

    // MARK: - Developer

    private var developerSection: some View {
        Section {
            NavigationLink {
                DeveloperSettingsView()
            } label: {
                hubRow(icon: "hammer.fill", title: "Developer Settings",
                       subtitle: "All 200+ granular automation parameters", color: .red)
            }
            NavigationLink {
                LoginNetworkSettingsView(vm: LoginViewModel.shared)
            } label: {
                hubRow(icon: "arrow.triangle.branch", title: "Login Network Settings",
                       subtitle: "URL rotation, validation, per-mode overrides", color: .cyan)
            }
        } header: {
            Label("Developer", systemImage: "hammer.fill")
        } footer: {
            Text("Advanced controls. Changes take effect at next run start.")
        }
    }

    // MARK: - Testing

    private var testingSection: some View {
        Section {
            NavigationLink {
                SuperTestView()
            } label: {
                hubRow(icon: "bolt.horizontal.circle.fill", title: "Super Test",
                       subtitle: "Full infrastructure validation", color: .purple)
            }
            NavigationLink {
                IPScoreTestView()
            } label: {
                hubRow(icon: "network.badge.shield.half.filled", title: "IP Score Test",
                       subtitle: "8× concurrent IP quality analysis", color: .indigo)
            }
            NavigationLink {
                GrokAIStatusView()
            } label: {
                HStack(spacing: 12) {
                    iconCircle("brain.head.profile.fill", color: GrokAISetup.isConfigured ? .green : .orange)
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
            Label("Testing Tools", systemImage: "flask.fill")
        }
    }

    // MARK: - Advanced

    private var advancedSection: some View {
        Section {
            NavigationLink {
                AdvancedSettingsView()
            } label: {
                hubRow(icon: "gearshape.fill", title: "Advanced Settings",
                       subtitle: "Debug logs, diagnostics, data management & about", color: .gray)
            }
            NavigationLink {
                SettingsAndTestingView()
            } label: {
                hubRow(icon: "wrench.adjustable.fill", title: "Settings & Testing",
                       subtitle: "Legacy test tools and network diagnostics", color: .gray)
            }
        } header: {
            Label("Advanced", systemImage: "ellipsis.circle.fill")
        }
    }

    // MARK: - Helpers

    private func statusBadge(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.caption, design: .monospaced, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func iconCircle(_ systemName: String, color: Color) -> some View {
        ZStack {
            Circle().fill(color.opacity(0.12)).frame(width: 40, height: 40)
            Image(systemName: systemName).font(.body).foregroundStyle(color)
        }
    }

    private func hubRow(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 12) {
            iconCircle(icon, color: color)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(subtitle).font(.caption2).foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Automation Settings Root (top-level hub for automation sub-pages)

struct AutomationSettingsRootView: View {
    @State private var settings: AutomationSettings = AutomationSettingsPersistence.shared.load()
    @State private var saveToast: Bool = false

    var body: some View {
        List {
            quickActionsSection
            trueDetectionNavSection
            delaysNavSection
            patternsNavSection
            stealthNavSection
            sessionNavSection
            advancedNavSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Automation Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let normalized = settings.normalizedTimeouts()
                    AutomationSettingsPersistence.shared.save(normalized)
                    withAnimation { saveToast = true }
                    Task { @MainActor in try? await Task.sleep(for: .seconds(1.5)); saveToast = false }
                }
                .bold()
            }
        }
        .overlay(alignment: .bottom) {
            if saveToast {
                toastBanner("Settings saved")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .automationSettingsDidChange)) { notification in
            if let newSettings = notification.object as? AutomationSettings {
                self.settings = newSettings
            }
        }
    }

    private var quickActionsSection: some View {
        Section {
            Button(role: .destructive) {
                let reset = AutomationSettings().normalizedTimeouts()
                settings = reset
                AutomationSettingsPersistence.shared.save(reset)
                withAnimation { saveToast = true }
                Task { @MainActor in try? await Task.sleep(for: .seconds(1.5)); saveToast = false }
            } label: {
                Label("Reset All to Defaults", systemImage: "arrow.counterclockwise")
                    .foregroundStyle(.red)
            }
        } header: {
            Text("Quick Actions")
        } footer: {
            Text("Resets every automation parameter to its built-in default value.")
        }
    }

    private var trueDetectionNavSection: some View {
        Section {
            NavigationLink { TrueDetectionSettingsView() } label: {
                navRow(icon: "scope", title: "True Detection",
                       subtitle: "Cycles · clicks · selectors · cooldown · timeouts", color: .orange)
            }
        } header: { Text("Primary Protocol") }
    }

    private var delaysNavSection: some View {
        Section {
            NavigationLink { AllDelaysSettingsView() } label: {
                navRow(icon: "timer", title: "All Timing & Delays",
                       subtitle: "Every ms value in the engine — fully wired", color: .yellow)
            }
        } header: { Text("Timing") }
    }

    private var patternsNavSection: some View {
        Section {
            NavigationLink {
                DevDetectionSection(settings: $settings)
            } label: {
                navRow(icon: "list.bullet.indent", title: "Detection & Patterns",
                       subtitle: "Pattern priority, submit method, fallback chain, selectors", color: .blue)
            }
            NavigationLink {
                DevSubmitClickSection(settings: $settings)
            } label: {
                navRow(icon: "hand.tap.fill", title: "Submit & Click",
                       subtitle: "Submit behavior, click method, settlement gate", color: .teal)
            }
        } header: { Text("Patterns & Submit") } footer: {
            Text("Changes saved via Save button above or per-section in Developer Settings.")
        }
    }

    private var stealthNavSection: some View {
        Section {
            NavigationLink {
                DevFingerprintingSection(settings: $settings)
            } label: {
                navRow(icon: "eye.slash.fill", title: "Stealth & Fingerprint",
                       subtitle: "JS injection, canvas noise, UA rotation, viewport", color: .indigo)
            }
        } header: { Text("Stealth") }
    }

    private var sessionNavSection: some View {
        Section {
            NavigationLink {
                DevSessionCookiesSection(settings: $settings)
            } label: {
                navRow(icon: "square.stack.3d.up.fill", title: "Session & Cookies",
                       subtitle: "Cookie clear, localStorage, isolation mode, WebView config", color: .teal)
            }
            NavigationLink {
                DevConcurrencySection(settings: $settings)
            } label: {
                navRow(icon: "cpu.fill", title: "Concurrency",
                       subtitle: "Max sessions, strategy, batch delay", color: .blue)
            }
        } header: { Text("Session & Concurrency") }
    }

    private var advancedNavSection: some View {
        Section {
            NavigationLink {
                DeveloperSettingsView()
            } label: {
                navRow(icon: "hammer.fill", title: "All Developer Settings",
                       subtitle: "Full 200+ parameter view across all categories", color: .red)
            }
        } header: { Text("Developer") } footer: {
            Text("Developer Settings is the master hub. All sub-pages above are shortcuts into it.")
        }
    }

    private func navRow(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.callout).foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(subtitle).font(.caption2).foregroundStyle(.secondary)
            }
        }
    }

    private func toastBanner(_ message: String) -> some View {
        Text(message)
            .font(.caption.bold())
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(Color.green.opacity(0.85))
            .clipShape(Capsule())
            .padding(.bottom, 24)
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - True Detection Settings View

struct TrueDetectionSettingsView: View {
    @State private var settings: AutomationSettings = AutomationSettingsPersistence.shared.load()
    @State private var saveToast: Bool = false

    var body: some View {
        List {
            coreSection
            timingSection
            selectorSection
            cooldownSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle("True Detection")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let normalized = settings.normalizedTimeouts()
                    AutomationSettingsPersistence.shared.save(normalized)
                    withAnimation { saveToast = true }
                    Task { @MainActor in try? await Task.sleep(for: .seconds(1.5)); saveToast = false }
                }
                .bold()
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Reset") {
                    let reset = AutomationSettings().normalizedTimeouts()
                    settings = reset
                    AutomationSettingsPersistence.shared.save(reset)
                    withAnimation { saveToast = true }
                    Task { @MainActor in try? await Task.sleep(for: .seconds(1.5)); saveToast = false }
                }
                .foregroundStyle(.orange)
            }
        }
        .overlay(alignment: .bottom) {
            if saveToast {
                Text("Saved").font(.caption.bold())
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(Color.green.opacity(0.85)).clipShape(Capsule())
                    .padding(.bottom, 24).transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .automationSettingsDidChange)) { notification in
            if let newSettings = notification.object as? AutomationSettings {
                self.settings = newSettings
            }
        }
    }

    private var coreSection: some View {
        Section {
            Toggle("True Detection Enabled", isOn: $settings.trueDetectionEnabled)
            Toggle("True Detection Priority", isOn: $settings.trueDetectionPriority)
            Toggle("Strict Waits", isOn: $settings.trueDetectionStrictWaits)
            Toggle("No Proxy Rotation During TD", isOn: $settings.trueDetectionNoProxyRotation)
        } header: {
            Text("Core")
        } footer: {
            Text("True Detection is the primary submit protocol. Priority means it runs first before pattern fallbacks.")
        }
    }

    private var timingSection: some View {
        Section {
            intRow("Hard Pause (ms)", value: $settings.trueDetectionHardPauseMs, range: 0...60000)
            intRow("Triple Click Delay (ms)", value: $settings.trueDetectionTripleClickDelayMs, range: 0...5000)
            intRow("Inter-Click Delay (ms) ⚑", value: $settings.tripleClickInterClickDelayMs, range: 0...2000)
            intRow("Submit Cycle Count", value: $settings.trueDetectionSubmitCycleCount, range: 1...20)
            intRow("Clicks Per Cycle", value: $settings.trueDetectionTripleClickCount, range: 1...20)
            intRow("Button Recovery Timeout (ms)", value: $settings.trueDetectionButtonRecoveryTimeoutMs, range: 0...120000)
            intRow("Max Attempts", value: $settings.trueDetectionMaxAttempts, range: 1...20)
            intRow("Post-Click Wait (ms)", value: $settings.trueDetectionPostClickWaitMs, range: 0...30000)
        } header: {
            Text("Timing")
        } footer: {
            Text("⚑ Inter-Click Delay controls TripleClickEngine inter-click gaps. All other delays use the main delay settings as source. Wired and active.")
        }
    }

    private var selectorSection: some View {
        Section {
            Text("Joe Fortune").font(.caption.bold()).foregroundStyle(.secondary)
            labeledStringField("Email Selector", value: $settings.joeEmailSelector)
            labeledStringField("Password Selector", value: $settings.joePasswordSelector)
            labeledStringField("Submit Selector", value: $settings.joeSubmitSelector)
            Divider()
            Text("Ignition (also base default for unknown sites)").font(.caption.bold()).foregroundStyle(.secondary)
            labeledStringField("Email Selector", value: $settings.ignEmailSelector)
            labeledStringField("Password Selector", value: $settings.ignPasswordSelector)
            labeledStringField("Submit Selector", value: $settings.ignSubmitSelector)
        } header: {
            Text("Per-Site Selectors")
        } footer: {
            Text("Ignition selectors are also the fallback for any unknown site. HumanInteractionEngine and TrueDetectionService.forSite() both use these values via AutomationSettings.emailSelector(for:).")
        }
    }

    private var cooldownSection: some View {
        Section {
            intRow("Cooldown (minutes)", value: $settings.trueDetectionCooldownMinutes, range: 0...1440)
        } header: {
            Text("Cooldown")
        } footer: {
            Text("Prevents re-triggering True Detection on the same session within this window.")
        }
    }

    private func intRow(_ label: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        HStack {
            Text(label).font(.subheadline)
            Spacer()
            TextField("", value: value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .onChange(of: value.wrappedValue) { _, new in
                    value.wrappedValue = max(range.lowerBound, min(range.upperBound, new))
                }
        }
    }

    private func labeledStringField(_ label: String, value: Binding<String>) -> some View {
        HStack {
            Text(label).font(.subheadline)
            Spacer()
            TextField("selector", text: value)
                .font(.system(.caption, design: .monospaced))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 180)
        }
    }
}


// MARK: - All Delays Settings View

struct AllDelaysSettingsView: View {
    @State private var settings: AutomationSettings = AutomationSettingsPersistence.shared.load()
    @State private var saveToast: Bool = false

    var body: some View {
        List {
            actionDelaysSection
            betweenAttemptSection
            settlementSection
            recoverySection
            navigationSection
            fieldSection
            submitSection
            screenSection
            randomSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle("All Delays")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let normalized = settings.normalizedTimeouts()
                    AutomationSettingsPersistence.shared.save(normalized)
                    withAnimation { saveToast = true }
                    Task { @MainActor in try? await Task.sleep(for: .seconds(1.5)); saveToast = false }
                }
                .bold()
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Reset Delays") {
                    let def = AutomationSettings()
                    settings.globalPreActionDelayMs = def.globalPreActionDelayMs
                    settings.globalPostActionDelayMs = def.globalPostActionDelayMs
                    settings.preNavigationDelayMs = def.preNavigationDelayMs
                    settings.postNavigationDelayMs = def.postNavigationDelayMs
                    settings.preTypingDelayMs = def.preTypingDelayMs
                    settings.postTypingDelayMs = def.postTypingDelayMs
                    settings.interFieldDelayMs = def.interFieldDelayMs
                    settings.fieldFocusDelayMs = def.fieldFocusDelayMs
                    settings.cookieDismissDelayMs = def.cookieDismissDelayMs
                    settings.preSubmitDelayMs = def.preSubmitDelayMs
                    settings.postSubmitDelayMs = def.postSubmitDelayMs
                    settings.submitRetryDelayMs = def.submitRetryDelayMs
                    settings.submitButtonWaitDelayMs = def.submitButtonWaitDelayMs
                    settings.loginButtonPreClickDelayMs = def.loginButtonPreClickDelayMs
                    settings.loginButtonPostClickDelayMs = def.loginButtonPostClickDelayMs
                    settings.v42HoverDwellMs = def.v42HoverDwellMs
                    settings.betweenAttemptsDelayMs = def.betweenAttemptsDelayMs
                    settings.betweenCredentialsDelayMs = def.betweenCredentialsDelayMs
                    settings.v42InterAttemptDelayMinSec = def.v42InterAttemptDelayMinSec
                    settings.v42InterAttemptDelayMaxSec = def.v42InterAttemptDelayMaxSec
                    settings.pageStabilizationDelayMs = def.pageStabilizationDelayMs
                    settings.ajaxSettleDelayMs = def.ajaxSettleDelayMs
                    settings.domMutationSettleMs = def.domMutationSettleMs
                    settings.animationSettleDelayMs = def.animationSettleDelayMs
                    settings.redirectFollowDelayMs = def.redirectFollowDelayMs
                    settings.captchaDetectionDelayMs = def.captchaDetectionDelayMs
                    settings.errorRecoveryDelayMs = def.errorRecoveryDelayMs
                    settings.sessionCooldownDelayMs = def.sessionCooldownDelayMs
                    settings.proxyRotationDelayMs = def.proxyRotationDelayMs
                    settings.vpnReconnectDelayMs = def.vpnReconnectDelayMs
                    settings.unifiedScreenshotPostClickDelayMs = def.unifiedScreenshotPostClickDelayMs
                    settings.blankPageRecheckIntervalMs = def.blankPageRecheckIntervalMs
                    settings.waitForJSRenderMs = def.waitForJSRenderMs
                    settings.batchDelayBetweenStartsMs = def.batchDelayBetweenStartsMs
                    settings.pageLoadExtraDelayMs = def.pageLoadExtraDelayMs
                    settings.delayRandomizationPercent = def.delayRandomizationPercent
                    let normalized = settings.normalizedTimeouts()
                    settings = normalized
                    AutomationSettingsPersistence.shared.save(normalized)
                    withAnimation { saveToast = true }
                    Task { @MainActor in try? await Task.sleep(for: .seconds(1.5)); saveToast = false }
                }
                .foregroundStyle(.orange)
            }
        }
        .overlay(alignment: .bottom) {
            if saveToast {
                Text("Saved").font(.caption.bold())
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(Color.green.opacity(0.85)).clipShape(Capsule())
                    .padding(.bottom, 24).transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .automationSettingsDidChange)) { notification in
            if let newSettings = notification.object as? AutomationSettings {
                self.settings = newSettings
            }
        }
    }

    private var actionDelaysSection: some View {
        Section {
            msRow("Global Pre-Action", $settings.globalPreActionDelayMs)
            msRow("Global Post-Action", $settings.globalPostActionDelayMs)
        } header: {
            Text("Global Action Delays")
        } footer: {
            Text("Applied before/after every pattern execution in HumanInteractionEngine. Wired & active.")
        }
    }

    private var betweenAttemptSection: some View {
        Section {
            msRow("Between Attempts", $settings.betweenAttemptsDelayMs)
            msRow("Between Credentials", $settings.betweenCredentialsDelayMs)
            doubleRow("V4.2 Inter-Attempt Min (s)", $settings.v42InterAttemptDelayMinSec)
            doubleRow("V4.2 Inter-Attempt Max (s)", $settings.v42InterAttemptDelayMaxSec)
            if settings.v42InterAttemptDelayMinSec > settings.v42InterAttemptDelayMaxSec {
                Label("Min exceeds Max — will clamp at runtime", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption).foregroundStyle(.orange)
            }
        } header: {
            Text("Between-Attempt Delays")
        } footer: {
            Text("'Between Attempts' used by DualFind (no settlement). 'V4.2 Inter-Attempt' used by UnifiedSession settlement gate. Both wired & active.")
        }
    }

    private var settlementSection: some View {
        Section {
            msRow("Page Stabilization", $settings.pageStabilizationDelayMs)
            msRow("AJAX Settle", $settings.ajaxSettleDelayMs)
            msRow("DOM Mutation Settle", $settings.domMutationSettleMs)
            msRow("Animation Settle", $settings.animationSettleDelayMs)
            msRow("Redirect Follow", $settings.redirectFollowDelayMs)
        } header: {
            Text("Settlement Delays")
        } footer: {
            Text("Page stabilization used by StrictLoginDetectionEngine P3. All wired via LiveSpeedAdaptationService.adaptedDelays().")
        }
    }

    private var recoverySection: some View {
        Section {
            msRow("Challenge Detection", $settings.captchaDetectionDelayMs)
            msRow("Recovery", $settings.errorRecoveryDelayMs)
            msRow("Session Cooldown", $settings.sessionCooldownDelayMs)
            msRow("Proxy Rotation", $settings.proxyRotationDelayMs)
            msRow("VPN Reconnect", $settings.vpnReconnectDelayMs)
        } header: {
            Text("Recovery Delays")
        } footer: {
            Text("Error Recovery used by TrueDetectionService (no fingerprint fallback) and HumanInteractionEngine. All wired.")
        }
    }

    private var navigationSection: some View {
        Section {
            msRow("Pre-Navigation", $settings.preNavigationDelayMs)
            msRow("Post-Navigation", $settings.postNavigationDelayMs)
        } header: {
            Text("Navigation Delays")
        } footer: {
            Text("Post-Navigation applied after page load in DualFindViewModel.navigateAndSetupSession(). Wired.")
        }
    }

    private var fieldSection: some View {
        Section {
            msRow("Pre-Typing", $settings.preTypingDelayMs)
            msRow("Post-Typing", $settings.postTypingDelayMs)
            msRow("Inter-Field", $settings.interFieldDelayMs)
            msRow("Field Focus Delay", $settings.fieldFocusDelayMs)
            msRow("Cookie Dismiss Delay", $settings.cookieDismissDelayMs)
        } header: {
            Text("Field Interaction Delays")
        } footer: {
            Text("Pre-Typing: before filling each field. Inter-Field: between email and password. Post-Typing: after fill before submit. All wired in TrueDetectionService, HumanInteractionEngine, LoginAutomationEngine & DualFindViewModel.")
        }
    }

    private var submitSection: some View {
        Section {
            msRow("Pre-Submit", $settings.preSubmitDelayMs)
            msRow("Post-Submit", $settings.postSubmitDelayMs)
            msRow("Submit Retry Delay", $settings.submitRetryDelayMs)
            msRow("Submit Button Wait", $settings.submitButtonWaitDelayMs)
            msRow("Login Button Pre-Click", $settings.loginButtonPreClickDelayMs)
            msRow("Login Button Post-Click", $settings.loginButtonPostClickDelayMs)
            msRow("Hover Dwell / v42 Hover (ms) ⟳", $settings.v42HoverDwellMs)
            msRow("Page Load Extra Delay", $settings.pageLoadExtraDelayMs)
        } header: {
            Text("Submit Delays")
        } footer: {
            Text("⟳ Hover Dwell is shared: loginButtonHoverDurationMs and v42HoverDwellMs are the same value. Post-Submit used after each True Detection submit cycle.")
        }
    }

    private var screenSection: some View {
        Section {
            msRow("Screenshot Post-Click Delay", $settings.unifiedScreenshotPostClickDelayMs)
            msRow("Blank Page Recheck Interval", $settings.blankPageRecheckIntervalMs)
            msRow("Wait for JS Render", $settings.waitForJSRenderMs)
        } header: { Text("Screenshot & Page Delays") }
    }

    private var randomSection: some View {
        Section {
            Toggle("Delay Randomization", isOn: $settings.delayRandomizationEnabled)
            if settings.delayRandomizationEnabled {
                msRow("Randomization %", $settings.delayRandomizationPercent)
            }
            Toggle("Auto Fallback WG → OVPN", isOn: $settings.autoFallbackWGtoOVPN)
            Toggle("Auto Fallback OVPN → SOCKS5", isOn: $settings.autoFallbackOVPNtoSOCKS5)
        } header: {
            Text("Randomization & Fallback")
        } footer: {
            Text("Randomization adds ±N% variance to all delays. Fallback chain auto-switches network protocols on failure.")
        }
    }

    private func msRow(_ label: String, _ value: Binding<Int>) -> some View {
        HStack {
            Text(label).font(.subheadline)
            Spacer()
            TextField("ms", value: value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .onChange(of: value.wrappedValue) { _, new in
                    value.wrappedValue = max(0, new)
                }
            Text("ms").font(.caption).foregroundStyle(.secondary)
        }
    }

    private func doubleRow(_ label: String, _ value: Binding<Double>) -> some View {
        HStack {
            Text(label).font(.subheadline)
            Spacer()
            TextField("s", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .onChange(of: value.wrappedValue) { _, new in
                    value.wrappedValue = max(0, new)
                }
            Text("s").font(.caption).foregroundStyle(.secondary)
        }
    }
}


// MARK: - Sheet Wrapper (for DualFind / Unified presentation)

struct SettingsHubSheet: View {
    let onDone: () -> Void
    @State private var urlService = LoginURLRotationService.shared
    @State private var proxyService = ProxyRotationService.shared

    var body: some View {
        NavigationStack {
            List {
                automationSection
                urlsSection
                networkSection
                developerSection
                testingSection
                advancedSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings Hub")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDone).bold()
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationContentInteraction(.scrolls)
    }

    private var automationSection: some View {
        Section {
            NavigationLink { AutomationSettingsRootView() } label: {
                hubRow(icon: "gearshape.2.fill", title: "Automation Settings",
                       subtitle: "Timing · True Detection · Delays · Stealth", color: .red)
            }
            NavigationLink { AllDelaysSettingsView() } label: {
                hubRow(icon: "timer", title: "All Delays",
                       subtitle: "Every ms value — fully wired & active", color: .yellow)
            }
        } header: { Label("Automation", systemImage: "gearshape.2.fill") }
    }

    private var urlsSection: some View {
        Section {
            NavigationLink { URLManagementView() } label: {
                HStack(spacing: 12) {
                    iconCircle("arrow.triangle.2.circlepath", color: .green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("URL Management").font(.subheadline.bold())
                        let joeCount = urlService.joeURLs.filter(\.isEnabled).count
                        let ignCount = urlService.ignitionURLs.filter(\.isEnabled).count
                        Text("Joe: \(joeCount)/\(urlService.joeURLs.count) · Ignition: \(ignCount)/\(urlService.ignitionURLs.count) enabled")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
        } header: { Label("URLs", systemImage: "link.circle.fill") }
    }

    private var networkSection: some View {
        Section {
            NavigationLink { DeviceNetworkSettingsView() } label: {
                HStack(spacing: 12) {
                    iconCircle("network.badge.shield.half.filled", color: .blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Device Network Settings").font(.subheadline.bold())
                        Text("Proxy, VPN, WireGuard, DNS").font(.caption2).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(proxyService.unifiedConnectionMode.label)
                        .font(.system(.caption2, design: .monospaced, weight: .bold))
                        .foregroundStyle(.blue).padding(.horizontal, 6).padding(.vertical, 3)
                        .background(Color.blue.opacity(0.12)).clipShape(Capsule())
                }
            }
        } header: { Label("Network", systemImage: "lock.shield.fill") }
    }

    private var developerSection: some View {
        Section {
            NavigationLink { DeveloperSettingsView() } label: {
                hubRow(icon: "hammer.fill", title: "Developer Settings",
                       subtitle: "All 200+ granular automation parameters", color: .red)
            }
        } header: { Label("Developer", systemImage: "hammer.fill") }
    }

    private var testingSection: some View {
        Section {
            NavigationLink { SuperTestView() } label: {
                hubRow(icon: "bolt.horizontal.circle.fill", title: "Super Test",
                       subtitle: "Full infrastructure validation", color: .purple)
            }
            NavigationLink { IPScoreTestView() } label: {
                hubRow(icon: "network.badge.shield.half.filled", title: "IP Score Test",
                       subtitle: "8× concurrent IP quality analysis", color: .indigo)
            }
        } header: { Label("Testing", systemImage: "flask.fill") }
    }

    private var advancedSection: some View {
        Section {
            NavigationLink { AdvancedSettingsView() } label: {
                hubRow(icon: "gearshape.fill", title: "Advanced Settings",
                       subtitle: "Debug, diagnostics, data management", color: .gray)
            }
        } header: { Label("Advanced", systemImage: "ellipsis.circle.fill") }
    }

    private func iconCircle(_ systemName: String, color: Color) -> some View {
        ZStack {
            Circle().fill(color.opacity(0.12)).frame(width: 40, height: 40)
            Image(systemName: systemName).font(.body).foregroundStyle(color)
        }
    }

    private func hubRow(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 12) {
            iconCircle(icon, color: color)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(subtitle).font(.caption2).foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - URL Management Full Screen

struct URLManagementView: View {
    @State private var urlService = LoginURLRotationService.shared

    var body: some View {
        List {
            AppURLManagerSection(urlService: urlService)
        }
        .listStyle(.insetGrouped)
        .navigationTitle("URL Management")
        .navigationBarTitleDisplayMode(.inline)
    }
}
