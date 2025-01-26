import 'package:flutter/material.dart';

// компоненти мазуту
class MazutComposition {
  final double carbonCombustible;
  final double hydrogenCombustible;
  final double oxygenCombustible;
  final double sulfurCombustible;
  final double vanadiumCombustible;
  final double moistureContent;
  final double ashDry;
  final double heatingValueCombustible;

  MazutComposition({
    this.carbonCombustible = 0.0,
    this.hydrogenCombustible = 0.0,
    this.oxygenCombustible = 0.0,
    this.sulfurCombustible = 0.0,
    this.vanadiumCombustible = 0.0,
    this.moistureContent = 0.0,
    this.ashDry = 0.0,
    this.heatingValueCombustible = 0.0,
  });

  MazutComposition copyWith({
    double? carbonCombustible,
    double? hydrogenCombustible,
    double? oxygenCombustible,
    double? sulfurCombustible,
    double? vanadiumCombustible,
    double? moistureContent,
    double? ashDry,
    double? heatingValueCombustible,
  }) {
    return MazutComposition(
      carbonCombustible: carbonCombustible ?? this.carbonCombustible,
      hydrogenCombustible: hydrogenCombustible ?? this.hydrogenCombustible,
      oxygenCombustible: oxygenCombustible ?? this.oxygenCombustible,
      sulfurCombustible: sulfurCombustible ?? this.sulfurCombustible,
      vanadiumCombustible: vanadiumCombustible ?? this.vanadiumCombustible,
      moistureContent: moistureContent ?? this.moistureContent,
      ashDry: ashDry ?? this.ashDry,
      heatingValueCombustible:
          heatingValueCombustible ?? this.heatingValueCombustible,
    );
  }
}

// результати розрахунків
class MazutResults {
  final Map<String, double> workingComposition;
  final double workingHeatingValue;

  MazutResults({
    this.workingComposition = const {},
    this.workingHeatingValue = 0.0,
  });
}

class Calculator2Screen extends StatefulWidget {
  const Calculator2Screen({
    super.key,
  });

  @override
  State<Calculator2Screen> createState() => _Calculator2ScreenState();
}

class _Calculator2ScreenState extends State<Calculator2Screen> {
  MazutComposition composition = MazutComposition();
  MazutResults? results;

  void updateComposition(String field, double value) {
    setState(() {
      switch (field) {
        case 'carbonCombustible':
          composition = composition.copyWith(carbonCombustible: value);
        case 'hydrogenCombustible':
          composition = composition.copyWith(hydrogenCombustible: value);
        case 'oxygenCombustible':
          composition = composition.copyWith(oxygenCombustible: value);
        case 'sulfurCombustible':
          composition = composition.copyWith(sulfurCombustible: value);
        case 'vanadiumCombustible':
          composition = composition.copyWith(vanadiumCombustible: value);
        case 'moistureContent':
          composition = composition.copyWith(moistureContent: value);
        case 'ashDry':
          composition = composition.copyWith(ashDry: value);
        case 'heatingValueCombustible':
          composition = composition.copyWith(heatingValueCombustible: value);
      }
    });
  }

  MazutResults calculateMazutResults(MazutComposition composition) {
    // формула перерахунку складу палива
    final conversionFactor =
        (100.0 - composition.moistureContent - composition.ashDry) / 100.0;

    // перерахунок для кожного компонента
    final workingComposition = {
      'C^P': composition.carbonCombustible * conversionFactor,
      'H^P': composition.hydrogenCombustible * conversionFactor,
      'O^P': composition.oxygenCombustible * conversionFactor,
      'S^P': composition.sulfurCombustible * conversionFactor,
      // віднімання - отримання маси без вологи (суха маса)
      // оскільки ванадій вказується відносно маси без вологи
      // ділення - отримання відсотку
      'V^P': composition.vanadiumCombustible *
          (100.0 - composition.moistureContent) /
          100.0,
      // віднімання - отримання відсотка маси без вологи
      // оскільки зола вказується відносно маси без вологи
      // ділення - отримання відсотку
      'A^P': composition.ashDry * (100.0 - composition.moistureContent) / 100.0,
    };

    // розрахунок нижчої теплоти згорання
    final workingHeatingValue = composition.heatingValueCombustible *
            (100.0 - composition.moistureContent - composition.ashDry) /
            100.0 -
        0.025 * composition.moistureContent;

    return MazutResults(
      workingComposition: workingComposition,
      workingHeatingValue: workingHeatingValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Калькулятор складу мазуту',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Склад горючої маси',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      InputField(
                        label: 'Вуглець (C^Г), %',
                        value: composition.carbonCombustible,
                        onChanged: (value) =>
                            updateComposition('carbonCombustible', value),
                      ),
                      InputField(
                        label: 'Водень (H^Г), %',
                        value: composition.hydrogenCombustible,
                        onChanged: (value) =>
                            updateComposition('hydrogenCombustible', value),
                      ),
                      InputField(
                        label: 'Кисень (O^Г), %',
                        value: composition.oxygenCombustible,
                        onChanged: (value) =>
                            updateComposition('oxygenCombustible', value),
                      ),
                      InputField(
                        label: 'Сірка (S^Г), %',
                        value: composition.sulfurCombustible,
                        onChanged: (value) =>
                            updateComposition('sulfurCombustible', value),
                      ),
                      InputField(
                        label: 'Ванадій (V^Г), мг/кг',
                        value: composition.vanadiumCombustible,
                        onChanged: (value) =>
                            updateComposition('vanadiumCombustible', value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Додаткові параметри',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      InputField(
                        label: 'Вологість, %',
                        value: composition.moistureContent,
                        onChanged: (value) =>
                            updateComposition('moistureContent', value),
                      ),
                      InputField(
                        label: 'Зольність, %',
                        value: composition.ashDry,
                        onChanged: (value) =>
                            updateComposition('ashDry', value),
                      ),
                      InputField(
                        label: 'Нижча теплота згоряння, МДж/кг',
                        value: composition.heatingValueCombustible,
                        onChanged: (value) =>
                            updateComposition('heatingValueCombustible', value),
                      ),
                    ],
                  ),
                ),
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
                      results = calculateMazutResults(composition);
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
              if (results != null) DisplayMazutResults(results: results!),
            ],
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
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value == 0.0 ? '' : widget.value.toString();
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
          widget.onChanged(double.tryParse(value) ?? 0.0);
        },
      ),
    );
  }
}

class DisplayMazutResults extends StatelessWidget {
  final MazutResults results;

  const DisplayMazutResults({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Результати розрахунків',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Склад робочої маси:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            ...results.workingComposition.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text(
                        entry.key.contains('V')
                            ? '${entry.value.toStringAsFixed(2)} мг/кг'
                            : '${entry.value.toStringAsFixed(2)}%',
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Text(
              'Нижча теплота згоряння робочої маси:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text('${results.workingHeatingValue.toStringAsFixed(2)} МДж/кг'),
          ],
        ),
      ),
    );
  }
}
