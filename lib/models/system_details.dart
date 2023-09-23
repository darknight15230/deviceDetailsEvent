// ignore_for_file: file_names

import 'dart:convert';

class SystemDetails {
    int nivelBateria;
    String tipoSenal;
    String? intensidadSenal;
    String? email;
    String uuid;
    double latitud;
    double longitud;

    SystemDetails({
        required this.nivelBateria,
        required this.tipoSenal,
        this.intensidadSenal,
        this.email,
        required this.uuid,
        required this.latitud,
        required this.longitud,
    });

    factory SystemDetails.fromJson(String str) => SystemDetails.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory SystemDetails.fromMap(Map<String, dynamic> json) => SystemDetails(
        nivelBateria: json["nivelBateria"],
        tipoSenal: json["tipoSenal"],
        intensidadSenal: json["intensidadSenal"],
        email: json["email"],
        uuid: json["UUID"],
        latitud: json["latitud"]?.toDouble(),
        longitud: json["longitud"]?.toDouble(),
    );

    Map<String, dynamic> toMap() => {
        "nivelBateria": nivelBateria,
        "tipoSenal": tipoSenal,
        "intensidadSenal": intensidadSenal,
        "email": email,
        "UUID": uuid,
        "latitud": latitud,
        "longitud": longitud,
    };
}
