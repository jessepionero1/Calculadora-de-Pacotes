import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
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

  final TextEditingController resultController = TextEditingController();

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

  String formatNumber(int number) {
    return NumberFormat("#,##0", "es_ES").format(number);
  }

  String formatWeight(double weight, [int decimalPlaces = 4]) {
    String pattern = "#,##0." + "0" * decimalPlaces;
    return NumberFormat(pattern, "es_ES").format(weight);
  }

  void calculateCapacityAndWeight() {
    // Intenta convertir los valores de los campos de texto a números decimales
    double? height = double.tryParse(heightController.text);
    double? length = double.tryParse(lengthController.text);
    double? width = double.tryParse(widthController.text);
    double? weight = double.tryParse(weightController.text);

    // Si alguno de los valores no es válido, muestra un mensaje de error y retorna
    if (height == null || length == null || width == null || weight == null) {
      Fluttertoast.showToast(msg: "Por favor, introduce números válidos");
      return;
    }

    void formatResults() {
      String smallBoxText = smallBoxCapacity > 0
          ? "${formatNumber(smallBoxCapacity * 100)} unidades por caixa"
          : "[Não tem capacidade] por caixa";

      String mediumBoxText = mediumBoxCapacity > 0
          ? "${formatNumber(mediumBoxCapacity * 100)} unidades por caixa"
          : "[Não tem capacidade] por caixa";

      String largeBoxText = largeBoxCapacity > 0
          ? "${formatNumber(largeBoxCapacity * 100)} unidades por caixa"
          : "[Não tem capacidade] por caixa";

      String smallBoxWeight = smallBoxCapacity > 0
          ? "${formatWeight(totalWeightSmallBox, 2)} kg"
          : "[0,00] kg";

      String mediumBoxWeight = mediumBoxCapacity > 0
          ? "${formatWeight(totalWeightMediumBox, 2)} kg"
          : "[0,00] kg";

      String largeBoxWeight = largeBoxCapacity > 0
          ? "${formatWeight(totalWeightLargeBox, 2)} kg"
          : "[0,00] kg";

      String formattedText = '''
Padrão de Observações - Detalhes do Produto
Detalhes de Peso:
- Peso por Unidade: ${formatWeight(weightPerSheet)} kg
- Peso por Pacote (100 unidades): ${formatWeight(weight, 3)} kg

Capacidade de Caixas:
- Caixas Pequenas: $smallBoxText
- Caixas Médias: $mediumBoxText
- Caixas Grandes: $largeBoxText

Detalhes de Peso das Caixas:
- Peso da Caixa Pequena: $smallBoxWeight
- Peso da Caixa Média: $mediumBoxWeight
- Peso da Caixa Grande: $largeBoxWeight
  ''';

      resultController.text = formattedText;
    }

    // Crea un paquete con las dimensiones ingresadas
    BoxDimensions package =
        BoxDimensions(height: height, length: length, width: width);

    // Establecemos el peso maximo de los 3 tipos de caja
    const double SMALL_BOX_WEIGHT_LIMIT = 4.1;
    const double MEDIUM_BOX_WEIGHT_LIMIT = 15.1;
    const double LARGE_BOX_WEIGHT_LIMIT = 25.1;

    try {
      setState(() {
        // Calcula la capacidad de paquetes para cada tipo de caja
        smallBoxCapacity = boxCalculator.calculatePackageCapacity(
            package, boxCalculator.smallBox);
        mediumBoxCapacity = boxCalculator.calculatePackageCapacity(
            package, boxCalculator.mediumBox);
        largeBoxCapacity = boxCalculator.calculatePackageCapacity(
            package, boxCalculator.largeBox);

        // Calcula el peso por hoja
        weightPerSheet = weight / 100;

        // Calcula el peso total para cada tipo de caja
        totalWeightSmallBox = weight * smallBoxCapacity;
        totalWeightMediumBox = weight * mediumBoxCapacity;
        totalWeightLargeBox = weight * largeBoxCapacity;

// Después de calcular la cantidad de paquetes basado en dimensiones, realizamos otra
// validación para garantizar que el peso total no exceda el límite de cada caja.
// Si el peso total excede el límite, ajustamos la cantidad de paquetes
// para que el peso total sea menor que el peso límite de la caja.
// Asegura que el peso total no exceda el límite de cada caja
        // Asegura que el peso total no exceda el límite de cada caja
        // Si se excede, ajusta la capacidad de la caja y recalcula el peso total
        // la funcion floor() redondea al numero entero abajo example  4.7 resultado 4
        if (totalWeightSmallBox > SMALL_BOX_WEIGHT_LIMIT) {
          smallBoxCapacity = (SMALL_BOX_WEIGHT_LIMIT / weight).floor();
          totalWeightSmallBox = weight * smallBoxCapacity;
        }

        if (totalWeightMediumBox > MEDIUM_BOX_WEIGHT_LIMIT) {
          mediumBoxCapacity = (MEDIUM_BOX_WEIGHT_LIMIT / weight).floor();
          totalWeightMediumBox = weight * mediumBoxCapacity;
        }

        if (totalWeightLargeBox > LARGE_BOX_WEIGHT_LIMIT) {
          largeBoxCapacity = (LARGE_BOX_WEIGHT_LIMIT / weight).floor();
          totalWeightLargeBox = weight * largeBoxCapacity;
        }

        _showResults = true;
      });
    } catch (error) {
      Fluttertoast.showToast(msg: "Aconteció un error al calcular: $error");
    }

    formatResults();
    // Cierra el teclado virtual
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
                      labelText: 'Peso do pacote de 100 peças (kg)'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: calculateCapacityAndWeight,
                  child: Text('Calcular'),
                ),
                SizedBox(height: 16),

                if (_showResults) ...[
                  // Verifique a variável aqui
                  TextField(
                    controller: resultController,
                    maxLines: 15, // Puedes ajustar este valor según necesites
                    readOnly: true,
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: resultController.text));
                    },
                    decoration: InputDecoration(
                      labelText: 'Resultados',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.copy),
                    ),
                  ),
                ],
                Visibility(
                  visible: !_isKeyboardVisible,
                  child: Container(
                    color: Colors.blue.withOpacity(0.0),
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: const Center(
                      child: Text(
                        'Desenvolvido por SCSIT | Jesse Condori. v3.0',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
