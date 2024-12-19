import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String? bookingId;
  
  final String eventId;
  final String userId;
  final String userName;
   
  final int seatsBooked;
  final double totalPrice;
  final DateTime bookingTime;
  final String eventName;
  final String organizerId;

  BookingModel({
    this.bookingId,
    required this.eventId,
    required this.userId,
    required this.userName,
    
    required this.seatsBooked,
    required this.totalPrice,
    required this.bookingTime,
    required this.eventName,
    required this.organizerId,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
    
      'seatsBooked': seatsBooked,
      'totalPrice': totalPrice,
      'bookingTime': bookingTime,
      'eventName': eventName,
      'organizerId': organizerId,
    };
  }

  // Create from Firestore document
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      bookingId: map['bookingId'],
      eventId: map['eventId'],
      userId: map['userId'],
      userName: map['userName'] ?? 'Unknown User',
   
      seatsBooked: map['seatsBooked'],
      totalPrice: map['totalPrice'],
      bookingTime: (map['bookingTime'] as Timestamp).toDate(),
      eventName: map['eventName'],
      organizerId: map['organizerId'],
    );
  }
}