abstract interface class HeroServicing {
  Future<(Map<String, dynamic>?, String?)> search(String name);
  Future<(Map<String, dynamic>?, String?)> getById(String id);
}
