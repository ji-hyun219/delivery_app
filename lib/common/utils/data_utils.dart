import '../const/data.dart';

class DataUtils {
  static String pathToUrl(String value) {
    return 'http://$ip$value';
  }

  static List<String> listPathsToUrls(List paths) {
    // List<String> 이 아니라 List 로 써준 이유는
    // 컴파일러가 List<dynamic> 으로 인식할 것이기 때문
    return paths.map((e) => pathToUrl(e)).toList();
  }
}
