import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/data/model/interested_user_model.dart';

import 'package:ebroker/utils/api.dart';

class InterestRepository {
  ///this method will set if we are interested in any category when we click intereseted
  Future<void> setInterest({
    required String propertyId,
    required String interest,
  }) async {
    await Api.post(
      url: Api.interestedUsers,
      parameter: {
        Api.type: interest,
        Api.propertyId: propertyId,
      },
    );
  }

  Future<DataOutput<InterestedUserModel>> getInterestUser(
    String propertyId, {
    required int offset,
  }) async {
    try {
      final response = await Api.get(
        useAuthToken: true,
        url: Api.getInterestedUsers,
        queryParameters: {
          'property_id': propertyId,
        },
      );
      if (response['error'] == true) {
        return DataOutput(total: 0, modelList: []);
      }
      final interestedUserList = (response['data'] as List)
          .cast<Map<String, dynamic>>()
          .map<InterestedUserModel>(InterestedUserModel.fromJson)
          .toList();

      return DataOutput(
        total: response['total'] as int? ?? 0,
        modelList: interestedUserList,
      );
    } catch (_) {
      return DataOutput(total: 0, modelList: []);
    }
  }
}
