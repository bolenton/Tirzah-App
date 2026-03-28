import SwiftUI

struct PieceTrayView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 8) {
            // Tray header
            HStack {
                Text("Pieces")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.vbTextSecondary)

                Spacer()

                Text("\(viewModel.availablePieces.count) remaining")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.vbTextSecondary)
            }
            .padding(.horizontal, 24)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(viewModel.availablePieces.count) pieces remaining")

            // Scrollable piece cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.availablePieces) { piece in
                        PieceCard(
                            piece: piece,
                            isSelected: viewModel.selectedPieceId == piece.id
                        ) {
                            viewModel.selectPiece(piece.id)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 12)
        .background(Color.vbSurface)
    }
}

struct PieceCard: View {
    let piece: PieceViewModel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Piece preview (colored rectangle representing the piece)
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: piece.color))
                    .frame(width: 64, height: 64)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )

                Text(piece.label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.vbText)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text(piece.typeName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.vbTextSecondary)
            }
            .frame(width: 100, height: 120)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.vbAccent.opacity(0.2) : Color.vbBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.vbAccent : Color.clear, lineWidth: 3)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(piece.label), \(piece.typeName)")
        .accessibilityHint(isSelected ? "Currently selected. Tap a slot on the grid to place it." : "Tap to select this piece")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct PieceViewModel: Identifiable {
    let id: String
    let label: String
    let typeName: String
    let color: String
    let width: Int
    let height: Int
}
