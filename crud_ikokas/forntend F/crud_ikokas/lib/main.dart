import 'package:crud_ikokas/bloc/crud_bloc.dart';
import 'package:crud_ikokas/bloc/crud_event.dart';
import 'package:crud_ikokas/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CrudBloc()..add(loadCrud()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}