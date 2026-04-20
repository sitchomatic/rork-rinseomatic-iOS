import SwiftUI

struct CredentialHubView: View {
    @State private var vm = LoginViewModel.shared
    @State private var selectedTab: CredentialHubTab = .dashboard

    nonisolated enum CredentialHubTab: String, Sendable {
        case dashboard
        case importCredentials
        case saved
        case working
        case sessions
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Dashboard", systemImage: "rectangle.grid.2x2.fill", value: .dashboard) {
                NavigationStack {
                    LoginDashboardContentView(vm: vm)
                }
            }

            Tab("Import", systemImage: "square.and.arrow.down.fill", value: .importCredentials) {
                NavigationStack {
                    CredentialImportView(vm: vm)
                }
            }

            Tab("Saved", systemImage: "tray.full.fill", value: .saved) {
                NavigationStack {
                    LoginCredentialsListView(vm: vm)
                }
            }

            Tab("Working", systemImage: "checkmark.shield.fill", value: .working) {
                NavigationStack {
                    LoginWorkingListView(vm: vm)
                }
            }

            Tab("Sessions", systemImage: "rectangle.stack.fill", value: .sessions) {
                NavigationStack {
                    LoginSessionMonitorContentView(vm: vm)
                }
            }
        }
        .tint(.green)
        .preferredColorScheme(vm.appearanceMode.colorScheme)
        .withMainMenuButton()
    }
}
