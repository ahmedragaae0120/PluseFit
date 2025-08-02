import 'package:dio/dio.dart';
import 'package:fit_zone/core/cache/shared_pref.dart';
import 'package:fit_zone/core/utils/routes_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constant.dart';

@singleton
class ApiManager {
  static late Dio dio;
  static late Dio mealDio;
  static late GlobalKey<NavigatorState> _navigatorKey;

  static init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    dio = Dio(
      BaseOptions(
          baseUrl: Constant.baseUrl,
          connectTimeout: Constant.connectTimeout,
          receiveTimeout: Constant.connectTimeout,
          sendTimeout: Constant.connectTimeout),
    );
    dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
        filter: (options, args) {
          // don't print requests with uris containing '/posts'
          if (options.path.contains('/posts')) {
            return false;
          }
          // don't print responses with unit8 list data
          return !args.isResponse || !args.hasUint8ListData;
        }));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = CacheHelper.getData<String>(Constant.tokenKey);
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await CacheHelper.removeData(Constant.tokenKey);
            await CacheHelper.removeData(Constant.isRememberMe);
            await CacheHelper.removeData(Constant.userName);
            _navigatorKey.currentState!.pushNamedAndRemoveUntil(
              RouteManager.loginScreen,
              (route) => false,
            );
            return handler.reject(DioException(
              requestOptions: error.requestOptions,
              error: 'Session expired. Please log in again.',
              type: DioExceptionType.badResponse,
              response: error.response,
            ));
          }
          return handler.next(error);
        },
      ),
    );

    mealDio = Dio(
      BaseOptions(
          baseUrl: Constant.mealBaseUrl,
          connectTimeout: Constant.connectTimeout,
          receiveTimeout: Constant.connectTimeout,
          sendTimeout: Constant.connectTimeout),
    );

    mealDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = CacheHelper.getData<String>(Constant.tokenKey);
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await CacheHelper.removeData(Constant.tokenKey);
            await CacheHelper.removeData(Constant.isRememberMe);
            await CacheHelper.removeData(Constant.userName);
            _navigatorKey.currentState!.pushNamedAndRemoveUntil(
              RouteManager.loginScreen,
              (route) => false,
            );
            return handler.reject(DioException(
              requestOptions: error.requestOptions,
              error: 'Session expired. Please log in again.',
              type: DioExceptionType.badResponse,
              response: error.response,
            ));
          }
          return handler.next(error);
        },
      ),
    );
    mealDio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
        filter: (options, args) {
          // don't print requests with uris containing '/posts'
          if (options.path.contains('/posts')) {
            return false;
          }
          // don't print responses with unit8 list data
          return !args.isResponse || !args.hasUint8ListData;
        }));
  }

  Future<Response> getRequestForMeal(
      {required String endpoint,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers}) async {
    var response = await mealDio.get(endpoint,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ));
    return response;
  }

  Future<Response> getRequest({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    var response = await dio.get(
      endpoint,
      queryParameters: queryParameters,
    );
    return response;
  }

  Future<Response> postRequest({
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    var response = await dio.post(
      endpoint,
      data: body,
    );
    return response;
  }

  Future<Response> put({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data, // ✅ Add this parameter for the request body
  }) async {
    var response = await dio.put(
      endpoint,
      queryParameters: queryParameters,
    );
    return response;
  }

  Future<Response> delete({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    var response = await dio.delete(
      endpoint,
      queryParameters: queryParameters,
    );
    return response;
  }

  Future<Response> patchRequest({
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    var response = await dio.patch(
      endpoint,
      data: body,
    );
    return response;
  }

  Future<Response> putFormData({
    required String endpoint,
    required FormData formData, // Change to accept FormData directly
    Map<String, dynamic>? headers,
  }) async {
    try {
      var response = await dio.put(
        endpoint,
        data: formData,
        options: Options(
          headers: headers,
          contentType: 'multipart/form-data',
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
