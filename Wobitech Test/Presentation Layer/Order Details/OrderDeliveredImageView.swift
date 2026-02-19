import SwiftUI

struct OrderDeliveredImageView: View {
  private let assetName: String

  init(assetName: String = "deliveredPhoto") {
    self.assetName = assetName
  }

  var body: some View {
    Image(assetName)
      .resizable()
      .scaledToFill()
      .aspectRatio(1, contentMode: .fit)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .accessibilityLabel(L10n.text("orderDetails.image.delivered.accessibilityLabel"))
  }
}
