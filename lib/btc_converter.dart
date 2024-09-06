import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BtcConverter extends StatefulWidget {
  const BtcConverter({super.key});

  @override
  _BtcConverterState createState() => _BtcConverterState();
}

class _BtcConverterState extends State<BtcConverter> {
  double? _btcPrice;
  String _usdInput = "";
  String _btcEquivalent = "--";
  String _lastUpdated = "";
  bool _isLoading = true;

  // Fetch BTC price from CoinGecko API
  Future<void> _fetchBTCPrice() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd",
        ),
      );

      final data = jsonDecode(response.body);
      double btcPrice = data['bitcoin']['usd'];

      setState(() {
        _btcPrice = btcPrice;
        _lastUpdated = DateTime.now().toString();
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorToast("Failed to fetch data. Please try again.");
    }
  }

  // Show error toast
  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  // Handle USD input change
  void _handleUsdInput(String value) {
    if (value.isEmpty) {
      setState(() {
        _usdInput = "";
        _btcEquivalent = "--";
      });
      return;
    }

    double? usdValue = double.tryParse(value);
    if (usdValue == null || usdValue > 100000000) {
      _showErrorToast("The maximum allowed input is \$100,000,000.");
      return;
    }

    setState(() {
      _usdInput = value;
      _btcEquivalent = (usdValue / _btcPrice!).toStringAsFixed(8);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchBTCPrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BTC Converter'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Container(
                padding: const EdgeInsets.all(16.0),
                width: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bitcoin Price: \$${_btcPrice?.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last Updated: $_lastUpdated',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter USD amount',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _handleUsdInput,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'BTC Equivalent: $_btcEquivalent',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _fetchBTCPrice,
                      child: const Text('Refresh Price'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
