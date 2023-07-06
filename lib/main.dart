import "package:flutter/material.dart";
import "package:to_memo/home.dart";
void main()=>runApp(const MyApp());
class MyApp extends StatelessWidget{
  const MyApp({super.key});
  @override
  MaterialApp build(final BuildContext context)
  => MaterialApp(home:Home());
}