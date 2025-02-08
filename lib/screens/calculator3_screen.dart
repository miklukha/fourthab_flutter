import 'package:flutter/material.dart';
import 'dart:math';

// вхідні дані
class Data {
  final double power;
  final double electricity;
  final double deviation1;
  final double deviation2;

  Data({
    this.power = 0.0,
    this.electricity = 0.0,
    this.deviation1 = 0.0,
    this.deviation2 = 0.0,
  });

  Data copyWith({
    double? power,
    double? electricity,
    double? deviation1,
    double? deviation2,
  }) {
    return Data(
      power: power ?? this.power,
      electricity: electricity ?? this.electricity,
      deviation1: deviation1 ?? this.deviation1,
      deviation2: deviation2 ?? this.deviation2,
    );
  }
}

// результати розрахунків
class CalculationResults {
  final double profitBefore;
  final double profitAfter;

  CalculationResults({
    this.profitBefore = 0.0,
    this.profitAfter = 0.0,
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
        case 'power':
          data = data.copyWith(power: value);
        case 'electricity':
          data = data.copyWith(electricity: value);
        case 'deviation1':
          data = data.copyWith(deviation1: value);
        case 'deviation2':
          data = data.copyWith(deviation2: value);
      }
    });
  }

  // функція нормального закону розподілу потужності (формула 9.1)
  double normalDistribution(double x, double power, double sigma) {
    return (1 / (sigma * sqrt(2 * pi))) *
        exp(-(pow(x - power, 2)) / (2 * pow(sigma, 2)));
  }

  // інтегрування
  double integrate(
    double a, // нижня межа
    double b, // верхня межа
    int n, // кількість точок для інтегрування
    double power,
    double sigma,
  ) {
    final h = (b - a) / n;
    var sum = (normalDistribution(a, power, sigma) +
            normalDistribution(b, power, sigma)) /
        2;

    for (var i = 1; i < n; i++) {
      final x = a + i * h;
      sum += normalDistribution(x, power, sigma);
    }

    return h * sum;
  }

  double calculateEnergyWithoutImbalance(
    double power,
    double sigma,
    double lowerBound,
    double upperBound,
  ) {
    return integrate(
          lowerBound,
          upperBound,
          100000,
          power,
          sigma,
        ) *
        100; // переводимо у відсотки
  }

  CalculationResults calculateResults(Data data) {
    // діапазони
    const lowerBound = 4.75;
    const upperBound = 5.25;

    // розрахунок частки енергії без небалансів до покращення (δW1)
    final energyWithoutImbalance1 = calculateEnergyWithoutImbalance(
      data.power,
      data.deviation1,
      lowerBound,
      upperBound,
    ).round().toDouble();

    // розрахунок частки енергії без небалансів після покращення (δW2)
    final energyWithoutImbalance2 = calculateEnergyWithoutImbalance(
      data.power,
      data.deviation2,
      lowerBound,
      upperBound,
    ).round().toDouble();

    // енергія W1
    final energy1 = data.power * 24 * energyWithoutImbalance1 / 100;

    // прибуток П1
    final profit1 = energy1 * data.electricity;

    // енергія W2
    final energy2 = data.power * 24 * (1 - energyWithoutImbalance1 / 100);

    // штраф Ш1
    final fine1 = energy2 * data.electricity;

    // загальний прибуток перед покращенням
    final profitBefore = profit1 - fine1;

    // енергія W3
    final energy3 = data.power * 24 * energyWithoutImbalance2 / 100;

    // прибуток П2
    final profit2 = energy3 * data.electricity;

    // енергія W4
    final energy4 = data.power * 24 * (1 - energyWithoutImbalance2 / 100);

    // штраф Ш2
    final fine2 = energy4 * data.electricity;

    // загальний прибуток після покращення
    final profitAfter = profit2 - fine2;

    return CalculationResults(
      profitBefore: profitBefore,
      profitAfter: profitAfter,
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
                  'Калькулятор прибутку від сонячних електростанцій',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                InputField(
                  label: 'Середньодобова потужність, МВт',
                  value: data.power,
                  onChanged: (value) => updateData('power', value),
                ),
                InputField(
                  label: 'Середньоквадратичне відхилення, МВт',
                  value: data.deviation1,
                  onChanged: (value) => updateData('deviation1', value),
                ),
                InputField(
                  label: 'Середньоквадратичне відхилення 2, МВт',
                  value: data.deviation2,
                  onChanged: (value) => updateData('deviation2', value),
                ),
                InputField(
                  label: 'Вартість електроенергії, МВт',
                  value: data.electricity,
                  onChanged: (value) => updateData('electricity', value),
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
        const SizedBox(height: 8),
        ResultSection(
          title: 'Прибутки:',
          items: {
            'до вдосконалення': ResultValue(results.profitBefore, 'тис.грн'),
            'після вдосконалення': ResultValue(results.profitAfter, 'тис.грн'),
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
                  Text(entry.value.unit != null
                      ? '${entry.value.value.toStringAsFixed(2)} ${entry.value.unit}'
                      : entry.value.value.toStringAsFixed(2)),
                ],
              ),
            )),
      ],
    );
  }
}
