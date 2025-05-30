class GooglePlaceResponseModel {
  GooglePlaceResponseModel({this.predictions, this.status});

  GooglePlaceResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['predictions'] != null) {
      predictions = <Predictions>[];
      json['predictions'].forEach((v) {
        predictions!
            .add(Predictions.fromJson(v as Map<String, dynamic>? ?? {}));
      });
    }
    status = json['status']?.toString() ?? '';
  }
  List<Predictions>? predictions;
  String? status;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (predictions != null) {
      data['predictions'] = predictions!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    return data;
  }
}

class Predictions {
  Predictions({
    this.description,
    this.placeId,
    this.reference,
  });

  Predictions.fromJson(Map<String, dynamic> json) {
    description = json['description']?.toString() ?? '';

    placeId = json['place_id']?.toString() ?? '';
    reference = json['reference']?.toString() ?? '';
  }
  String? description;
  String? placeId;
  String? reference;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['description'] = description;

    data['place_id'] = placeId;
    data['reference'] = reference;

    return data;
  }
}
