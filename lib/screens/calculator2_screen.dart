// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'dart:math';

// вхідні дані
class Data {
  final int power;

  Data({
    this.power = 0,
  });

  Data copyWith({
    int? power,
  }) {
    return Data(
      power: power ?? this.power,
    );
  }
}

// результати розрахунків
class CalculationResults {
  final double initialCurrentValue;

  CalculationResults({
    this.initialCurrentValue = 0.0,
  });
}

class Calculator2Screen extends StatefulWidget {
  const Calculator2Screen({super.key});

  @override
  State<Calculator2Screen> createState() => _Calculator2ScreenState();
}

class _Calculator2ScreenState extends State<Calculator2Screen> {
  Data data = Data();
  CalculationResults? results;

  void updateData(String field, int value) {
    setState(() {
      switch (field) {
        case 'power':
          data = data.copyWith(power: value);
      }
    });
  }

  CalculationResults calculateResults(Data data) {
    // середня номінальна напруга точки, в якій виникає КЗ
    const usn = 10.5;
    // номінальна потужність трансформатора
    const snomt = 6.3;
    const uk = 10.5;

    // середній час відновлення трансформатора напругою 35 кВ
    const recoveryTimeT = 45 * 0.001;
    // середній час планового простою трансформатора напругою 35 кВ
    const averageTime = 4 * 0.001;
    const pm = 5.12 * 1000;
    const tm = 6451;

    // опори елементів заступної схеми
    final xc = pow(usn, 2) / data.power;
    final xt = (uk / 100) * (pow(usn, 2) / snomt);

    // сумарний опір для точки К1
    final totalResistance = xc + xt;

    // початкове діюче значення струму трифазного КЗ
    final initialCurrentValue = usn / (sqrt(3.0) * totalResistance);

    return CalculationResults(
      initialCurrentValue: initialCurrentValue,
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
                  'Калькулятор визначення струмів КЗ на шинах 10 кВ ГПП',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Визначити струми К3 на шинах 10 кВ ГПП. Потужність К3 200 МВ А. Для перевірки вибраних кабелів та вимикачів необіхдно розрахувати струми К3 на шинах низької напруги ГПП',
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),
                InputField(
                  label: 'Потужність КЗ',
                  value: data.power,
                  onChanged: (value) => updateData('power', value),
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
  final int value;
  final Function(int) onChanged;

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
      text: widget.value == 0 ? '' : widget.value.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final selection = _controller.selection;
      _controller.text = widget.value == 0 ? '' : widget.value.toString();
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
        keyboardType: TextInputType.number,
        onChanged: (value) {
          if (value.isEmpty) {
            widget.onChanged(0);
            return;
          }
          final number = int.tryParse(value);
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
        const SizedBox(height: 8),
        ResultSection(
          title: 'Результати:',
          items: {
            'Початкове діюче значення\nструму трифазного КЗ':
                ResultValue(results.initialCurrentValue, 'кА'),
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
