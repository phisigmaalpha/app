import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ATHMovilService {
  static const String _baseUrl =
      'https://payments.athmovil.com/api/business-transaction/ecommerce';

  // TODO: Reemplaza con tu publicToken de ATH Business (Settings > Development)
  static const String publicToken = 'TU_PUBLIC_TOKEN_AQUI';

  /// Crea un pago y retorna {ecommerceId, authToken}
  Future<Map<String, String>> createPayment({
    required double total,
    required String phoneNumber,
    String? metadata1,
    String? metadata2,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payment'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'env': 'production',
        'publicToken': publicToken,
        'timeout': 600,
        'total': total,
        'subtotal': total,
        'tax': 0.0,
        'metadata1': metadata1 ?? 'SIGMA Membership',
        'metadata2': metadata2 ?? 'Annual Subscription',
        'items': [
          {
            'name': 'Membresía SIGMA',
            'description': 'Suscripción anual Phi Sigma Alpha',
            'quantity': 1,
            'price': total,
            'tax': 0.0,
            'metadata': 'membership',
          }
        ],
        'phoneNumber': phoneNumber.replaceAll(RegExp(r'[^0-9]'), ''),
      }),
    );

    if (response.statusCode != 200) {
      debugPrint('ATH Movil create payment error: ${response.body}');
      throw Exception('Error al crear el pago');
    }

    final data = jsonDecode(response.body);
    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Error al crear el pago');
    }

    return {
      'ecommerceId': data['data']['ecommerceId'] as String,
      'authToken': data['data']['auth_token'] as String,
    };
  }

  /// Consulta el estado del pago. Retorna: OPEN, CONFIRM, COMPLETED, CANCEL
  Future<String> findPayment({
    required String ecommerceId,
    required String authToken,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/business/findPayment'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'ecommerceId': ecommerceId,
        'publicToken': publicToken,
      }),
    );

    if (response.statusCode != 200) {
      debugPrint('ATH Movil find payment error: ${response.body}');
      throw Exception('Error al consultar el pago');
    }

    final data = jsonDecode(response.body);
    return data['data']?['ecommerceStatus'] as String? ?? 'OPEN';
  }

  /// Autoriza el pago (después de que el cliente confirma en ATH Movil)
  Future<Map<String, dynamic>> authorizePayment({
    required String authToken,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/authorization'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode != 200) {
      debugPrint('ATH Movil authorize error: ${response.body}');
      throw Exception('Error al autorizar el pago');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Flujo completo: crea pago, espera confirmación, autoriza.
  /// Llama [onStatusChange] con cada cambio de estado.
  Future<bool> processPayment({
    required double total,
    required String phoneNumber,
    required Function(String status) onStatusChange,
  }) async {
    // 1. Crear pago
    onStatusChange('CREATING');
    final payment = await createPayment(
      total: total,
      phoneNumber: phoneNumber,
    );

    final ecommerceId = payment['ecommerceId']!;
    final authToken = payment['authToken']!;

    // 2. Esperar confirmación del cliente (poll cada 3 segundos, max 10 minutos)
    onStatusChange('OPEN');
    String status = 'OPEN';
    final maxAttempts = 200; // 200 * 3s = 10 min
    int attempts = 0;

    while (status == 'OPEN' && attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 3));
      attempts++;
      status = await findPayment(
        ecommerceId: ecommerceId,
        authToken: authToken,
      );
      onStatusChange(status);
    }

    if (status == 'CANCEL') {
      return false;
    }

    // 3. Autorizar pago
    if (status == 'CONFIRM') {
      onStatusChange('AUTHORIZING');
      await authorizePayment(authToken: authToken);
      onStatusChange('COMPLETED');
      return true;
    }

    return false;
  }
}
