import 'package:fit_zone/core/api/api_result.dart';
import 'package:fit_zone/core/api/endpoints.dart';
import 'package:fit_zone/core/api/api_manager.dart';
import 'package:injectable/injectable.dart';
import '../../core/api/api_excuter.dart';
import '../data_source_contract/change_password_datasource.dart';

@Injectable(as: ChangePasswordDatasource)
class ChangePasswordDatasourceImpl implements ChangePasswordDatasource {
  final ApiManager apiManager;

  ChangePasswordDatasourceImpl(this.apiManager);

  @override
  Future<ApiResult<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await executeApi<bool>(() async {
      var apiResponse = await apiManager.patchRequest(
        endpoint: EndPoint.changePasswordEndpoint,
        body: {
          "password": currentPassword,
          "newPassword": newPassword,
        },
      );
      if (apiResponse.data != null &&
          apiResponse.data["message"] == "success") {
        return true;
      } else {
        return false;
      }
    });
  }
}
