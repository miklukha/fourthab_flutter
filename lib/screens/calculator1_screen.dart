import 'package:flutter/material.dart';

// компоненти палива
class FuelComposition {
  final double hp;
  final double cp;
  final double sp;
  final double np;
  final double op;
  final double wp;
  final double ap;

  FuelComposition({
    this.hp = 0.0,
    this.cp = 0.0,
    this.sp = 0.0,
    this.np = 0.0,
    this.op = 0.0,
    this.wp = 0.0,
    this.ap = 0.0,
  });

  FuelComposition copyWith({
    double? hp,
    double? cp,
    double? sp,
    double? np,
    double? op,
    double? wp,
    double? ap,
  }) {
    return FuelComposition(
      hp: hp ?? this.hp,
      cp: cp ?? this.cp,
      sp: sp ?? this.sp,
      np: np ?? this.np,
      op: op ?? this.op,
      wp: wp ?? this.wp,
      ap: ap ?? this.ap,
    );
  }
}

// результати розрахунків
class CalculationResults {
  final double dryMassCoefficient;
  final double combustibleMassCoefficient;
  final Map<String, double> dryComposition;
  final Map<String, double> combustibleComposition;
  final double lowerHeatingValue;
  final double lowerDryHeatingValue;
  final double lowerCombustibleHeatingValue;

  CalculationResults({
    this.dryMassCoefficient = 0.0,
    this.combustibleMassCoefficient = 0.0,
    this.dryComposition = const {},
    this.combustibleComposition = const {},
    this.lowerHeatingValue = 0.0,
    this.lowerDryHeatingValue = 0.0,
    this.lowerCombustibleHeatingValue = 0.0,
  });
}

class Calculator1Screen extends StatefulWidget {
  const Calculator1Screen({super.key});

  @override
  State<Calculator1Screen> createState() => _Calculator1ScreenState();
}

class _Calculator1ScreenState extends State<Calculator1Screen> {
  FuelComposition composition = FuelComposition();
  CalculationResults? results;

  void updateComposition(String field, double value) {
    setState(() {
      switch (field) {
        case 'hp':
          composition = composition.copyWith(hp: value);
        case 'cp':
          composition = composition.copyWith(cp: value);
        case 'sp':
          composition = composition.copyWith(sp: value);
        case 'np':
          composition = composition.copyWith(np: value);
        case 'op':
          composition = composition.copyWith(op: value);
        case 'wp':
          composition = composition.copyWith(wp: value);
        case 'ap':
          composition = composition.copyWith(ap: value);
      }
    });
  }

  CalculationResults calculateResults(FuelComposition composition) {
    // кофіцієнт переходу від робочої до сухої маси
    final kpc = 100.0 / (100.0 - composition.wp);
    // кофіцієнт переходу від робочої до горючої маси
    final kpg = 100.0 / (100.0 - composition.wp - composition.ap);

    // cклад сухої маси палива
    final dryComposition = {
      'H^C': composition.hp * kpc,
      'C^C': composition.cp * kpc,
      'S^C': composition.sp * kpc,
      'N^C': composition.np * kpc,
      'O^C': composition.op * kpc,
      'A^C': composition.ap * kpc,
    };

    // cклад горючої маси палива
    final combustibleComposition = {
      'H^Г': composition.hp * kpg,
      'C^Г': composition.cp * kpg,
      'S^Г': composition.sp * kpg,
      'N^Г': composition.np * kpg,
      'O^Г': composition.op * kpg,
    };

    // нижча теплота згоряння для робочої маси
    final qph = (339 * composition.cp +
            1030 * composition.hp -
            108.8 * (composition.op - composition.sp) -
            25 * composition.wp) /
        1000;
    // нижча теплота згоряння для сухої маси
    final qch =
        (qph + 0.025 * composition.wp) * (100.0 / (100.0 - composition.wp));
    // нижча теплота згоряння для горючої маси
    final qgh = (qph + 0.025 * composition.wp) *
        (100.0 / (100.0 - composition.wp - composition.ap));

    return CalculationResults(
      dryMassCoefficient: kpc,
      combustibleMassCoefficient: kpg,
      dryComposition: dryComposition,
      combustibleComposition: combustibleComposition,
      lowerHeatingValue: qph,
      lowerDryHeatingValue: qch,
      lowerCombustibleHeatingValue: qgh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Калькулятор складу палива',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                InputField(
                  label: 'H^P, %',
                  value: composition.hp,
                  onChanged: (value) => updateComposition('hp', value),
                ),
                InputField(
                  label: 'C^P, %',
                  value: composition.cp,
                  onChanged: (value) => updateComposition('cp', value),
                ),
                InputField(
                  label: 'S^P, %',
                  value: composition.sp,
                  onChanged: (value) => updateComposition('sp', value),
                ),
                InputField(
                  label: 'N^P, %',
                  value: composition.np,
                  onChanged: (value) => updateComposition('np', value),
                ),
                InputField(
                  label: 'O^P, %',
                  value: composition.op,
                  onChanged: (value) => updateComposition('op', value),
                ),
                InputField(
                  label: 'W^P, %',
                  value: composition.wp,
                  onChanged: (value) => updateComposition('wp', value),
                ),
                InputField(
                  label: 'A^P, %',
                  value: composition.ap,
                  onChanged: (value) => updateComposition('ap', value),
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
                        results = calculateResults(composition);
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
          title: 'Коефіцієнти переходу:',
          items: {
            'К^PС': results.dryMassCoefficient,
            'К^PГ': results.combustibleMassCoefficient,
          },
        ),
        ResultSection(
          title: 'Суха маса:',
          items: results.dryComposition,
        ),
        ResultSection(
          title: 'Горюча маса:',
          items: results.combustibleComposition,
        ),
        ResultSection(
          title: 'Нижча теплота згоряння:',
          items: {
            'Для робочої маси': results.lowerHeatingValue,
            'Для сухої маси': results.lowerDryHeatingValue,
            'Для горючої маси': results.lowerCombustibleHeatingValue,
          },
        ),
      ],
    );
  }
}

class ResultSection extends StatelessWidget {
  final String title;
  final Map<String, double> items;

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
                  Text(entry.value.toStringAsFixed(2)),
                ],
              ),
            )),
      ],
    );
  }
}
