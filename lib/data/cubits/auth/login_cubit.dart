// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:ebroker/data/repositories/auth_repository.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginInProgress extends LoginState {}

class LoginSuccess extends LoginState {
  final bool isProfileCompleted;
  LoginSuccess({
    required this.isProfileCompleted,
  });
}

class LoginFailure extends LoginState {
  final String errorMessage;
  LoginFailure(this.errorMessage);
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  final AuthRepository _authRepository = AuthRepository();
  bool isProfileIsCompleted = false;

  Future<void> login({
    required String? phoneNumber,
    required String uniqueId,
    required LoginType type,
    required dynamic countryCode,
    String? email,
    String? name,
    String? password,
    String? reEnteredPassword,
  }) async {
    try {
      emit(LoginInProgress());
      final result = await _authRepository.loginWithApi(
        type: type,
        email: email,
        name: name,
        phone: phoneNumber,
        uid: uniqueId,
      );

      if (result['error'] == true) {
        emit(LoginFailure(result['message']?.toString() ?? ''));
        return;
      }

      ///Storing data to local database {HIVE}
      await HiveUtils.setJWT(result['token']?.toString() ?? '');

      isProfileIsCompleted = true;
      final data = result['data'] as Map;
      data['countryCode'] = countryCode;
      data['type'] = type.name;

      await HiveUtils.setUserData(data);
      // }

      emit(LoginSuccess(isProfileCompleted: isProfileIsCompleted));
    } catch (e, st) {
      log(st.toString(), name: 'login');
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
    required LoginType type,
  }) async {
    try {
      emit(LoginInProgress());
      final result = await _authRepository.loginWithEmail(
        email: email,
        password: password,
        type: type,
      );

      if (result['error'] == true) {
        emit(LoginFailure(result['message']?.toString() ?? ''));
        return;
      }
      if (result['error'] != true) {
        ///Storing data to local database {HIVE}
        await HiveUtils.setJWT(result['token']?.toString() ?? '');

        isProfileIsCompleted = true;
        final data = result['data'] as Map;
        data['type'] = type.name;

        await HiveUtils.setUserData(data);
      }

      emit(LoginSuccess(isProfileCompleted: isProfileIsCompleted));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
