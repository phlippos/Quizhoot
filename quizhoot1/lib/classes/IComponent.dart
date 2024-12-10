import 'package:http/http.dart' as  http;

abstract class IComponent {

  Future<http.Response> add();

  Future<bool> update();

  Future<bool> remove();

}
