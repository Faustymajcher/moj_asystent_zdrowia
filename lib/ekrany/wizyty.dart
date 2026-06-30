import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Wizyty extends StatefulWidget {
  const Wizyty({super.key});

  @override
  State<Wizyty> createState() {
    return _WizytyState();
  }
}

class _WizytyState extends State<Wizyty> {
  @override
  Widget build(BuildContext context) {
    int myIndex = 4;
    return Scaffold(
      appBar: AppBar(title: const Text("Wizyty lekarskie")),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Container(
          child: TableCalendar<dynamic>(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2035, 10, 16),
            focusedDay: DateTime.now(),
          ),
        ),
      ],
    );
  }
}
