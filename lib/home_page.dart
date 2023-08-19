import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'box_calculator.dart';
import 'box_dimensions.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController weightController =
      TextEditingController(); // Nuevo

  BoxCalculator boxCalculator = BoxCalculator();
  int smallBoxCapacity = 0;
  int mediumBoxCapacity = 0;
  int largeBoxCapacity = 0;

  double weightPerSheet = 0; // Nuevo
  double totalWeightSmallBox = 0; // Nuevo
  double totalWeightMediumBox = 0; // Nuevo
  double totalWeightLargeBox = 0; // Nuevo

  bool _isKeyboardVisible = false; // Adicione esta linha
  bool _showResults = false; // Adicione esta linha

  void resetValues() {
    setState(() {
      heightController.clear();
      lengthController.clear();
      widthController.clear();
      weightController.clear();

      smallBoxCapacity = 0;
      mediumBoxCapacity = 0;
      largeBoxCapacity = 0;
      weightPerSheet = 0;
      totalWeightSmallBox = 0;
      totalWeightMediumBox = 0;
      totalWeightLargeBox = 0;
      _showResults = false;
    });
  }

  void calculateCapacityAndWeight() {
    double? height = double.tryParse(heightController.text);
    double? length = double.tryParse(lengthController.text);
    double? width = double.tryParse(widthController.text);
    double? weight = double.tryParse(weightController.text); // Nuevo

    if (height == null || length == null || width == null || weight == null) {
      Fluttertoast.showToast(msg: "Por favor, introduce números válidos");
      return;
    }

    BoxDimensions package =
        BoxDimensions(height: height, length: length, width: width);

    // Calculando capacidad
    try {
      setState(() {
        smallBoxCapacity = boxCalculator.calculatePackageCapacity(
            package, boxCalculator.smallBox);
        mediumBoxCapacity = boxCalculator.calculatePackageCapacity(
            package, boxCalculator.mediumBox);
        largeBoxCapacity = boxCalculator.calculatePackageCapacity(
            package, boxCalculator.largeBox);

        // Calculando pesos
        weightPerSheet = weight / 100;
        totalWeightSmallBox = weight * smallBoxCapacity;
        totalWeightMediumBox = weight * mediumBoxCapacity;
        totalWeightLargeBox = weight * largeBoxCapacity;

        _showResults = true;
      });
    } catch (error) {
      Fluttertoast.showToast(msg: "Aconteceu um erro ao calcular: $error");
    }

    // Fechar o teclado
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    _isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de Pacotes'),
        actions: <Widget>[
          IconButton(
            color: Colors.blue,
            icon: Icon(Icons.refresh),
            onPressed: resetValues,
            tooltip: 'Resetar valores',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            ListView(
              children: [
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Altura (mm)'),
                ),
                TextField(
                  controller: lengthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Largura (mm)'),
                ),
                TextField(
                  controller: widthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Comprimento (mm)'),
                ),
                // ... Todos los TextFields previos
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'Peso del pacote de 100 peças (kg)'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: calculateCapacityAndWeight,
                  child: Text('Calcular'),
                ),
                SizedBox(height: 16),
                if (_showResults) ...[
                  // Verifique a variável aqui
                  SheetWeightResult(weight: weightPerSheet),
                  TextResult(
                    boxType: "pequena",
                    capacity: smallBoxCapacity,
                    weight: totalWeightSmallBox,
                  ),
                  TextResult(
                    boxType: "media",
                    capacity: mediumBoxCapacity,
                    weight: totalWeightMediumBox,
                  ),
                  TextResult(
                    boxType: "grande",
                    capacity: largeBoxCapacity,
                    weight: totalWeightLargeBox,
                  ),
                ],
              ],
            ),
            Visibility(
              visible: !_isKeyboardVisible,
              child: Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.blue.withOpacity(0.0),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: const Center(
                    child: Text(
                      'Desenvolvido por SCSIT e Jesse Condori. v1.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextResult extends StatelessWidget {
  final String boxType;
  final int capacity;
  final double weight; // Nuevo

  TextResult(
      {required this.boxType, required this.capacity, required this.weight});

  @override
  Widget build(BuildContext context) {
    String message = capacity > 0
        ? 'Caixa $boxType: ${capacity * 100} unidades .\n Peso total: ${weight.toStringAsFixed(2)} kg'
        : 'O pacote não tem capaciade na caixa $boxType';

    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          message,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class SheetWeightResult extends StatelessWidget {
  final double weight;

  SheetWeightResult({required this.weight});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "Peso de uma peça: ${weight.toStringAsFixed(4)} kg",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
