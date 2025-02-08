import 'package:flutter/material.dart';
import 'dart:math';

// вхідні дані
class Data {
  final double rcn;
  final double xcn;
  final double rcmin;
  final double xcmin;

  Data({
    this.rcn = 0.0,
    this.xcn = 0.0,
    this.rcmin = 0.0,
    this.xcmin = 0.0,
  });

  Data copyWith({
    double? rcn,
    double? xcn,
    double? rcmin,
    double? xcmin,
  }) {
    return Data(
      rcn: rcn ?? this.rcn,
      xcn: xcn ?? this.xcn,
      rcmin: rcmin ?? this.rcmin,
      xcmin: xcmin ?? this.xcmin,
    );
  }
}

// результати розрахунків
class CalculationResults {
  final int iThreeNormal;
  final int iThreeMinimal;
  final int iTwoNormal;
  final int iTwoMinimal;
  final int iThreeNormalActual;
  final int iThreeMinimalActual;
  final int iTwoNormalActual;
  final int iTwoMinimalActual;
  final int iThreeNormal10;
  final int iThreeMinimal10;
  final int iTwoNormal10;
  final int iTwoMinimal10;

  CalculationResults({
    this.iThreeNormal = 0,
    this.iThreeMinimal = 0,
    this.iTwoNormal = 0,
    this.iTwoMinimal = 0,
    this.iThreeNormalActual = 0,
    this.iThreeMinimalActual = 0,
    this.iTwoNormalActual = 0,
    this.iTwoMinimalActual = 0,
    this.iThreeNormal10 = 0,
    this.iThreeMinimal10 = 0,
    this.iTwoNormal10 = 0,
    this.iTwoMinimal10 = 0,
  });
}

class Calculator3Screen extends StatefulWidget {
  const Calculator3Screen({super.key});

  @override
  State<Calculator3Screen> createState() => _Calculator3ScreenState();
}

class _Calculator3ScreenState extends State<Calculator3Screen> {
  Data data = Data();
  CalculationResults? results;

  void updateData(String field, double value) {
    setState(() {
      switch (field) {
        case 'rcn':
          data = data.copyWith(rcn: value);
        case 'xcn':
          data = data.copyWith(xcn: value);
        case 'rcmin':
          data = data.copyWith(rcmin: value);
        case 'xcmin':
          data = data.copyWith(xcmin: value);
      }
    });
  }

  CalculationResults calculateResults(Data data) {
    final ukmax = 11.1;
    final uvn = 115;
    final unn = 11;
    final r0 = 0.64;
    final x0 = 0.363;
    // номінальна потужність трансформатора
    final snomt = 6.3;

    // реактивний опір (реактанс) ТМН 6300/110
    final xt = ((ukmax * pow(uvn, 2)) / (100 * snomt)).round();

    // опори на шинах 10 кВ в нормальному та мінімальному режимах,
    // що приведені до напруги 110 кВ
    final rTire = data.rcn;
    final xTire = data.xcn + xt;
    final zTire =
        double.parse((sqrt(pow(rTire, 2) + pow(xTire, 2))).toStringAsFixed(1));
    final rTireMinimal = data.rcmin;
    final xTireMinimal = data.xcmin + xt;
    final zTireMinimal = double.parse(
        (sqrt(pow(rTireMinimal, 2) + pow(xTireMinimal, 2))).toStringAsFixed(1));

    // Струми трифазного КЗ на шинах 10 кВ, приведені до напруги 110 кВ
    // (нормальний режим)
    final iThreeNormal = (uvn * 1000 / (1.73 * zTire)).round();
    // (мінімальний режим)
    final iThreeMinimal = (uvn * 1000 / (1.73 * zTireMinimal)).round();

    // Струми двофазного КЗ на шинах 10 кВ, приведені до напруги 110 кВ
    // (нормальний режим)
    final iTwoNormal = (iThreeNormal * (1.73 / 2)).round();
    // (мінімальний режим)
    final iTwoMinimal = (iThreeMinimal * (1.73 / 2)).round();

    // коефіцієнт приведення для визначення дійсних струмів на шинах 10 кВ
    final kpr = double.parse((pow(unn, 2) / pow(uvn, 2)).toStringAsFixed(3));

    // опори на шинах 10 кВ в нормальному та мінімальному режимах
    final rTireN = double.parse((rTire * kpr).toStringAsFixed(1));
    final xTireN = double.parse((xTire * kpr).toStringAsFixed(2));
    final zTireN = double.parse(
        (sqrt(pow(rTireN, 2) + pow(xTireN, 2))).toStringAsFixed(2));
    final rTireNMinimal = double.parse((rTireMinimal * kpr).toStringAsFixed(2));
    final xTireNMinimal = double.parse((xTireMinimal * kpr).toStringAsFixed(2));
    final zTireNMinimal = double.parse(
        (sqrt(pow(rTireNMinimal, 2) + pow(xTireNMinimal, 2)))
            .toStringAsFixed(1));

    // Дійсні струми трифазного КЗ на шинах 10 кВ
    // (нормальний режим)
    final iThreeNormalActual = (unn * 1000 / (1.73 * zTireN)).round();
    // (мінімальний режим)
    final iThreeMinimalActual = (unn * 1000 / (1.73 * zTireNMinimal)).round();

    // Дійсні струми двофазного КЗ на шинах 10 кВ
    // (нормальний режим)
    final iTwoNormalActual = (iThreeNormalActual * (1.73 / 2)).round();
    // (мінімальний режим)
    final iTwoMinimalActual = (iThreeMinimalActual * (1.73 / 2)).round();

    // довжина лінії електропередач
    final il = 0.2 + 0.35 + 0.2 + 0.6 + 2 + 2.55 + 3.37 + 3.1;
    // резистанс лінії електропередач
    final rl = il * r0;
    // реактанс лінії електропередач
    final xl = il * x0;

    // опори в точці 10 в нормальному та мінімальному режимах
    final r10n = double.parse((rl + rTireN).toStringAsFixed(2));
    final x10n = double.parse((xl + xTireN).toStringAsFixed(2));
    final z10n =
        double.parse((sqrt(pow(r10n, 2) + pow(x10n, 2))).toStringAsFixed(2));
    final r10nMinimal = double.parse((rl + rTireNMinimal).toStringAsFixed(2));
    final x10nMinimal = double.parse((xl + xTireNMinimal).toStringAsFixed(1));
    final z10nMinimal = double.parse(
        (sqrt(pow(r10nMinimal, 2) + pow(x10nMinimal, 2))).toStringAsFixed(2));

    // Струми трифазного КЗ в точці 10
    // (нормальний режим)
    final iThreeNormal10 = (unn * 1000 / (1.73 * z10n)).round();
    // (мінімальний режим)
    final iThreeMinimal10 = (unn * 1000 / (1.73 * z10nMinimal)).round();

    // Струми двофазного КЗ в точці 10
    // (нормальний режим)
    final iTwoNormal10 = (iThreeNormal10 * (1.73 / 2)).round();
    // (мінімальний режим)
    final iTwoMinimal10 = (iThreeMinimal10 * (1.73 / 2)).round();

    return CalculationResults(
      iThreeNormal: iThreeNormal,
      iThreeMinimal: iThreeMinimal,
      iTwoNormal: iTwoNormal,
      iTwoMinimal: iTwoMinimal,
      iThreeNormalActual: iThreeNormalActual,
      iThreeMinimalActual: iThreeMinimalActual,
      iTwoNormalActual: iTwoNormalActual,
      iTwoMinimalActual: iTwoMinimalActual,
      iThreeNormal10: iThreeNormal10,
      iThreeMinimal10: iThreeMinimal10,
      iTwoNormal10: iTwoNormal10,
      iTwoMinimal10: iTwoMinimal10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Калькулятор визначення струмів для підстанції ХПнЕМ',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                InputField(
                  label: 'Rc.н, Ом',
                  value: data.rcn,
                  onChanged: (value) => updateData('rcn', value),
                ),
                InputField(
                  label: 'Хc.н, Ом',
                  value: data.xcn,
                  onChanged: (value) => updateData('xcn', value),
                ),
                InputField(
                  label: 'Rc.min, Ом',
                  value: data.rcmin,
                  onChanged: (value) => updateData('rcmin', value),
                ),
                InputField(
                  label: 'Хc.min, Ом',
                  value: data.xcmin,
                  onChanged: (value) => updateData('xcmin', value),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[400],
                    ),
                    onPressed: () {
                      setState(() {
                        results = calculateResults(data);
                      });
                    },
                    child: const Text(
                      'Розрахувати',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.purple[400]!),
                    ),
                    child: Text(
                      'Повернутися',
                      style: TextStyle(
                        color: Colors.purple[400],
                      ),
                    ),
                  ),
                ),
                if (results != null) ResultsDisplay(results: results!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InputField extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;

  const InputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == 0.0 ? '' : widget.value.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value &&
        !_controller.text.contains(RegExp(r'[.,]$'))) {
      final selection = _controller.selection;
      _controller.text = widget.value == 0.0 ? '' : widget.value.toString();
      _controller.selection = selection;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) {
          if (value.isEmpty) {
            widget.onChanged(0.0);
            return;
          }
          final normalizedValue = value.replaceAll(',', '.');
          final number = double.tryParse(normalizedValue);
          if (number != null) {
            widget.onChanged(number);
          }
        },
      ),
    );
  }
}

class ResultsDisplay extends StatelessWidget {
  final CalculationResults results;

  const ResultsDisplay({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Результати розрахунків:',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ResultSection(
          title:
              'Струми двофазного КЗ на шинах 10 кВ, приведені до напруги 110 кВ:',
          items: {
            'нормальний режим': ResultValue(results.iTwoNormal.toDouble(), 'A'),
            'мінімальний режим':
                ResultValue(results.iTwoMinimal.toDouble(), 'A'),
          },
        ),
        ResultSection(
          title:
              'Струми трифазного КЗ на шинах 10 кВ, приведені до напруги 110 кВ:',
          items: {
            'нормальний режим':
                ResultValue(results.iThreeNormal.toDouble(), 'A'),
            'мінімальний режим':
                ResultValue(results.iThreeMinimal.toDouble(), 'A'),
          },
        ),
        ResultSection(
          title: 'Дійсні струми двофазного КЗ на шинах 10 кВ:',
          items: {
            'нормальний режим':
                ResultValue(results.iTwoNormalActual.toDouble(), 'A'),
            'мінімальний режим':
                ResultValue(results.iTwoMinimalActual.toDouble(), 'A'),
          },
        ),
        ResultSection(
          title: 'Дійсні струми трифазного КЗ на шинах 10 кВ:',
          items: {
            'нормальний режим':
                ResultValue(results.iThreeNormalActual.toDouble(), 'A'),
            'мінімальний режим':
                ResultValue(results.iThreeMinimalActual.toDouble(), 'A'),
          },
        ),
        ResultSection(
          title: 'Струми двофазного КЗ в точці 10:',
          items: {
            'нормальний режим':
                ResultValue(results.iTwoNormal10.toDouble(), 'A'),
            'мінімальний режим':
                ResultValue(results.iTwoMinimal10.toDouble(), 'A'),
          },
        ),
        ResultSection(
          title: 'Струми двофазного КЗ в точці 10:',
          items: {
            'нормальний режим':
                ResultValue(results.iThreeNormal10.toDouble(), 'A'),
            'мінімальний режим':
                ResultValue(results.iThreeMinimal10.toDouble(), 'A'),
          },
        ),
      ],
    );
  }
}

class ResultValue {
  final double value;
  final String? unit;

  const ResultValue(this.value, [this.unit]);
}

class ResultSection extends StatelessWidget {
  final String title;
  final Map<String, ResultValue> items;

  const ResultSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        ...items.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text(
                    '${entry.value.value.toStringAsFixed(1)} ${entry.value.unit}',
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
