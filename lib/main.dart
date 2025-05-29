import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(TempConverterApp());
}

class TempConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: TempConverterHome(),
    );
  }
}

enum ConversionType { fToC, cToF, toKelvin }

class TempConverterHome extends StatefulWidget {
  @override
  _TempConverterHomeState createState() => _TempConverterHomeState();
}

class _TempConverterHomeState extends State<TempConverterHome> {
  final TextEditingController _inputController = TextEditingController();
  ConversionType _selectedConversion = ConversionType.fToC;
  String _result = '';
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('history') ?? [];
    });
  }

  Future<void> _saveHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('history', _history);
  }

  void _convertTemperature() {
    final inputText = _inputController.text;
    if (inputText.isEmpty) return;

    final inputValue = double.tryParse(inputText);
    if (inputValue == null) {
      setState(() {
        _result = '⚠️ Invalid input! Please enter a number.';
      });
      return;
    }

    double convertedValue;
    String conversionLabel;

    switch (_selectedConversion) {
      case ConversionType.fToC:
        convertedValue = (inputValue - 32) * 5 / 9;
        conversionLabel = 'F → C';
        break;
      case ConversionType.cToF:
        convertedValue = inputValue * 9 / 5 + 32;
        conversionLabel = 'C → F';
        break;
      case ConversionType.toKelvin:
        convertedValue = inputValue + 273.15;
        conversionLabel = '°C → K';
        break;
    }

    String formattedResult = convertedValue.toStringAsFixed(2);

    setState(() {
      _result = '✅ $inputValue° → $formattedResult°';
      _history.insert(0, '$conversionLabel: $inputValue° → $formattedResult°');
      _saveHistory();
    });
  }

  void _clearHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _history.clear();
    });
    prefs.remove('history');
  }

  @override
  Widget build(BuildContext context) {
    final isInputValid = double.tryParse(_inputController.text) != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('🌡️ Temperature Converter'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearHistory,
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Orientation: ${orientation == Orientation.portrait ? 'Portrait' : 'Landscape'}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 10),

                TextField(
                  controller: _inputController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter temperature',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.thermostat),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 20),

                Card(
                  elevation: 3,
                  child: Column(
                    children: [
                      RadioListTile(
                        title: Text('Fahrenheit to Celsius (°F → °C)'),
                        value: ConversionType.fToC,
                        groupValue: _selectedConversion,
                        onChanged: (value) {
                          setState(() {
                            _selectedConversion = value!;
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Celsius to Fahrenheit (°C → °F)'),
                        value: ConversionType.cToF,
                        groupValue: _selectedConversion,
                        onChanged: (value) {
                          setState(() {
                            _selectedConversion = value!;
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Celsius to Kelvin (°C → K)'),
                        value: ConversionType.toKelvin,
                        groupValue: _selectedConversion,
                        onChanged: (value) {
                          setState(() {
                            _selectedConversion = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: isInputValid ? _convertTemperature : null,
                  icon: Icon(Icons.calculate),
                  label: Text('Convert'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                if (_result.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal, width: 1),
                    ),
                    child: Text(
                      _result,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                SizedBox(height: 20),

                Text(
                  'Conversion History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                if (_history.isEmpty)
                  Text('No conversions yet.')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(Icons.history),
                          title: Text(_history[index]),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

