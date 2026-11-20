import SwiftUI

struct EqualizerView: View {
    @ObservedObject var viewModel: MusicViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPreset: String = "Flat"

    let presets = ["Flat", "Bass Boost", "Rock", "Pop", "Vocal"]

    var body: some View {
        ZStack {
            Color.blackBg.ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Equalizer")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.whitePrimary)

                    Spacer()

                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.redPrimary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Presets Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("PRESET")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(.whiteSecondary)
                        .padding(.horizontal, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(presets, id: \.self) { preset in
                                Button(action: {
                                    selectedPreset = preset
                                    viewModel.applyPreset(name: preset)
                                }) {
                                    Text(preset)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(selectedPreset == preset ? .whitePrimary : .whiteSecondary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedPreset == preset ? Color.redPrimary : Color.blackElevated)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                // 5 Frequency Bands (60Hz, 230Hz, 910Hz, 3.6kHz, 14kHz)
                VStack(spacing: 12) {
                    Text("FREQUENCY BANDS (-15 dB to +15 dB)")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(.whiteSecondary)

                    HStack(spacing: 20) {
                        ForEach(viewModel.eqBands.indices, id: \.self) { index in
                            VStack(spacing: 12) {
                                Text("\(Int(viewModel.eqBands[index].gain)) dB")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.redPrimary)

                                // Vertical Slider
                                VerticalSlider(
                                    value: Binding(
                                        get: { Double(viewModel.eqBands[index].gain) },
                                        set: { viewModel.updateEqBand(index: index, gain: Float($0)) }
                                    ),
                                    range: -15...15
                                )
                                .frame(width: 32, height: 160)

                                Text(viewModel.eqBands[index].frequency)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.whiteSecondary)
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .background(Color.blackCard)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                }

                // Bass Boost & 3D Virtualizer Card
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Bass Boost")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.whitePrimary)
                            Spacer()
                            Text("\(Int(viewModel.bassBoostLevel))%")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.redPrimary)
                        }
                        Slider(value: Binding(
                            get: { Double(viewModel.bassBoostLevel) },
                            set: { viewModel.bassBoostLevel = Float($0) }
                        ), in: 0...100)
                        .accentColor(.redPrimary)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("3D Virtualizer")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.whitePrimary)
                            Spacer()
                            Text("\(Int(viewModel.virtualizerLevel))%")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.redPrimary)
                        }
                        Slider(value: Binding(
                            get: { Double(viewModel.virtualizerLevel) },
                            set: { viewModel.virtualizerLevel = Float($0) }
                        ), in: 0...100)
                        .accentColor(.redPrimary)
                    }
                }
                .padding(16)
                .background(Color.blackCard)
                .cornerRadius(16)
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}

struct VerticalSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let normalized = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
            let thumbY = height * (1.0 - CGFloat(normalized))

            ZStack(alignment: .bottom) {
                // Track Background
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.blackElevated)
                    .frame(width: 6)

                // Progress Track
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.redPrimary)
                    .frame(width: 6, height: max(0, height - thumbY))

                // Thumb
                Circle()
                    .fill(Color.redPrimary)
                    .frame(width: 22, height: 22)
                    .overlay(Circle().stroke(Color.whitePrimary, lineWidth: 2))
                    .offset(y: thumbY - height + 11)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let y = min(max(0, gesture.location.y), height)
                        let newNorm = 1.0 - Double(y / height)
                        value = range.lowerBound + newNorm * (range.upperBound - range.lowerBound)
                    }
            )
        }
    }
}
