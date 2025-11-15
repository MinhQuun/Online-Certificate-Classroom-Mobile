import 'models/combo.dart';
import 'combos_api.dart';

class CombosRepository {
  CombosRepository({CombosApi? api}) : _api = api ?? CombosApi();

  final CombosApi _api;

  Future<List<CourseCombo>> getCombos({int page = 1, int perPage = 6}) async {
    final json = await _api.getCombos(page: page, perPage: perPage);
    return json.map(CourseCombo.fromJson).toList();
  }
}
