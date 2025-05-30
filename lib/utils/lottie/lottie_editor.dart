import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class LottieEditor {
  LottieEditor();
  final ValueNotifier<Map<String, dynamic>?> _lottieNotifier =
      ValueNotifier<Map<String, dynamic>>({});
  Map<String, dynamic>? get lottieJson => _lottieNotifier.value;
  ValueNotifier<Map<String, dynamic>?> get listener => _lottieNotifier;

  ///This is to load lottie file put here asset file path
  ///CALL THIS FIRST->
  Future<void> openAndLoad(String path) async {
    try {
      final data = await rootBundle.loadString(path);
      final lottieJson = json.decode(data) as Map<String, dynamic>;
      _updateLottieJson(lottieJson);
    } catch (e) {
      _handleError('Error opening and loading Lottie file', e);
    }
  }

  ////This function is used to modify all colors of lottie with their opacity
  ////USE THIS-->
  void changeWholeLottieFileColor(Color targetColor) {
    if (lottieJson != null) {
      final modifiedJson = modifyColorsRecursive(lottieJson!, targetColor);
      _updateLottieJson(modifiedJson);
    } else {}
  }

  ////This file is to modify colors by their shape name; [Useful for multiple color lottie]
  void changeColorsOfShapeNames(List<String> shapeNames, Color targetColor) {
    if (lottieJson != null) {
      final modifiedJson =
          modifyColorsByShapeNames(lottieJson!, shapeNames, targetColor);
      _updateLottieJson(modifiedJson);
    } else {}
  }

  ///This will convert json to UINT8
  ///USE THIS TO DISPLAY LOTTIE

  Uint8List convertToUint8List() {
    if (lottieJson != null) {
      return Uint8List.fromList(utf8.encode(json.encode(lottieJson)));
    } else {
      return Uint8List(0); // Return an empty list or handle as needed
    }
  }

  // Private method to modify colors recursively
  Map<String, dynamic> modifyColorsRecursive(
    Map<String, dynamic> json,
    Color targetColor,
  ) {
    final layers = (json['layers'] as List<dynamic>?) ?? [];

    for (final dynamic layer in layers) {
      _modifyLayerColors(layer, targetColor);
    }
    return json;
  }

  // Private method to modify colors by shape names
  Map<String, dynamic> modifyColorsByShapeNames(
    Map<String, dynamic> json,
    List<String> shapeNames,
    Color targetColor,
  ) {
    final layers = (json['layers'] as List<dynamic>?) ?? [];
    for (final dynamic layer in layers) {
      _modifyLayerColorsByShapeNames(layer, shapeNames, targetColor);
    }
    return json;
  }

  // Private method to modify colors within a layer
  void _modifyLayerColors(layer, Color targetColor) {
    final shapes = (layer['shapes'] as List<dynamic>?) ?? [];
    for (final dynamic shape in shapes) {
      _loopShapes(shape as Map<String, dynamic>, targetColor);
    }
  }

  void _loopShapes(Map<dynamic, dynamic> shape, targetColor) {
    final shapes = (shape['it'] as List?) ?? [];
    for (final element in shapes) {
      if (element['ty'] == 'fl') {
        element['c'] = _flutterColorToLottie(targetColor as Color);
      } else if (element['ty'] == 'gr') {
        _loopShapes(element as Map<dynamic, dynamic>, targetColor);
      } else if (element['ty'] == 'st') {
        element['c'] = _flutterColorToLottie(targetColor as Color);
      }
    }
  }

  // Private method to modify colors within a layer based on shape names
  void _modifyLayerColorsByShapeNames(
    layer,
    List<String> shapeNames,
    Color targetColor,
  ) {
    final shapes = (layer['shapes'] as List<dynamic>?) ?? [];
    for (final dynamic shape in shapes) {
      if (shape['ty'] == 'fl' || shape['ty'] == 'st') {
        final shapeName = shape['nm']?.toString() ?? '';

        if (shapeNames.contains(shapeName)) {
          shape['c'] = _flutterColorToLottie(targetColor);
        }
      } else if (shape['ty'] == 'gr') {
        _modifyLayerColorsByShapeNames(shape, shapeNames, targetColor);
      }
    }
  }

  // Private method to handle errors
  void _handleError(String message, error) {
    log('$message: $error');
    // You can choose to throw an exception, log the error, or handle it differently.
  }

  // Private method to update the Lottie JSON and notify listeners
  void _updateLottieJson(Map<String, dynamic> modifiedJson) {
    _lottieNotifier.value = modifiedJson;
  }

  // Private method to convert Flutter color to Lottie color format
  Map<String, dynamic> _flutterColorToLottie(Color flutterColor) {
    final red = flutterColor.r;
    final green = flutterColor.g;
    final blue = flutterColor.b;
    final alpha = flutterColor.a;

    return {
      'a': 0,
      'k': [red, green, blue, alpha],
      'ix': 4,
    };
  }

  // Dispose method to release resources
  void dispose() {
    _lottieNotifier.dispose();
  }
}

/***
 *
 * //THIS IS EXPERIMENTAL
    Future<void> extractLayersInfo(BuildContext context) async {
    try {
    final ByteData data = await rootBundle.load("assets/lottie/onbo_a.json");
    final LottieComposition composition =
    await LottieComposition.fromByteData(data);
    recurs(composition.layers);
    log({"layers": composition.layers, "": composition.name}.toString());
    } catch (e) {
    print('Error loading Lottie file: $e');
    }
    }

    recurs(List<Layer> layers) {
    for (Layer layer in layers) {
    log("LAYER : ${layer.name} ${layer.id}");
    shapeGroupRecurs(layer.shapes);
    }
    }

    shapeGroupRecurs(List<ContentModel> shapes) {
    for (ContentModel element in shapes) {
    log("ELEMENT ISS $element");

    if (element is ShapeGroup) {
    shapeGroupRecurs(element.items);

    log(" SHAPE GROUP: ${element.name}");
    }

    if (element is ShapePath) {
    log("SHAPE PATH: ${element.name} ${element}");
    }

    if (element is ShapeFill) {
    shapes.remove(element);
    log("SHAPE FILL: ${element.name} ${element.color}");
    }
    }
    }

    Future<void> modifyLottieColors() async {
    try {
    final String data =
    await rootBundle.loadString("assets/lottie/onbo_a.json");
    var lottieJson = json.decode(data);

    modifyColorsRecursive(lottieJson);

    // Log the modified JSON
    log("Modified Lottie JSON: $lottieJson");
    Uint8List uint8List =
    Uint8List.fromList(utf8.encode(json.encode(lottieJson)));
    setState(() {
    lottiesss = uint8List;
    });
    } catch (e, st) {
    log("Error modifying Lottie colors: $e, $st");
    }
    }

    void modifyColorsRecursive(Map<String, dynamic> json) {
    List layers = json['layers'];
    for (var element in layers) {
    loopLayers(element);
    }
    }

    void loopLayers(Map layer) {
    List shapes = layer['shapes'] ?? [];
    for (var element in shapes) {
    loopShapes(element);
    }
    }

    void loopShapes(Map shape) {
    List shapes = shape['it'] ?? [];
    for (var element in shapes) {
    if (element['ty'] == "fl") {
    log("FILLLLLL $element");
    element['c'] = flutterColorToLottie(context.color.teritoryColor);
    } else if (element['ty'] == "gr") {
    loopShapes(element);
    } else if (element['ty'] == "st") {
    element['c'] = flutterColorToLottie(context.color.teritoryColor);
    }
    }
    }

    Map<String, dynamic> flutterColorToLottie(Color flutterColor) {
    double red = flutterColor.red / 255.0;
    double green = flutterColor.green / 255.0;
    double blue = flutterColor.blue / 255.0;
    double alpha = flutterColor.opacity;

    return {
    'a': 0,
    'k': [red, green, blue, alpha],
    'ix': 4,
    };
    }
 */
