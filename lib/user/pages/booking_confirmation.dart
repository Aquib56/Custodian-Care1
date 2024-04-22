import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingConfirmationPage extends StatefulWidget {
  final String technicianName;
  final String technicianEmail;
  final DateTime bookedTime;

  const BookingConfirmationPage({
    Key? key,
    required this.technicianName,
    required this.technicianEmail,
    required this.bookedTime,
  }) : super(key: key);

  @override
  _BookingConfirmationPageState createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  String? _bookingId;
  String? _userEmail;

  Future<void> _getUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email;
      });
    }
  }

  Future<void> _generateBookingId() async {
    final String bookingId =
        '${widget.technicianName.replaceAll(' ', '_')}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}';
    setState(() {
      _bookingId = bookingId;
    });
  }

  Future<void> _writeBookingData() async {
    if (_bookingId == null || _userEmail == null) return;

    final firestore = FirebaseFirestore.instance;
    final bookingRef = firestore.collection('Bookings').doc(_bookingId).set({
      'bookingId': _bookingId,
      'technicianName': widget.technicianName,
      'technicianEmail': widget.technicianEmail,
      'bookedTime': widget.bookedTime,
      'user': _userEmail,
      'status': false,
    });
  }

  @override
  void initState() {
    super.initState();
    _generateBookingId();
    _getUserEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Confirmation'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Booking Confirmed!',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                _bookingId != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Booking ID:',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            _bookingId!,
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : CircularProgressIndicator(),
                SizedBox(height: 16.0),
                _userEmail != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'User Name:',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            _userEmail!,
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Container(),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Technician:',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      widget.technicianName,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booked Time:',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      '${widget.bookedTime.year}-${widget.bookedTime.month.toString().padLeft(2, '0')}-${widget.bookedTime.day.toString().padLeft(2, '0')} ${widget.bookedTime.hour.toString().padLeft(2, '0')}:${widget.bookedTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    await _writeBookingData();
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
