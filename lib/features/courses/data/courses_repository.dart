import 'courses_api.dart';
import 'models/course.dart';

class CoursesRepository {
  CoursesRepository({CoursesApi? api}) : _api = api ?? CoursesApi();

  final CoursesApi _api;

  Future<List<CourseSummary>> getCourses({
    int page = 1,
    int perPage = 20,
    String? search,
    int? categoryId,
    String? categorySlug,
  }) async {
    final data = await _api.getCourses(
      page: page,
      perPage: perPage,
      search: search,
      categoryId: categoryId,
      categorySlug: categorySlug,
    );
    return data.map(CourseSummary.fromJson).toList();
  }

  Future<CourseDetail> getCourseDetail(int id) async {
    final data = await _api.getCourseDetail(id);
    return CourseDetail.fromJson(data);
  }
}
