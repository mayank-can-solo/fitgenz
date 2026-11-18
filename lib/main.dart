import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color kBg = Color(0xFF080B0A);
const Color kPanel = Color(0xFF121916);
const Color kPanel2 = Color(0xFF19231E);
const Color kLime = Color(0xFFC7FF4A);
const Color kMint = Color(0xFF72E6B2);
const Color kMuted = Color(0xFF91A098);

void main() => runApp(const FitgenzApp());

class FitgenzApp extends StatelessWidget {
  const FitgenzApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FITGENZ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kLime, secondary: kMint, surface: kPanel),
        fontFamily: 'Roboto',
        snackBarTheme: SnackBarThemeData(
          backgroundColor: kPanel2,
          contentTextStyle: const TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kPanel2,
          labelStyle: const TextStyle(color: kMuted),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kLime)),
        ),
      ),
      home: const FitgenzShell(),
    );
  }
}

class FitgenzShell extends StatefulWidget {
  const FitgenzShell({super.key});
  @override
  State<FitgenzShell> createState() => _FitgenzShellState();
}

class _FitgenzShellState extends State<FitgenzShell> {
  int _tab = 0;
  String _name = 'FITGENZ USER';
  int _age = 20;
  String _sex = 'Male';
  double _height = 177;
  double _weight = 60;
  double _target = 65;
  String _activity = 'Moderately active';
  String _goal = 'Build muscle';
  String _diet = 'Eggetarian';
  int _days = 4;
  int _water = 0;
  final List<double> _history = <double>[];
  final Set<String> _doneHabits = <String>{};
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _targetController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _name);
    _ageController = TextEditingController(text: _age.toString());
    _heightController = TextEditingController(text: _height.toStringAsFixed(0));
    _weightController = TextEditingController(text: _weight.toStringAsFixed(1));
    _targetController = TextEditingController(text: _target.toStringAsFixed(1));
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _name = p.getString('name') ?? _name;
      _age = p.getInt('age') ?? _age;
      _sex = p.getString('sex') ?? _sex;
      _height = p.getDouble('height') ?? _height;
      _weight = p.getDouble('weight') ?? _weight;
      _target = p.getDouble('target') ?? _target;
      _activity = p.getString('activity') ?? _activity;
      _goal = p.getString('goal') ?? _goal;
      _diet = p.getString('diet') ?? _diet;
      _days = p.getInt('days') ?? _days;
      _water = p.getInt('water') ?? _water;
      _history
        ..clear()
        ..addAll((p.getStringList('history') ?? <String>[]).map((e) => double.tryParse(e) ?? 0));
      _doneHabits
        ..clear()
        ..addAll(p.getStringList('habits') ?? <String>[]);
      _nameController.text = _name;
      _ageController.text = _age.toString();
      _heightController.text = _height.toStringAsFixed(0);
      _weightController.text = _weight.toStringAsFixed(1);
      _targetController.text = _target.toStringAsFixed(1);
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('name', _name);
    await p.setInt('age', _age);
    await p.setString('sex', _sex);
    await p.setDouble('height', _height);
    await p.setDouble('weight', _weight);
    await p.setDouble('target', _target);
    await p.setString('activity', _activity);
    await p.setString('goal', _goal);
    await p.setString('diet', _diet);
    await p.setInt('days', _days);
    await p.setInt('water', _water);
    await p.setStringList('history', _history.map((e) => e.toString()).toList());
    await p.setStringList('habits', _doneHabits.toList());
  }

  Map<String, double> get _metrics {
    final safeHeight = _height.clamp(100.0, 230.0).toDouble();
    final safeWeight = _weight.clamp(25.0, 300.0).toDouble();
    final bmi = safeWeight / math.pow(safeHeight / 100, 2);
    final bmr = 10 * safeWeight + 6.25 * safeHeight - 5 * _age + (_sex == 'Male' ? 5 : -161);
    const factors = <String, double>{
      'Sedentary': 1.2,
      'Lightly active': 1.375,
      'Moderately active': 1.55,
      'Very active': 1.725,
      'Extremely active': 1.9,
    };
    final tdee = bmr * (factors[_activity] ?? 1.55);
    final adjustment = _goal == 'Gain weight' ? 250.0 : _goal == 'Lose weight' ? -300.0 : _goal == 'Build muscle' ? 150.0 : 0.0;
    final calories = (tdee + adjustment).clamp(1200.0, 5000.0).toDouble();
    final protein = safeWeight * (_goal == 'Build muscle' || _goal == 'Lose weight' ? 1.8 : 1.5);
    final fat = calories * .27 / 9;
    final carbs = ((calories - protein * 4 - fat * 9) / 4).clamp(0.0, 1000.0).toDouble();
    return <String, double>{'BMI': bmi, 'BMR': bmr, 'TDEE': tdee, 'Calories': calories, 'Protein': protein, 'Fat': fat, 'Carbs': carbs, 'Fibre': calories * .014};
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _addWeight(double value) {
    setState(() {
      _weight = value;
      _weightController.text = value.toStringAsFixed(1);
      _history.add(value);
    });
    _save();
    _message('Progress entry saved');
  }

  void _changeWater(int amount) {
    setState(() => _water = (_water + amount).clamp(0, 20).toInt());
    _save();
  }

  void _toggleHabit(String habit) {
    setState(() {
      if (_doneHabits.contains(habit)) {
        _doneHabits.remove(habit);
      } else {
        _doneHabits.add(habit);
      }
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _homePage(),
      _nutritionPage(),
      _workoutPage(),
      _progressPage(),
      _profilePage(),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _tab, children: pages)),
      bottomNavigationBar: NavigationBar(
        height: 72,
        backgroundColor: const Color(0xFF101612),
        indicatorColor: kLime.withOpacity(.16),
        selectedIndex: _tab,
        onDestinationSelected: (v) => setState(() => _tab = v),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.restaurant_outlined), selectedIcon: Icon(Icons.restaurant), label: 'Fuel'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Train'),
          NavigationDestination(icon: Icon(Icons.query_stats_outlined), selectedIcon: Icon(Icons.query_stats), label: 'Growth'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'You'),
        ],
      ),
    );
  }

  Widget _pageHeader(String eyebrow, String title, {Widget? trailing}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text(eyebrow.toUpperCase(), style: const TextStyle(color: kLime, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: -.7)),
      ])),
      if (trailing != null) trailing,
    ]);
  }

  Widget _homePage() {
    final m = _metrics;
    return ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 26), children: <Widget>[
      Row(children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.asset(
            'assets/fitgenz_logo.png',
            width: 42,
            height: 42,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: kLime, borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.fitness_center_rounded, color: kBg, size: 24),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text('FITGENZ', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const Spacer(),
        IconButton(onPressed: () => setState(() => _tab = 4), icon: const Icon(Icons.account_circle_outlined, color: kLime, size: 28)),
      ]),
      const SizedBox(height: 25),
      Text('WELCOME BACK, ${_name.toUpperCase()}', style: const TextStyle(color: kMuted, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      const Text('Make today\nyour strongest.', style: TextStyle(fontSize: 33, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -1.1)),
      const SizedBox(height: 19),
      _calorieHero(m['Calories']!.round()),
      const SizedBox(height: 18),
      Row(children: <Widget>[
        const Expanded(child: _SectionTitle('YOUR SNAPSHOT', 'Numbers that move you')),
        TextButton(onPressed: () => setState(() => _tab = 4), child: const Text('EDIT PROFILE')),
      ]),
      const SizedBox(height: 10),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
        children: <Widget>[
          _metricCard('BMI', m['BMI']!.toStringAsFixed(1), 'Body mass index', Icons.monitor_weight_outlined, const Color(0xFFB9F36A)),
          _metricCard('BMR', '${m['BMR']!.round()}', 'Resting kcal / day', Icons.local_fire_department_outlined, const Color(0xFFFFA66B)),
          _metricCard('PROTEIN', '${m['Protein']!.round()} g', 'Daily estimate', Icons.egg_alt_outlined, const Color(0xFF79D8FF)),
          _metricCard('TDEE', '${m['TDEE']!.round()}', 'Activity-adjusted kcal', Icons.bolt_outlined, const Color(0xFFD4A6FF)),
        ],
      ),
      const SizedBox(height: 21),
      const _SectionTitle('JUMP BACK IN', 'Your fitness toolkit'),
      const SizedBox(height: 12),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.18,
        children: <Widget>[
          _FeatureCard(title: 'Nutrition', subtitle: 'Fuel with purpose', icon: Icons.ramen_dining_rounded, colors: const <Color>[Color(0xFF315B42), Color(0xFF17251D)], onTap: () => setState(() => _tab = 1)),
          _FeatureCard(title: 'Workouts', subtitle: 'Build your strength', icon: Icons.sports_gymnastics_rounded, colors: const <Color>[Color(0xFF51402D), Color(0xFF241D17)], onTap: () => setState(() => _tab = 2)),
          _FeatureCard(title: 'Progress', subtitle: 'See your evolution', icon: Icons.insights_rounded, colors: const <Color>[Color(0xFF263E59), Color(0xFF151F2B)], onTap: () => setState(() => _tab = 3)),
          _FeatureCard(title: 'My profile', subtitle: 'Tune your targets', icon: Icons.tune_rounded, colors: const <Color>[Color(0xFF4A3655), Color(0xFF211A29)], onTap: () => setState(() => _tab = 4)),
        ],
      ),
      const SizedBox(height: 21),
      _habitCard(),
      const SizedBox(height: 14),
      const Text('FITGENZ estimates are educational starting points, not medical advice. BMI is an adult screening measure, not a diagnosis.', style: TextStyle(color: kMuted, fontSize: 10, height: 1.5)),
    ]);
  }

  Widget _calorieHero(int calories) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFF263C2D), Color(0xFF142019), Color(0xFF101713)]),
        border: Border.all(color: kLime.withOpacity(.25)),
      ),
      child: Stack(children: <Widget>[
        Positioned(right: -15, top: -20, child: Icon(Icons.bolt_rounded, size: 145, color: kLime.withOpacity(.07))),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Row(children: <Widget>[
            const Icon(Icons.local_fire_department_rounded, color: kLime, size: 18),
            const SizedBox(width: 7),
            const Text('DAILY ENERGY TARGET', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
            const Spacer(),
            _Pill(label: _goal.toUpperCase()),
          ]),
          const SizedBox(height: 13),
          Text('$calories', style: const TextStyle(fontSize: 43, fontWeight: FontWeight.w900, color: kLime, letterSpacing: -1.5)),
          const Text('KCAL / DAY • ESTIMATED', style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1.4)),
          const SizedBox(height: 18),
          Row(children: <Widget>[
            Expanded(child: _miniTarget('PROTEIN', '${_metrics['Protein']!.round()} g')),
            Expanded(child: _miniTarget('CARBS', '${_metrics['Carbs']!.round()} g')),
            Expanded(child: _miniTarget('FATS', '${_metrics['Fat']!.round()} g')),
          ]),
        ]),
      ]),
    );
  }

  Widget _miniTarget(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1)),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
  ]);

  Widget _metricCard(String label, String value, String caption, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(.06))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Row(children: <Widget>[Icon(icon, color: accent, size: 18), const Spacer(), Icon(Icons.north_east_rounded, color: Colors.white.withOpacity(.25), size: 15)]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: -.5)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
          Text(caption, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kMuted, fontSize: 9)),
        ]),
      ]),
    );
  }

  Widget _habitCard() {
    const habits = <String>['Move for 20 minutes', 'Eat a protein-rich meal', 'Drink water regularly', 'Get enough sleep'];
    final done = habits.where(_doneHabits.contains).length;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withOpacity(.06))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Row(children: <Widget>[
          const Expanded(child: _SectionTitle('DAILY CHECK-IN', 'Small wins add up')),
          Text('$done/${habits.length}', style: const TextStyle(color: kLime, fontWeight: FontWeight.w900, fontSize: 17)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: done / habits.length, minHeight: 6, backgroundColor: Colors.white10, color: kLime)),
        const SizedBox(height: 8),
        for (final habit in habits)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: kLime,
            checkColor: kBg,
            title: Text(habit, style: TextStyle(fontSize: 12, color: _doneHabits.contains(habit) ? kMuted : Colors.white, decoration: _doneHabits.contains(habit) ? TextDecoration.lineThrough : null)),
            value: _doneHabits.contains(habit),
            onChanged: (_) => _toggleHabit(habit),
          ),
      ]),
    );
  }

  Widget _nutritionPage() {
    final m = _metrics;
    final meals = <Map<String, String>>[
      <String, String>{'time': 'BREAKFAST', 'name': _diet == 'Vegan' ? 'Overnight oats + soy milk' : 'Oats, milk + eggs', 'detail': 'A balanced start with protein and fibre', 'icon': 'breakfast'},
      <String, String>{'time': 'LUNCH', 'name': _diet == 'Vegan' || _diet == 'Vegetarian' ? 'Dal, rice + tofu / curd' : 'Rice, dal + chicken / eggs', 'detail': 'Build a satisfying, colourful plate', 'icon': 'lunch'},
      <String, String>{'time': 'SNACK', 'name': 'Banana + roasted chana', 'detail': 'Easy option between meals', 'icon': 'snack'},
      <String, String>{'time': 'DINNER', 'name': _diet == 'Vegan' ? 'Tofu, roti + vegetables' : 'Paneer / egg + roti + vegetables', 'detail': 'Protein, vegetables and whole grains', 'icon': 'dinner'},
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(18, 22, 18, 26), children: <Widget>[
      _pageHeader('FUEL YOUR DAY', 'Nutrition studio', trailing: const _RoundIcon(icon: Icons.restaurant_menu_rounded)),
      const SizedBox(height: 18),
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: <Color>[Color(0xFF344D35), Color(0xFF17231C)]), borderRadius: BorderRadius.circular(23)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        const Text('YOUR DAILY TARGET', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('${m['Calories']!.round()} kcal', style: const TextStyle(fontSize: 32, color: kLime, fontWeight: FontWeight.w900)),
        const SizedBox(height: 15),
        _macroBar('Protein', m['Protein']!, 200, kLime),
        _macroBar('Carbs', m['Carbs']!, 400, const Color(0xFF70D6FF)),
        _macroBar('Fats', m['Fat']!, 120, const Color(0xFFFFB56B)),
        _macroBar('Fibre', m['Fibre']!, 50, const Color(0xFFCB9BFF)),
      ])),
      const SizedBox(height: 22),
      const _SectionTitle('MEAL INSPIRATION', 'Simple ideas, flexible portions'),
      const SizedBox(height: 12),
      for (var i = 0; i < meals.length; i++) _MealCard(index: i, meal: meals[i]),
      const SizedBox(height: 13),
      _waterCard(),
      const SizedBox
