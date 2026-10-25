class NfcService {
  Future<bool> isAvailable() async => false;
  
  Future<String?> scanCard({required Function(String) onStatus}) async {
    onStatus('NFC funksiyası hazırda əlçatan deyil.');
    return null;
  }
  
  Future<String?> getSavedUid() async => null;
  
  Future<void> clearUid() async {}
}