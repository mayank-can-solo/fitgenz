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
        Container(width: 38, height: 38, decoration: BoxDecoration(color: kLime, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.bolt_rounded, color: kBg, size: 25)),
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
      const SizedBox(height: 13),
      const Text('Meal ideas are examples, not a prescribed diet. Adjust portions, consider allergies and seek qualified advice for individual nutrition needs.', style: TextStyle(color: kMuted, fontSize: 10, height: 1.5)),
    ]);
  }

  Widget _macroBar(String label, double value, double scale, Color color) {
    final progress = (value / scale).clamp(0.0, 1.0).toDouble();
    return Padding(padding: const EdgeInsets.only(top: 11), child: Column(children: <Widget>[
      Row(children: <Widget>[Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)), const Spacer(), Text('${value.round()} g', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))]),
      const SizedBox(height: 6),
      ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: progress, minHeight: 6, color: color, backgroundColor: Colors.white12)),
    ]));
  }

  Widget _waterCard() {
    return Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withOpacity(.06))), child: Row(children: <Widget>[
      Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFF173D48), borderRadius: BorderRadius.circular(17)), child: const Icon(Icons.water_drop_rounded, color: Color(0xFF70D6FF), size: 27)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        const Text('WATER CHECK-IN', style: TextStyle(color: kMuted, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
        Text('$_water glasses logged', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        const Text('A glass is counted as 250 ml', style: TextStyle(color: kMuted, fontSize: 10)),
      ])),
      IconButton(onPressed: () => _changeWater(-1), icon: const Icon(Icons.remove_circle_outline, color: Colors.white60)),
      IconButton(onPressed: () => _changeWater(1), icon: const Icon(Icons.add_circle, color: kLime, size: 29)),
    ]));
  }

  Widget _workoutPage() {
    final plans = _days <= 2
        ? <String>['Full body A', 'Full body B']
        : _days <= 4
            ? <String>['Upper body', 'Lower body', 'Mobility / recovery', 'Full body']
            : <String>['Push', 'Pull', 'Legs', 'Recovery', 'Upper body', 'Lower body', 'Rest'];
    final exerciseSets = <String, List<String>>{
      'Push': <String>['Push-ups • 3 × 8–12', 'Dumbbell shoulder press • 3 × 8–12', 'Lateral raises • 3 × 12–15', 'Triceps extensions • 3 × 10–12'],
      'Pull': <String>['One-arm dumbbell row • 3 × 10', 'Reverse fly • 3 × 12', 'Curl variation • 3 × 10–12', 'Hammer curls • 3 × 10–12'],
      'Legs': <String>['Bodyweight / goblet squat • 3 × 10', 'Romanian deadlift • 3 × 10', 'Reverse lunges • 3 × 10', 'Calf raises • 3 × 15'],
      'Upper body': <String>['Push-ups • 3 × 8–12', 'Dumbbell row • 3 × 10', 'Shoulder press • 3 × 10', 'Biceps curls • 3 × 12'],
      'Lower body': <String>['Squats • 3 × 10', 'Hip hinge • 3 × 10', 'Split squats • 3 × 8', 'Calf raises • 3 × 15'],
      'Full body A': <String>['Squat • 3 × 10', 'Push-ups • 3 × 8', 'Dumbbell row • 3 × 10', 'Plank • 3 × 20 sec'],
      'Full body B': <String>['Reverse lunge • 3 × 8', 'Shoulder press • 3 × 10', 'Hip hinge • 3 × 10', 'Curl • 3 × 12'],
    };
    return ListView(padding: const EdgeInsets.fromLTRB(18, 22, 18, 26), children: <Widget>[
      _pageHeader('TRAIN WITH INTENT', 'Workout studio', trailing: const _RoundIcon(icon: Icons.fitness_center_rounded)),
      const SizedBox(height: 18),
      Container(height: 154, padding: const EdgeInsets.all(18), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFF4B3B27), Color(0xFF1F1B15)])), child: Stack(children: <Widget>[
        Positioned(right: 2, top: -23, child: Icon(Icons.fitness_center_rounded, size: 150, color: Colors.white.withOpacity(.09))),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          const Text('YOUR TRAINING FREQUENCY', style: TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('$_days DAYS / WEEK', style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: kLime)),
          Text('Goal: $_goal', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const Spacer(),
          const Text('Tap a session to view exercise ideas', style: TextStyle(color: Colors.white60, fontSize: 10)),
        ]),
      ])),
      const SizedBox(height: 21),
      const _SectionTitle('YOUR WEEKLY SPLIT', 'Train hard. Recover smarter.'),
      const SizedBox(height: 12),
      for (var i = 0; i < plans.length; i++) _WorkoutTile(day: i + 1, title: plans[i], exercises: exerciseSets[plans[i]] ?? <String>['Choose comfortable full-body movements', 'Use controlled technique', 'Allow recovery between sessions']),
      const SizedBox(height: 12),
      const Text('This is a general example plan. Adapt it to your equipment, training experience and limitations. Warm up first; stop if you feel pain.', style: TextStyle(color: kMuted, fontSize: 10, height: 1.5)),
    ]);
  }

  Widget _progressPage() {
    final values = <double>[..._history];
    if (values.isEmpty) values.add(_weight);
    final difference = _weight - _target;
    return ListView(padding: const EdgeInsets.fromLTRB(18, 22, 18, 26), children: <Widget>[
      _pageHeader('YOUR JOURNEY', 'Growth tracker', trailing: const _RoundIcon(icon: Icons.insights_rounded)),
      const SizedBox(height: 18),
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(23), border: Border.all(color: Colors.white.withOpacity(.06))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        const Text('CURRENT BODY WEIGHT', style: TextStyle(color: kMuted, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
          Text('${_weight.toStringAsFixed(1)}', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
          const Padding(padding: EdgeInsets.only(bottom: 8, left: 5), child: Text('KG', style: TextStyle(color: kLime, fontWeight: FontWeight.w900))),
          const Spacer(),
          Text('TARGET ${_target.toStringAsFixed(1)} KG', style: const TextStyle(color: kMuted, fontSize: 10, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: (_weight / (_target <= 0 ? 1 : _target)).clamp(0.0, 1.0).toDouble(), minHeight: 8, color: kLime, backgroundColor: Colors.white12)),
        const SizedBox(height: 8),
        Text(difference.abs() < .1 ? 'You are at your target weight.' : '${difference.abs().toStringAsFixed(1)} kg ${difference > 0 ? 'above' : 'below'} your target', style: const TextStyle(color: kMuted, fontSize: 11)),
      ])),
      const SizedBox(height: 14),
      _weightEntryCard(),
      const SizedBox(height: 14),
      Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        const _SectionTitle('WEIGHT TREND', 'Your saved check-ins'),
        const SizedBox(height: 14),
        SizedBox(height: 170, child: CustomPaint(painter: _LineChartPainter(values), child: const SizedBox.expand())),
        const SizedBox(height: 6),
        Text('${_history.length} saved entries • Add entries consistently to see a trend', style: const TextStyle(color: kMuted, fontSize: 10)),
      ])),
      const SizedBox(height: 14),
      const _SectionTitle('BODY METRICS', 'Your current estimates'),
      const SizedBox(height: 10),
      Row(children: <Widget>[
        Expanded(child: _smallStat('BMI', _metrics['BMI']!.toStringAsFixed(1), Icons.monitor_weight_outlined)),
        const SizedBox(width: 9),
        Expanded(child: _smallStat('BMR', '${_metrics['BMR']!.round()} kcal', Icons.local_fire_department_outlined)),
      ]),
    ]);
  }

  Widget _weightEntryCard() {
    final controller = TextEditingController(text: _weight.toStringAsFixed(1));
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: kPanel2, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      const Text('LOG A CHECK-IN', style: TextStyle(color: kLime, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Row(children: <Widget>[
        Expanded(child: TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight in kg', prefixIcon: Icon(Icons.scale_outlined)))),
        const SizedBox(width: 9),
        FilledButton(onPressed: () {
          final v = double.tryParse(controller.text);
          if (v == null || v < 25 || v > 300) {
            _message('Enter a valid weight between 25 and 300 kg');
          } else {
            _addWeight(v);
          }
        }, child: const Text('SAVE')),
      ]),
    ]));
  }

  Widget _smallStat(String title, String value, IconData icon) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18)), child: Row(children: <Widget>[
    Icon(icon, color: kLime, size: 21),
    const SizedBox(width: 9),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Text(title, style: const TextStyle(color: kMuted, fontSize: 9, letterSpacing: 1)),
      Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
    ])),
  ]));

  Widget _profilePage() {
    return ListView(padding: const EdgeInsets.fromLTRB(18, 22, 18, 26), children: <Widget>[
      _pageHeader('MAKE IT YOURS', 'Your profile', trailing: const _RoundIcon(icon: Icons.tune_rounded)),
      const SizedBox(height: 18),
      Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(gradient: const LinearGradient(colors: <Color>[Color(0xFF304333), Color(0xFF18231B)]), borderRadius: BorderRadius.circular(22)), child: Row(children: <Widget>[
        Container(width: 58, height: 58, decoration: BoxDecoration(color: kLime, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.person_rounded, color: kBg, size: 34)),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text(_name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          Text('$_goal • $_days training days / week', style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ])),
      ])),
      const SizedBox(height: 20),
      const _SectionTitle('BASIC DETAILS', 'Your starting point'),
      const SizedBox(height: 12),
      _inputField('Display name', _nameController),
      _inputField('Age (years)', _ageController, numeric: true),
      _inputField('Height (cm)', _heightController, numeric: true),
      _inputField('Current weight (kg)', _weightController, numeric: true),
      _inputField('Target weight (kg)', _targetController, numeric: true),
      const SizedBox(height: 8),
      const _SectionTitle('FITNESS SETTINGS', 'Personalise your estimates'),
      const SizedBox(height: 12),
      _dropdown('Sex for BMR equation', _sex, <String>['Male', 'Female'], (v) => setState(() => _sex = v)),
      _dropdown('Activity level', _activity, <String>['Sedentary', 'Lightly active', 'Moderately active', 'Very active', 'Extremely active'], (v) => setState(() => _activity = v)),
      _dropdown('Primary goal', _goal, <String>['Gain weight', 'Build muscle', 'Lose weight', 'Maintain weight'], (v) => setState(() => _goal = v)),
      _dropdown('Diet preference', _diet, <String>['Vegetarian', 'Eggetarian', 'Non-vegetarian', 'Vegan'], (v) => setState(() => _diet = v)),
      _dropdown('Workout days per week', '$_days', List<String>.generate(8, (i) => '$i'), (v) => setState(() => _days = int.parse(v))),
      const SizedBox(height: 10),
      FilledButton.icon(
        onPressed: () async {
          final a = int.tryParse(_ageController.text);
          final h = double.tryParse(_heightController.text);
          final w = double.tryParse(_weightController.text);
          final t = double.tryParse(_targetController.text);
          if (a == null || a < 18 || a > 100 || h == null || h < 100 || h > 230 || w == null || w < 25 || w > 300 || t == null || t < 25 || t > 300) {
            _message('Check your details. This demo is designed for adults aged 18+ and valid body measurements.');
            return;
          }
          setState(() {
            _name = _nameController.text.trim().isEmpty ? 'FITGENZ USER' : _nameController.text.trim();
            _age = a;
            _height = h;
            _weight = w;
            _target = t;
          });
          await _save();
          if (mounted) _message('Your profile has been saved on this device');
        },
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('SAVE MY PROFILE'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), backgroundColor: kLime, foregroundColor: kBg, textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .5)),
      ),
      const SizedBox(height: 14),
      const Text('Calorie and macro values are estimates based on the details entered. They are not medical advice or a substitute for a qualified dietitian. Do not use this app to set restrictive targets without professional guidance.', style: TextStyle(color: kMuted, fontSize: 10, height: 1.5)),
    ]);
  }

  Widget _inputField(String label, TextEditingController controller, {bool numeric = false}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: controller, keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, decoration: InputDecoration(labelText: label)));

  Widget _dropdown(String label, String value, List<String> options, ValueChanged<String> onChanged) => Padding(padding: const EdgeInsets.only(bottom: 10), child: DropdownButtonFormField<String>(value: value, decoration: InputDecoration(labelText: label), items: options.map((v) => DropdownMenuItem<String>(value: v, child: Text(v, style: const TextStyle(fontSize: 13)))).toList(), onChanged: (v) { if (v != null) onChanged(v); }));
}

class _SectionTitle extends StatelessWidget {
  final String eyebrow;
  final String title;
  const _SectionTitle(this.eyebrow, this.title);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
    Text(eyebrow, style: const TextStyle(color: kLime, fontSize: 9, letterSpacing: 1.7, fontWeight: FontWeight.w900)),
    const SizedBox(height: 4),
    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -.2)),
  ]);
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill({required this.label});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: kLime.withOpacity(.13), borderRadius: BorderRadius.circular(30), border: Border.all(color: kLime.withOpacity(.2))), child: Text(label, style: const TextStyle(color: kLime, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: .6)));
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  const _RoundIcon({required this.icon});
  @override
  Widget build(BuildContext context) => Container(width: 42, height: 42, decoration: BoxDecoration(color: kPanel2, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)), child: Icon(icon, color: kLime));
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
  const _FeatureCard({required this.title, required this.subtitle, required this.icon, required this.colors, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(color: Colors.transparent, child: InkWell(
      borderRadius: BorderRadius.circular(21),
      onTap: onTap,
      child: Ink(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors), borderRadius: BorderRadius.circular(21), border: Border.all(color: Colors.white.withOpacity(.08))), child: Stack(children: <Widget>[
        Positioned(right: -10, top: -12, child: Icon(icon, size: 105, color: Colors.white.withOpacity(.10))),
        Positioned(right: 13, top: 13, child: Icon(Icons.arrow_outward_rounded, color: Colors.white.withOpacity(.6), size: 16)),
        Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          Container(width: 39, height: 39, decoration: BoxDecoration(color: Colors.white.withOpacity(.13), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: Colors.white, size: 22)),
          const Spacer(),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ])),
      ])),
    ));
  }
}

class _MealCard extends StatelessWidget {
  final int index;
  final Map<String, String> meal;
  const _MealCard({required this.index, required this.meal});
  @override
  Widget build(BuildContext context) {
    const icons = <IconData>[Icons.breakfast_dining_rounded, Icons.lunch_dining_rounded, Icons.eco_rounded, Icons.dinner_dining_rounded];
    const colors = <Color>[Color(0xFFB9E86B), Color(0xFFFFB56B), Color(0xFF79D8FF), Color(0xFFD0A1FF)];
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(19), border: Border.all(color: Colors.white.withOpacity(.06))), child: Row(children: <Widget>[
      Container(width: 61, height: 61, decoration: BoxDecoration(color: colors[index].withOpacity(.13), borderRadius: BorderRadius.circular(17)), child: Stack(alignment: Alignment.center, children: <Widget>[
        Icon(Icons.circle, size: 50, color: colors[index].withOpacity(.10)),
        Icon(icons[index], size: 30, color: colors[index]),
      ])),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text(meal['time']!, style: TextStyle(color: colors[index], fontSize: 9, letterSpacing: 1.3, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(meal['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(meal['detail']!, style: const TextStyle(color: kMuted, fontSize: 10)),
      ])),
      const Icon(Icons.chevron_right_rounded, color: kMuted),
    ]));
  }
}

class _WorkoutTile extends StatelessWidget {
  final int day;
  final String title;
  final List<String> exercises;
  const _WorkoutTile({required this.day, required this.title, required this.exercises});
  @override
  Widget build(BuildContext context) {
    final isRest = title.toLowerCase().contains('rest') || title.toLowerCase().contains('recovery') || title.toLowerCase().contains('mobility');
    return Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(.06))), child: ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: isRest ? Colors.white10 : kLime.withOpacity(.13), borderRadius: BorderRadius.circular(13)), child: Icon(isRest ? Icons.self_improvement_rounded : Icons.fitness_center_rounded, color: isRest ? kMuted : kLime)),
      title: Text('DAY $day • ${title.toUpperCase()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .4)),
      subtitle: Text(isRest ? 'Recovery and mobility' : '${exercises.length} exercise ideas • Tap to expand', style: const TextStyle(color: kMuted, fontSize: 10)),
      children: <Widget>[
        for (final exercise in exercises) Padding(padding: const EdgeInsets.only(bottom: 9), child: Row(children: <Widget>[const Icon(Icons.check_circle_outline, color: kLime, size: 16), const SizedBox(width: 9), Expanded(child: Text(exercise, style: const TextStyle(fontSize: 12, color: Colors.white70)))])),
        if (isRest) const Text('Try an easy walk, gentle mobility and enough sleep.', style: TextStyle(color: kMuted, fontSize: 11)),
      ],
    ));
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  _LineChartPainter(this.values);
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = Colors.white.withOpacity(.07)..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (values.isEmpty) return;
    final minV = values.reduce((a, b) => a < b ? a : b) - 1;
    final maxV = values.reduce((a, b) => a > b ? a : b) + 1;
    final range = (maxV - minV).abs() < .01 ? 1.0 : maxV - minV;
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? size.width / 2 : size.width * i / (values.length - 1);
      final y = size.height - ((values[i] - minV) / range * (size.height - 18)) - 9;
      points.add(Offset(x, y));
    }
    if (points.length == 1) {
      canvas.drawCircle(points.first, 5, Paint()..color = kLime);
      return;
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    final fillPath = Path.from(path)..lineTo(points.last.dx, size.height)..lineTo(points.first.dx, size.height)..close();
    canvas.drawPath(fillPath, Paint()..shader = LinearGradient(colors: <Color>[kLime.withOpacity(.24), kLime.withOpacity(0)]).createShader(Offset.zero & size));
    canvas.drawPath(path, Paint()..color = kLime..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = kLime);
      canvas.drawCircle(point, 7, Paint()..color = kLime.withOpacity(.18));
    }
  }
  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => oldDelegate.values != values;
}
