import 'package:v04/models/hero_model.dart';

abstract interface class HeroDataManaging {  
  void persist(HeroModel hero);
  void delete(HeroModel hero);
  void clear();
  List<HeroModel> query(String query);
  Future<Null> dispose(); 
  List<HeroModel> get heroes;
  HeroModel? getByExternalId(String externalId);
  HeroModel? getById(String id);
}
