import 'package:flutter/material.dart';
import 'package:isa_task_app/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  //supbase setup
    await Supabase.initialize(
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhzY3ptcGNyYnhwaWRybWZpZ2x1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5Mjc4MTgsImV4cCI6MjA1MDUwMzgxOH0.jYCWdfcQLIfxv7RL26ZxhqhfFCIy924XO-zcR_rbxXY',
      url: 'https://xsczmpcrbxpidrmfiglu.supabase.co'
    );
    runApp(MyApp());
  }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
