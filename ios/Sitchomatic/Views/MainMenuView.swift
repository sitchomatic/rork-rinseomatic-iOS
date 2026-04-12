import SwiftUI

struct MainMenuView: View {
    @Binding var activeMode: ActiveAppMode?
    let requiresProfileSelection: Bool
    @State private var animateIn: Bool = false
    @State private var nordService = NordVPNService.shared
    private let proxyService = ProxyRotationService.shared

    init(activeMode: Binding<ActiveAppMode?>, requiresProfileSelection: Bool = false) {
        _activeMode = activeMode
        self.requiresProfileSelection = requiresProfileSelection
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("MainMenuBG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()

                Color.black.opacity(0.3)

                VStack(spacing: 0) {
                    profileSelector(geo: geo)
                        .frame(height: profileSelectorHeight(geo: geo))
                        .padding(.top, geo.safeAreaInsets.top + 4)
                        .padding(.bottom, 12)
                        .zIndex(10)

                    if profileSelectionNeeded {
                        profileSelectionBanner
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                    }

                    unifiedSessionZone(geo: geo)
                        .frame(height: (geo.size.height - geo.safeAreaInsets.top - geo.safeAreaInsets.bottom) * 0.27)

                    HStack(spacing: 0) {
                        dualFindZone(geo: geo)
                        credentialHubZone(geo: geo)
                    }
                    .frame(height: (geo.size.height - geo.safeAreaInsets.top - geo.safeAreaInsets.bottom) * 0.16)

                    ppsrZone(geo: geo)
                        .frame(height: (geo.size.height - geo.safeAreaInsets.top - geo.safeAreaInsets.bottom) * 0.15)

                    HStack(spacing: 0) {
                        toolsAndTestingZone(geo: geo)
                        settingsZone(geo: geo)
                    }
                    .frame(maxHeight: .infinity)

                    Spacer().frame(height: geo.safeAreaInsets.bottom + 4)
                }

                ghostTrigger(geo: geo)

                VStack {
                    Spacer()

                    HStack {
                        Spacer()
                        Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.15))
                            .padding(.trailing, 16)
                    }
                    .padding(.bottom, geo.safeAreaInsets.bottom + 6)
                }
                .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.spring(duration: 0.7, bounce: 0.12)) {
                animateIn = true
            }
        }
        .onDisappear {
            animateIn = false
        }
    }

    private func profileSelector(geo: GeometryProxy) -> some View {
        SplitProfileSelectorView(
            nordService: nordService,
            height: profileSelectorHeight(geo: geo),
            animateIn: animateIn
        )
    }

    private func profileSelectorHeight(geo: GeometryProxy) -> CGFloat {
        let availableHeight: CGFloat = geo.size.height - geo.safeAreaInsets.top - geo.safeAreaInsets.bottom
        return min(max(availableHeight * 0.23, 170), 232)
    }

    private func unifiedSessionZone(geo: GeometryProxy) -> some View {
        Button {
            guard canEnterModes else { return }
            withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
                activeMode = .unifiedSession
            }
        } label: {
            ZStack {
                LinearGradient(
                    colors: [.green.opacity(0.12), .orange.opacity(0.12)],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "suit.spade.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.green)
                                .symbolEffect(.pulse, options: .repeating.speed(0.4))
                                .shadow(color: .green.opacity(0.6), radius: 10)
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundStyle(.white.opacity(0.4))
                            Image(systemName: "flame.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.orange)
                                .symbolEffect(.pulse, options: .repeating.speed(0.4))
                                .shadow(color: .orange.opacity(0.6), radius: 10)
                        }

                        Text("UNIFIED\nSESSIONS")
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundStyle(.white)
                            .lineSpacing(2)
                            .shadow(color: .black.opacity(0.8), radius: 4)

                        Text("JoePoint + Ignition Lite · Paired Testing")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.6))

                        Text("V4.1 · 4 Workers · Early-Stop Sync")
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.35))
                    }
                    .padding(.leading, 20)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 8) {
                        Image(systemName: "rectangle.split.2x1.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(colors: [.green, .orange], startPoint: .leading, endPoint: .trailing)
                            )
                            .shadow(color: .green.opacity(0.3), radius: 8)

                        HStack(spacing: 3) {
                            Text("LAUNCH")
                                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.6))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 8, weight: .heavy))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                    .padding(.trailing, 20)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(animateIn ? (canEnterModes ? 1 : 0.35) : 0)
        .offset(y: animateIn ? 0 : -20)
        .allowsHitTesting(canEnterModes)
        .sensoryFeedback(.impact(weight: .heavy), trigger: activeMode == .unifiedSession)
    }

    private func dualFindZone(geo: GeometryProxy) -> some View {
        Button {
            guard canEnterModes else { return }
            withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
                activeMode = .dualFind
            }
        } label: {
            ZStack {
                LinearGradient(
                    colors: [.purple.opacity(0.15), .indigo.opacity(0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.purple)
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.indigo)
                        }
                        .shadow(color: .purple.opacity(0.5), radius: 8)

                        Text("DUAL FIND")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.6), radius: 4)

                        Text("Email × 3 Passwords")
                            .font(.system(size: 8, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.purple.opacity(0.7))

                        HStack(spacing: 3) {
                            Text("FIND")
                                .font(.system(size: 8, weight: .heavy, design: .monospaced))
                                .foregroundStyle(.purple.opacity(0.6))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 7, weight: .heavy))
                                .foregroundStyle(.purple.opacity(0.4))
                        }
                    }
                    .padding(.leading, 20)

                    Spacer()
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(animateIn ? (canEnterModes ? 1 : 0.35) : 0)
        .offset(x: animateIn ? 0 : -30)
        .allowsHitTesting(canEnterModes)
        .sensoryFeedback(.impact(weight: .medium), trigger: activeMode == .dualFind)
    }

    private func credentialHubZone(geo: GeometryProxy) -> some View {
        Button {
            guard canEnterModes else { return }
            withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
                activeMode = .credentialHub
            }
        } label: {
            ZStack {
                LinearGradient(
                    colors: [.green.opacity(0.16), .mint.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.crop.rectangle.stack.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.green)
                            Image(systemName: "square.and.arrow.down.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.mint)
                        }
                        .shadow(color: .green.opacity(0.4), radius: 8)

                        Text("CREDENTIAL HUB")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.6), radius: 4)

                        Text("Dashboard · Import · Saved · Working · Sessions")
                            .font(.system(size: 8, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.55))
                    }
                    .padding(.leading, 20)

                    Spacer()
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(animateIn ? (canEnterModes ? 1 : 0.35) : 0)
        .offset(x: animateIn ? 0 : 30)
        .allowsHitTesting(canEnterModes)
        .sensoryFeedback(.impact(weight: .medium), trigger: activeMode == .credentialHub)
    }

    private func ppsrZone(geo: GeometryProxy) -> some View {
        Button {
            guard canEnterModes else { return }
            withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
                activeMode = .ppsr
            }
        } label: {
            ZStack(alignment: .leading) {
                LinearGradient(
                    colors: [.cyan.opacity(0.2), .blue.opacity(0.05)],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                HStack(spacing: 14) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.cyan)
                        .shadow(color: .cyan.opacity(0.5), radius: 8)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("CARD")
                            .font(.system(size: 20, weight: .black, design: .monospaced))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.6), radius: 4)

                        Text("TESTING")
                            .font(.system(size: 20, weight: .black, design: .monospaced))
                            .foregroundStyle(.cyan)
                            .shadow(color: .cyan.opacity(0.4), radius: 4)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("PPSR, BPOINT & WA REGO")
                            .font(.system(size: 8, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.cyan.opacity(0.6))

                        HStack(spacing: 3) {
                            Text("ENTER")
                                .font(.system(size: 8, weight: .heavy, design: .monospaced))
                                .foregroundStyle(.cyan.opacity(0.6))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 7, weight: .heavy))
                                .foregroundStyle(.cyan.opacity(0.4))
                        }
                    }
                }
                .padding(.leading, 20)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(animateIn ? (canEnterModes ? 1 : 0.35) : 0)
        .offset(y: animateIn ? 0 : 30)
        .allowsHitTesting(canEnterModes)
        .sensoryFeedback(.impact(weight: .medium), trigger: activeMode == .ppsr)
    }

    private func toolsAndTestingZone(geo: GeometryProxy) -> some View {
        Button {
            guard canEnterModes else { return }
            withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
                activeMode = .toolsAndTesting
            }
        } label: {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.4), Color(red: 0.2, green: 0.3, blue: 0.5).opacity(0.3)],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "wrench.and.screwdriver.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                            Image(systemName: "flask.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.orange.opacity(0.7))
                        }
                        .shadow(color: .orange.opacity(0.4), radius: 8)

                        Text("TOOLS & TESTING")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.6), radius: 4)

                        Text("Super Test · Debug · Nord · Recorder")
                            .font(.system(size: 8, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.leading, 20)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "flask.fill")
                            Image(systemName: "network")
                            Image(systemName: "brain.head.profile.fill")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))

                        HStack(spacing: 3) {
                            Text("OPEN")
                                .font(.system(size: 8, weight: .heavy, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.5))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 7, weight: .heavy))
                                .foregroundStyle(.white.opacity(0.3))
                        }
                    }
                    .padding(.trailing, 20)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(animateIn ? (canEnterModes ? 1 : 0.35) : 0)
        .offset(y: animateIn ? 0 : 30)
        .allowsHitTesting(canEnterModes)
        .sensoryFeedback(.impact(weight: .medium), trigger: activeMode == .toolsAndTesting)
    }

    private func settingsZone(geo: GeometryProxy) -> some View {
        Button {
            guard canEnterModes else { return }
            withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
                activeMode = .settings
            }
        } label: {
            ZStack {
                LinearGradient(
                    colors: [Color(.secondarySystemBackground).opacity(0.35), connectionModeColor.opacity(0.22)],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(connectionModeColor)
                            .shadow(color: connectionModeColor.opacity(0.4), radius: 8)

                        Text("SETTINGS")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.6), radius: 4)

                        Text("Automation · URLs · Network · Vault")
                            .font(.system(size: 8, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.55))

                        HStack(spacing: 5) {
                            Image(systemName: proxyService.unifiedConnectionMode.icon)
                                .font(.system(size: 8, weight: .bold))
                            Text(proxyService.unifiedConnectionMode.label.uppercased())
                                .font(.system(size: 8, weight: .heavy, design: .monospaced))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(connectionModeColor.opacity(0.45))
                        .clipShape(Capsule())
                    }
                    .padding(.leading, 20)

                    Spacer()
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(animateIn ? (canEnterModes ? 1 : 0.35) : 0)
        .offset(x: animateIn ? 0 : 30)
        .allowsHitTesting(canEnterModes)
        .sensoryFeedback(.impact(weight: .medium), trigger: activeMode == .settings)
    }

    private func ghostTrigger(geo: GeometryProxy) -> some View {
        Color.clear
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .onTapGesture(count: 3) {
                openCustomSitch()
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 1.1)
                    .onEnded { _ in
                        openCustomSitch()
                    }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.top, geo.safeAreaInsets.top + 4)
            .padding(.trailing, 4)
    }

    private func openCustomSitch() {
        guard canEnterModes else { return }
        withAnimation(.spring(duration: 0.35, bounce: 0.15)) {
            activeMode = .customSitch
        }
    }

    private var connectionModeColor: Color {
        switch proxyService.unifiedConnectionMode {
        case .direct: .green
        case .proxy: .blue
        case .openvpn: .indigo
        case .wireguard: .purple
        case .dns: .cyan
        case .nodeMaven: .teal
        case .hybrid: .mint
        }
    }

    private var canEnterModes: Bool {
        !requiresProfileSelection || nordService.hasSelectedProfile
    }

    private var profileSelectionNeeded: Bool {
        requiresProfileSelection && !nordService.hasSelectedProfile
    }

    private func isProfileActive(_ profile: NordKeyProfile) -> Bool {
        nordService.hasSelectedProfile && nordService.activeKeyProfile == profile
    }

    private var profileSelectionBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.title3)
                .foregroundStyle(.yellow)

            VStack(alignment: .leading, spacing: 4) {
                Text("Choose Nick or Poli to continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("No profile is selected automatically on first launch.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.white.opacity(0.10))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        )
    }
}

