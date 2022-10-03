import 'package:flutter/material.dart';

class DatePicker extends StatefulWidget {
  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {

  final weekList = [
    'Dom',
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sab',
    'Dom',
    'Seg',
    'Ter',
    'Qua'
  ];
  final dayList = [
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
    '1'
  ];
  var selected = 5;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          border: Border.all(width: 0, color: Colors.white),
        ),
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => GestureDetector(
                  onTap: () => setState(() {

                    selected = index;

                  }),
                  child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: selected == index
                            ? Colors.grey.withOpacity(0.1)
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            weekList[index],
                            style: TextStyle(
                                color: selected == index
                                    ? Colors.black
                                    : Colors.grey),
                          ),
                          SizedBox(height: 5),
                          Text(dayList[index],
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: selected == index
                                      ? Colors.black
                                      : Colors.grey))
                        ],
                      )),
                ),
            separatorBuilder: (_, index) => SizedBox(width: 5),
            itemCount: weekList.length));
  }
}
