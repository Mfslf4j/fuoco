class ProgressUtils {
  static Map<String, dynamic> calculateProgress(
      Map<String, dynamic> comic, String profile) {
    List<String> purchasedNumbers = (comic['bought_volumes'] ?? '').split(",");
    var purchaseProgress = purchasedNumbers.length / (comic['volumes'] ?? 1);
    var readingProgress =
        (comic['last_read_volume_${profile.toLowerCase()}'] ?? 0) /
            (comic['volumes'] ?? 1);
    String lastPurchasedVolume =
    purchasedNumbers.isNotEmpty ? purchasedNumbers.last : 'N/A';

    return {
      'isReadingInProgress': readingProgress > 0 && readingProgress < 1,
      'isPurchasingInProgress': purchaseProgress < 1,
      'isFullyPurchased': purchaseProgress == 1,
      'isFullyRead': readingProgress == 1,
      'isCompleted': purchaseProgress == 1 && readingProgress == 1,
      'readingProgress': readingProgress,
      'purchaseProgress': purchaseProgress,
      'lastPurchasedVolume': lastPurchasedVolume,
      'hasProgressBars': (readingProgress > 0 && readingProgress < 1) ||
          (purchaseProgress < 1 && purchaseProgress > 0),
    };
  }
}