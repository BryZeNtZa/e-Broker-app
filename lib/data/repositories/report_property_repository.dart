import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/data/model/report_property/reason_model.dart';

import 'package:ebroker/utils/api.dart';

class ReportPropertyRepository {
  Future<DataOutput<ReportReason>> fetchReportReasonsList() async {
    try {
      final response = await Api.get(
        url: Api.getReportReasons,
        queryParameters: {},
      );

      final list = (response['data'] as List).map((e) {
        return ReportReason(
          id: e['id'] as int,
          reason: e['reason']?.toString() ?? '',
        );
      }).toList();

      return DataOutput(
        total: int.parse(response['total']?.toString() ?? '0'),
        modelList: list,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<dynamic, dynamic>> reportProperty({
    required int reasonId,
    required int propertyId,
    String? message,
  }) async {
    return Api.post(
      url: Api.addReports,
      parameter: {
        'reason_id': (reasonId == -10) ? 0 : reasonId,
        'property_id': propertyId,
        if (message != null) 'other_message': message,
      },
    );
  }
}
