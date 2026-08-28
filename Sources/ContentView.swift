import SwiftUI
import Engine

struct ContentView: View {
    @State private var path: [Int] = []
    @State private var hasAutoTriggered = false

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 44))
                    .foregroundStyle(.orange)

                Text("Engine issue 58")
                    .font(.title)

                Text("Open the destination to exercise Engine's tint environment lookup inside a toolbar.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Button("Navigate to reproducer") {
                    path.append(0)
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Engine Issue 58")
            .navigationDestination(for: Int.self) { _ in
                CrashDetailView()
            }
        }
        .frame(minWidth: 620, minHeight: 420)
        .onAppear {
            guard CommandLine.arguments.contains("--auto-trigger"), !hasAutoTriggered else { return }
            hasAutoTriggered = true

            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 500_000_000)
                path = [0]
            }
        }
    }
}

private struct CrashDetailView: View {
    @State private var stepper = 0

    var body: some View {
        VStack(spacing: 18) {
            Text("Detail View")
                .font(.title2)

            Text("The toolbar contains a direct tintStyle environment read and the custom Engine ViewStyle path from the related report.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Group {
                    ToolbarTintProbeView()

                    StepperView2(
                        StepperViewStyleConfiguration2(
                            onIncrement: { stepper += 1 },
                            onDecrement: { stepper -= 1 }
                        )
                    )

                    StepperView2 {
                        Text("\(stepper)")
                    } onIncrement: {
                        stepper += 1
                    } onDecrement: {
                        stepper -= 1
                    }
                }
                // The linked report uses .title on iOS; .principal is the macOS title-area equivalent.
                .styleContext(.toolbar)
            }
        }
    }
}

private struct ToolbarTintProbeView: View {
    @Environment(\.tintStyle) private var tintStyle

    var body: some View {
        Circle()
            .fill(tintStyle)
            .frame(width: 12, height: 12)
    }
}

private protocol StepperViewStyle2: ViewStyle where Configuration == StepperViewStyleConfiguration2 {
    associatedtype Configuration = Configuration
}

private struct StepperViewStyleConfiguration2 {
    struct Label: ViewAlias { }

    var label: Label { .init() }
    var onIncrement: () -> Void
    var onDecrement: () -> Void
}

private struct AutomaticStepperViewStyle2: StepperViewStyle2 {
    func makeBody(configuration: Configuration) -> some View {
        StepperView2(configuration)
            .stepperViewStyle2(DefaultStepperViewStyle2(), predicate: .toolbar)
            .stepperViewStyle2(InlineStepperViewStyle2())
    }
}

private struct DefaultStepperViewStyle2: StepperViewStyle2 {
    func makeBody(configuration: Configuration) -> some View {
        Stepper {
            configuration.label
        } onIncrement: {
            configuration.onIncrement()
        } onDecrement: {
            configuration.onDecrement()
        }
    }
}

private struct InlineStepperViewStyle2: StepperViewStyle2 {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Button {
                configuration.onDecrement()
            } label: {
                Image(systemName: "minus.circle.fill")
            }

            configuration.label

            Button {
                configuration.onIncrement()
            } label: {
                Image(systemName: "plus.circle.fill")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                configuration.onIncrement()
            case .decrement:
                configuration.onDecrement()
            default:
                break
            }
        }
    }
}

private extension View {
    func stepperViewStyle2<Style: StepperViewStyle2>(_ style: Style) -> some View {
        styledViewStyle(StepperViewBody2.self, style: style)
    }

    func stepperViewStyle2<Style: StepperViewStyle2, Context: StyleContext>(
        _ style: Style,
        predicate: Context
    ) -> some View {
        styledViewStyle(StepperViewBody2.self, style: style, predicate: predicate)
    }
}

private struct StepperView2<Label: View>: View {
    var label: Label
    var onIncrement: () -> Void
    var onDecrement: () -> Void

    init(
        @ViewBuilder label: () -> Label,
        onIncrement: @escaping () -> Void,
        onDecrement: @escaping () -> Void
    ) {
        self.label = label()
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }

    var body: some View {
        StepperViewBody2(
            configuration: .init(
                onIncrement: onIncrement,
                onDecrement: onDecrement
            )
        )
        .viewAlias(StepperViewStyleConfiguration2.Label.self) {
            label
        }
    }
}

private extension StepperView2 where Label == StepperViewStyleConfiguration2.Label {
    init(_ configuration: StepperViewStyleConfiguration2) {
        self.label = configuration.label
        self.onIncrement = configuration.onIncrement
        self.onDecrement = configuration.onDecrement
    }
}

private struct StepperViewBody2: ViewStyledView {
    var configuration: StepperViewStyleConfiguration2

    static var defaultStyle: some StepperViewStyle2 {
        AutomaticStepperViewStyle2()
    }
}
