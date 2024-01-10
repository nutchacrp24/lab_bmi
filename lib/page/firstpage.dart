import 'package:flutter/material.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  DateTime? selectedDate;
  String selectedGender = 'Male'; // Default gender value

  double bmiResult = 0.0;
  int age = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('โปรแกรมคำนวณ BMI'),
        backgroundColor: const Color.fromARGB(255, 179, 223, 128),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Image.network(
                'https://cdn.vectorstock.com/i/preview-1x/91/62/body-mass-index-control-pretty-young-woman-vector-41319162.jpg'),
            Text(
              'ชื่อ-สกุล',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: nameController,
            ),
            Text(
              'วันเดือนปีเกิด',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('วันเดือนปีเกิด'),
            ),
            SizedBox(height: 16),
            Text(
              'เพศ',
              style: TextStyle(fontSize: 16),
            ),
            DropdownButton<String>(
                value: selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGender = newValue!;
                  });
                },
                items: <String>['Male', 'Female', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                hint: Text('เลือกเพศ') // Added hint
                ),
            SizedBox(height: 16),
            Text(
              'น้ำหนัก: ${weightController.text} กก.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _incrementWeight();
                  },
                  child: Icon(Icons.add),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _decrementWeight();
                  },
                  child: Icon(Icons.remove),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'ส่วนสูง: ${heightController.text} ซม.',
              style: TextStyle(fontSize: 16),
            ),
            Slider(
              value: double.tryParse(heightController.text) ?? 0.0,
              onChanged: (double value) {
                _updateHeight(value);
              },
              min: 0,
              max: 250,
              divisions: 250,
              label: 'เลือกส่วนสูงของคุณ',
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                calculateBMI();
                _showResultDialog();
              },
              child: Text('คำนวณ BMI'),
            ),
          ],
        ),
      ),
    );
  }

  void _incrementWeight() {
    double currentWeight = double.tryParse(weightController.text) ?? 0.0;
    setState(() {
      weightController.text = (currentWeight + 1).toString();
    });
  }

  void _decrementWeight() {
    double currentWeight = double.tryParse(weightController.text) ?? 0.0;
    if (currentWeight > 0) {
      setState(() {
        weightController.text = (currentWeight - 1).toString();
      });
    }
  }

  void _updateHeight(double value) {
    setState(() {
      heightController.text = value.toStringAsFixed(0);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void calculateBMI() {
    double weight = double.tryParse(weightController.text) ?? 0.0;
    double height = double.tryParse(heightController.text) ?? 0.0;

    if (weight > 0 && height > 0) {
      double heightInMeters = height / 100;
      bmiResult = weight / (heightInMeters * heightInMeters);
    } else {
      bmiResult = 0.0;
    }

    calculateAge();
  }

  void calculateAge() {
    DateTime now = DateTime.now();

    if (selectedDate != null) {
      age = now.year - selectedDate!.year;

      if (now.month < selectedDate!.month ||
          (now.month == selectedDate!.month && now.day < selectedDate!.day)) {
        age--;
      }
    } else {
      age = 0;
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ผลลัพธ์ BMI'),
          backgroundColor: Color.fromARGB(255, 150, 243, 255),
          content: Column(
            children: [
              Text('ชื่อ: ${nameController.text}'),
              Text('เพศ: $selectedGender'),
              Text('อายุ: $age ปี'),
              Text('BMI: ${bmiResult.toStringAsFixed(2)}'),
              _getBMIStatus(),
              SizedBox(height: 16),
              Image.network(
                'http://images.everydayhealth.com/images/diet-nutrition/adult-body-mass-index-guide-alt-1440x810.jpg?sfvrsn=5d905d91_8',
                height: 150, // Set the desired height
                width: 300, // Set the desired width
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  Widget _getBMIStatus() {
    if (bmiResult < 18.5) {
      return Text('สถานะ: น้ำหนักน้อย/ผอม');
    } else if (bmiResult >= 18.5 && bmiResult < 24.9) {
      return Text('สถานะ: น้ำหนักปกติ');
    } else if (bmiResult >= 25 && bmiResult < 29.9) {
      return Text('สถานะ: น้ำหนักเกิน');
    } else {
      return Text('สถานะ: อ้วน');
    }
  }
}
