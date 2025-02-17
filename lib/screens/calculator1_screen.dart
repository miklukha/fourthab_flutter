import 'package:flutter/material.dart';
import 'dart:math';

// дані систем
class SystemData {
  final double current;
  final double switchOffCurrentTime;
  final double sm;

  SystemData({
    this.current = 0.0,
    this.switchOffCurrentTime = 0.0,
    this.sm = 0.0,
  });

  SystemData copyWith({
    double? current,
    double? switchOffCurrentTime,
    double? sm,
  }) {
    return SystemData(
      current: current ?? this.current,
      switchOffCurrentTime: switchOffCurrentTime ?? this.switchOffCurrentTime,
      sm: sm ?? this.sm,
    );
  }
}

// результати розрахунків
class CalculationResults {
  final double section;
  final double increaseMinimum;

  CalculationResults({
    this.section = 0.0,
    this.increaseMinimum = 0.0,
  });
}

class Calculator1Screen extends StatefulWidget {
  const Calculator1Screen({super.key});

  @override
  State<Calculator1Screen> createState() => _Calculator1ScreenState();
}

class _Calculator1ScreenState extends State<Calculator1Screen> {
  SystemData data = SystemData();
  CalculationResults? results;

  void updateData(String field, double value) {
    setState(() {
      switch (field) {
        case 'current':
          data = data.copyWith(current: value);
        case 'switchOffCurrentTime':
          data = data.copyWith(switchOffCurrentTime: value);
        case 'sm':
          data = data.copyWith(sm: value);
      }
    });
  }

  CalculationResults calculateResults(SystemData data) {
    // напруга
    const voltage = 10;
    // економічна густина струму для кабелів з паперовою ізоляцією для Тм = 4000год
    const density = 1.4;
    // для кабелів з алюмінієвими суцільними жилами,
    // паперовою ізоляцією і номінальною напругою 6 кВ
    const ct = 92.0;

    // розрахунковий струм для нормального режиму
    final ratedCurrentNormal = (data.sm / 2) / (sqrt(3.0) * voltage);

    // розрахунковий струм для післяаварійного режиму
    // ignore: unused_local_variable
    final ratedCurrentAfterEmergency = 2 * ratedCurrentNormal;

    // економічний переріз
    final section = ratedCurrentNormal / density;

    // мінімум збільшення перерізу жил кабелю
    final increaseMinimum =
        data.current * 1000 * sqrt(data.switchOffCurrentTime) / ct;

    return CalculationResults(
      section: section,
      increaseMinimum: increaseMinimum,
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
                  'Калькулятор для розрахунку струму',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Вибрати кабелі для живлення двотрансформаторної підстанції системи внутрішнього елкетропостачання підприємства напругою 10 кВ. Струм К3 Ік = 2.5 кА, фіктиіний час вимикання струму КЗ tф = 2.5с. Потужність ТП - 2х1000 кВ А. Розрахункове навантаження Sм = 1300 кВ А, Тм = 4000 год.',
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),
                InputField(
                  label: 'Струм КЗ, кА',
                  value: data.current,
                  onChanged: (value) => updateData('current', value),
                ),
                InputField(
                  label: 'Фіктивний час вимикання струму КЗ, с',
                  value: data.switchOffCurrentTime,
                  onChanged: (value) =>
                      updateData('switchOffCurrentTime', value),
                ),
                InputField(
                  label: 'Sm, кВ',
                  value: data.sm,
                  onChanged: (value) => updateData('sm', value),
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
          title: 'Результати:',
          items: {
            'Економічний переріз': ResultValue(results.section, 'мм2'),
            'Переріз має бути збільшений мінімум до':
                ResultValue(results.increaseMinimum, 'мм2'),
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
