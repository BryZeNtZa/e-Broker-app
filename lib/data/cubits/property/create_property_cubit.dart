// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CreatePropertyState {}

class CreatePropertyInitial extends CreatePropertyState {}

class CreatePropertyInProgress extends CreatePropertyState {}

class CreatePropertySuccess extends CreatePropertyState {
  final PropertyModel? propertyModel;
  CreatePropertySuccess({
    this.propertyModel,
  });
}

class CreatePropertyFailure extends CreatePropertyState {
  final String errorMessage;

  CreatePropertyFailure(this.errorMessage);
}

class CreatePropertyCubit extends Cubit<CreatePropertyState> {
  final PropertyRepository _propertyRepository = PropertyRepository();

  CreatePropertyCubit() : super(CreatePropertyInitial());

  Future<void> create({
    required Map<String, dynamic> parameters,
  }) async {
    try {
      emit(CreatePropertyInProgress());
      final result = await _propertyRepository.createProperty(
        parameters: parameters,
      );
      if (result['error'] == true) {
        emit(CreatePropertyFailure(result['message']?.toString() ?? ''));
        return;
      }

      final data = result['data'][0] as Map<String, dynamic>?;

      if (result['data'] != null) {
        emit(
          CreatePropertySuccess(
            propertyModel: PropertyModel.fromMap(data ?? {}),
          ),
        );
      } else {
        if (result is Map) {
          emit(CreatePropertyFailure(result['message'].toString()));
        } else {
          emit(CreatePropertyFailure('Something went wrong'));
        }
      }
    } catch (e, st) {
      log(e.toString());
      log(st.toString());
      emit(CreatePropertyFailure(e.toString()));
    }
  }
}
