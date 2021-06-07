// To parse this JSON data, do
//
//     final ocrModel = ocrModelFromJson(jsonString);

import 'dart:convert';

OcrModel ocrModelFromJson(String str) => OcrModel.fromJson(json.decode(str));

String ocrModelToJson(OcrModel data) => json.encode(data.toJson());

class OcrModel {
    OcrModel({
        this.code,
        this.text,
        this.blocks,
    });

    int code;
    String text;
    int blocks;

    factory OcrModel.fromJson(Map<String, dynamic> json) => OcrModel(
        code: json["code"],
        text: json["text"],
        blocks: json["blocks"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "text": text,
        "blocks": blocks,
    };
}
