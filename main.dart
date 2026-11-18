import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const lime = Color(0xFFB7FF36);
const bg = Color(0xFF080A08);
const card = Color(0xFF151B15);

void main() => runApp(const FitgenzApp());

class FitgenzApp extends StatelessWidget {
  const FitgenzApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FITGENZ', debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark, scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(primary: lime, secondary: lime, surface: card),
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    ),
    home: const FitgenzHome(),
  );
}

class FitgenzHome extends StatefulWidget {
  const FitgenzHome({super.key});
  @override
  State<FitgenzHome> createState() => _FitgenzHomeState();
}

class _FitgenzHomeState extends State<FitgenzHome> {
  int tab = 0, age = 20, days = 4;
  String sex = 'Male', activity = 'Moderately active', goal = 'Build muscle', diet = 'Eggetarian';
  double height = 177, weight = 60, target = 65;
  final name = TextEditingController(text: 'FITGENZ User');
  final ageCtrl = TextEditingController(text: '20');
  final heightCtrl = TextEditingController(text: '177');
  final weightCtrl = TextEditingController(text: '60');
  final targetCtrl = TextEditingController(text: '65');
  final history = <double>[];

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      name.text = p.getString('name') ?? name.text;
      ageCtrl.text = p.getString('age') ?? ageCtrl.text;
      heightCtrl.text = p.getString('height') ?? heightCtrl.text;
      weightCtrl.text = p.getString('weight') ?? weightCtrl.text;
      targetCtrl.text = p.getString('target') ?? targetCtrl.text;
      sex = p.getString('sex') ?? sex;
      activity = p.getString('activity') ?? activity;
      goal = p.getString('goal') ?? goal;
      diet = p.getString('diet') ?? diet;
      days = p.getInt('days') ?? days;
      history.addAll((p.getStringList('history') ?? []).map((e) => double.tryParse(e) ?? 0));
      _sync();
    });
  }
  void _sync() {
    age = int.tryParse(ageCtrl.text) ?? 20;
    height = double.tryParse(heightCtrl.text) ?? 177;
    weight = double.tryParse(weightCtrl.text) ?? 60;
    target = double.tryParse(targetCtrl.text) ?? 65;
  }
  Future<void> _save() async {
    _sync();
    final p = await SharedPreferences.getInstance();
    await p.setString('name', name.text);
    await p.setString('age', ageCtrl.text);
    await p.setString('height', heightCtrl.text);
    await p.setString('weight', weightCtrl.text);
    await p.setString('target', targetCtrl.text);
    await p.setString('sex', sex);
    await p.setString('activity', activity);
    await p.setString('goal', goal);
    await p.setString('diet', diet);
    await p.setInt('days', days);
    await p.setStringList('history', history.map((e) => e.toString()).toList());
    if (mounted) setState(() {});
  }
  Map<String, double> get result {
    _sync();
    final bmi = weight / ((height / 100) * (height / 100));
    final bmr = 10 * weight + 6.25 * height - 5 * age + (sex == 'Male' ? 5 : -161);
    const factors = {'Sedentary':1.2,'Lightly active':1.375,'Moderately active':1.55,'Very active':1.725,'Extremely active':1.9};
    final tdee = bmr * (factors[activity] ?? 1.55);
    final delta = goal == 'Gain weight' ? 250.0 : goal == 'Lose weight' ? -300.0 : goal == 'Build muscle' ? 150.0 : 0.0;
    final kcal = (tdee + delta).clamp(1200.0, 5000.0).toDouble();
    final protein = weight * ((goal == 'Build muscle' || goal == 'Lose weight') ? 1.8 : 1.5);
    final fat = kcal * .27 / 9;
    final carbs = ((kcal - protein * 4 - fat * 9) / 4).clamp(0.0, 1000.0).toDouble();
    return {'BMI':bmi,'BMR':bmr,'TDEE':tdee,'Calories':kcal,'Protein':protein,'Fat':fat,'Carbs':carbs,'Fibre':kcal*.014};
  }
  String get bmiText {
    final b = result['BMI']!;
    return b < 18.5 ? 'Below adult reference range' : b < 25 ? 'Within adult reference range' : b < 30 ? 'Above adult reference range' : 'High adult BMI range';
  }
  Widget tile(String title, String value, {String? subtitle}) => Container(
    padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      const SizedBox(height: 7), Text(value, style: const TextStyle(color: lime, fontSize: 23, fontWeight: FontWeight.bold)),
      if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11))]
    ]),
  );
  Widget field(String label, TextEditingController c, {bool numeric=false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(controller: c, keyboardType: numeric ? const TextInputType.numberWithOptions(decimal:true) : TextInputType.text,
      decoration: InputDecoration(labelText: label), onChanged: (_) => setState(() {})),
  );
  Widget drop(String label, String value, List<String> options, ValueChanged<String?> change) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(value:value, decoration:InputDecoration(labelText:label),
      items:options.map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(), onChanged:change),
  );
  Widget dashboard() {
    final r = result;
    return ListView(padding: const EdgeInsets.all(18), children: [
      Row(children:[const Icon(Icons.bolt,color:lime,size:30),const SizedBox(width:8),const Text('FITGENZ',style:TextStyle(fontSize:23,fontWeight:FontWeight.w900,letterSpacing:1.5)),const Spacer(),const Icon(Icons.person_outline,color:lime)]),
      const SizedBox(height:25),
      Text('HELLO, ${name.text.toUpperCase()}',style:const TextStyle(color:Colors.white54,letterSpacing:1.2,fontSize:11)),
      const Text('Build your best self.',style:TextStyle(fontSize:27,fontWeight:FontWeight.bold)),
      const SizedBox(height:18),
      Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),gradient:const LinearGradient(colors:[Color(0xFF26391C),card])),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('DAILY CALORIE TARGET',style:TextStyle(color:Colors.white60,fontSize:11,letterSpacing:1.2)),
          Text('${r['Calories']!.round()} kcal',style:const TextStyle(color:lime,fontSize:38,fontWeight:FontWeight.w900)),
          const Text('Estimated starting target • adjust using weight trends',style:TextStyle(color:Colors.white54,fontSize:11))
        ])),
      const SizedBox(height:14),
      GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,childAspectRatio:1.6,crossAxisSpacing:10,mainAxisSpacing:10,children:[
        tile('BMI',r['BMI']!.toStringAsFixed(1),subtitle:bmiText),
        tile('BMR','${r['BMR']!.round()} kcal'),
        tile('Protein','${r['Protein']!.round()} g / day'),
        tile('Carbohydrates','${r['Carbs']!.round()} g / day'),
        tile('Fat','${r['Fat']!.round()} g / day'),
        tile('Fibre','${r['Fibre']!.round()} g / day'),
      ]),
      const SizedBox(height:12),
      tile('Activity-adjusted TDEE','${r['TDEE']!.round()} kcal'),
      const SizedBox(height:12),
      FilledButton(onPressed:()=>setState(()=>tab=4),child:const Text('EDIT MY FITNESS PROFILE')),
    ]);
  }
  Widget profilePage() => ListView(padding:const EdgeInsets.all(18),children:[
    const Text('YOUR PROFILE',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
    const SizedBox(height:18),field('Name',name),field('Age (years)',ageCtrl,numeric:true),
    field('Height (cm)',heightCtrl,numeric:true),field('Current weight (kg)',weightCtrl,numeric:true),field('Target weight (kg)',targetCtrl,numeric:true),
    drop('Sex for BMR equation',sex,['Male','Female'],(v)=>setState(()=>sex=v!)),
    drop('Daily activity level',activity,['Sedentary','Lightly active','Moderately active','Very active','Extremely active'],(v)=>setState(()=>activity=v!)),
    drop('Fitness goal',goal,['Gain weight','Build muscle','Lose weight','Maintain weight'],(v)=>setState(()=>goal=v!)),
    drop('Diet preference',diet,['Vegetarian','Eggetarian','Non-vegetarian','Vegan'],(v)=>setState(()=>diet=v!)),
    drop('Workout days per week','$days',[for(int i=0;i<=7;i++) '$i'],(v)=>setState(()=>days=int.parse(v!))),
    FilledButton(onPressed:() async {await _save(); if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Profile saved on this device')));},child:const Text('SAVE PROFILE')),
  ]);
  Widget nutritionPage() {
    final r=result;
    final meals = diet=='Vegan' || diet=='Vegetarian'
      ? ['Oats with milk/soy milk and banana','Dal, rice, curd and vegetables','Roasted chana and fruit','Paneer/tofu with roti and vegetables']
      : ['Oats, milk and boiled eggs','Rice, dal, curd and eggs/chicken','Banana and yogurt','Paneer/egg/chicken with roti and vegetables'];
    return ListView(padding:const EdgeInsets.all(18),children:[
      const Text('NUTRITION PLAN',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),Text('Daily target: ${r['Calories']!.round()} kcal',style:const TextStyle(color:lime,fontSize:20,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),const Text('Sample meal ideas — adjust portions to meet your calculated targets.',style:TextStyle(color:Colors.white60)),
      const SizedBox(height:16),
      for(int i=0;i<meals.length;i++) Padding(padding:const EdgeInsets.only(bottom:10),child:tile(['BREAKFAST','LUNCH','SNACK','DINNER'][i],meals[i])),
      const SizedBox(height:8),const Text('Macro targets',style:TextStyle(fontWeight:FontWeight.bold,fontSize:18)),
      tile('Protein','${r['Protein']!.round()} g'),tile('Carbohydrates','${r['Carbs']!.round()} g'),tile('Fat','${r['Fat']!.round()} g'),
      const SizedBox(height:10),const Text('Food suggestions are examples, not a verified meal prescription. Check ingredients and allergies.',style:TextStyle(color:Colors.white54,fontSize:11))
    ]);
  }
  Widget workoutPage() {
    final split = days <= 2 ? ['Full body A','Full body B'] : days <= 4 ? ['Upper body','Lower body','Rest / mobility','Full body'] : ['Push','Pull','Legs','Rest / mobility','Upper body','Lower body','Rest'];
    return ListView(padding:const EdgeInsets.all(18),children:[
      const Text('WORKOUT PLAN',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),Text('$days training days per week • ${goal}',style:const TextStyle(color:lime)),
      const SizedBox(height:16),
      for(int i=0;i<split.length;i++) Padding(padding:const EdgeInsets.only(bottom:10),child:Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:card,borderRadius:BorderRadius.circular(16)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('DAY ${i+1} • ${split[i].toUpperCase()}',style:const TextStyle(color:lime,fontWeight:FontWeight.bold)),
        const SizedBox(height:8),Text(split[i].toLowerCase().contains('rest')?'Light walking, mobility and recovery.':'3 sets of 8–12 reps per exercise; use a comfortable, controlled load.',style:const TextStyle(color:Colors.white70)),
        if(!split[i].toLowerCase().contains('rest')) const Text('Suggested: Squat / press / row / hinge / core stability',style:TextStyle(color:Colors.white54,fontSize:12))
      ]))),
      const Text('Adapt exercises to your ability, equipment and any physical limitations. Stop if you feel pain.',style:TextStyle(color:Colors.white54,fontSize:11))
    ]);
  }
  Widget progressPage() => ProgressView(weight:weight,history:history,onAdd:(v) async {
    setState(()=>history.add(v));
    final p=await SharedPreferences.getInstance();
    await p.setStringList('history',history.map((e)=>e.toString()).toList());
  });
  @override
  Widget build(BuildContext context) {
    final pages=[dashboard(),nutritionPage(),workoutPage(),progressPage(),profilePage()];
    return Scaffold(
      body:SafeArea(child:pages[tab]),
      bottomNavigationBar:NavigationBar(backgroundColor:const Color(0xFF111711),indicatorColor:lime.withOpacity(.15),selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),destinations:const[
        NavigationDestination(icon:Icon(Icons.grid_view_rounded),label:'Home'),
        NavigationDestination(icon:Icon(Icons.restaurant_menu),label:'Nutrition'),
        NavigationDestination(icon:Icon(Icons.fitness_center),label:'Workout'),
        NavigationDestination(icon:Icon(Icons.insights),label:'Progress'),
        NavigationDestination(icon:Icon(Icons.person_outline),label:'Profile'),
      ]),
    );
  }
}

class ProgressView extends StatefulWidget {
  final double weight;
  final List<double> history;
  final ValueChanged<double> onAdd;
  const ProgressView({super.key,required this.weight,required this.history,required this.onAdd});
  @override
  State<ProgressView> createState()=>_ProgressViewState();
}
class _ProgressViewState extends State<ProgressView> {
  final controller=TextEditingController();
  @override
  Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(18),children:[
    const Text('YOUR PROGRESS',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
    const SizedBox(height:14),
    TextField(controller:controller,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Enter current weight (kg)')),
    const SizedBox(height:10),
    FilledButton(onPressed:(){final v=double.tryParse(controller.text);if(v!=null&&v>0&&v<500){widget.onAdd(v);controller.clear();ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Weight entry saved')));}},child:const Text('ADD WEIGHT ENTRY')),
    const SizedBox(height:20),const Text('RECENT ENTRIES',style:TextStyle(color:lime,fontWeight:FontWeight.bold)),
    const SizedBox(height:8),
    if(widget.history.isEmpty) const Text('No entries yet',style:TextStyle(color:Colors.white54)),
    for(final v in widget.history.reversed.take(15)) ListTile(leading:const Icon(Icons.monitor_weight_outlined,color:lime),title:Text('${v.toStringAsFixed(1)} kg'),subtitle:const Text('Saved on this device')),
  ]);
}
