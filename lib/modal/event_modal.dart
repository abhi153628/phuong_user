import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phuong/view/search_screen/search_event_card_widget.dart';

class EventModel {
  final String? eventId;
  final String? eventName;
  final String? organizerName;
  final String ?organizerId;
  final String? description;
  final double? ticketPrice;
  final String? instagramLink;
  final String? facebookLink;
  final String? email;
  final double? seatAvailabilityCount;
  final double? eventDurationTime;
  final String? specialInstruction;
  final String? location;
  final DateTime? date;
  final TimeOfDay? time;
  final String? imageUrl;
  final int? performanceType;
  final String? genreType;
  final List<String>? eventRules;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
   final bool isFree;

  EventModel({
    this.eventId,
    this.eventName,
    this.organizerName,
    this.organizerId,
    this.description,
    this.ticketPrice,
    this.instagramLink,
    this.facebookLink,
    this.email,
    this.seatAvailabilityCount,
    this.eventDurationTime,
    this.specialInstruction,
    this.location,
    this.date,
    this.time,
    this.imageUrl,
    this.performanceType,
    this.genreType,
    this.eventRules,
    this.createdAt,
    this.updatedAt,
      required this.isFree,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    // Handle the date
    DateTime? parsedDate;
    if (map['date'] != null) {
      try {
        parsedDate = DateTime.parse(map['date']);
      } catch (e) {
        parsedDate = DateTime.now();
        print('Error parsing date: $e');
      }
    }

    // Handle the time
    TimeOfDay? parsedTime;
    if (map['time'] != null) {
      try {
        parsedTime = timeOfDayFromString(map['time']);
      } catch (e) {
        parsedTime = TimeOfDay.now();
        print('Error parsing time: $e');
      }
    }

    // Handle eventRules
    List<String>? eventRules;
    if (map['eventRules'] != null) {
      eventRules = List<String>.from(map['eventRules']);
    }

    return EventModel(
      eventId: map['eventId'],
      eventName: map['eventName'],
      organizerName: map['organizerName'],
      organizerId: map['organizerId'],
      description: map['description'],
      ticketPrice: map['ticketPrice']?.toDouble(),
      instagramLink: map['instagramLink'],
      facebookLink: map['facebookLink'],
      email: map['email'],
      seatAvailabilityCount: map['seatAvailabilityCount']?.toDouble(),
      eventDurationTime: map['eventDurationTime']?.toDouble(),
      specialInstruction: map['specialInstruction'],
      location: map['location'],
      date: parsedDate,
      time: parsedTime,
      imageUrl: map['uploadedImageUrl'],
      performanceType: map['performanceType'],
      genreType: map['genreType'],
      eventRules: eventRules,
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      isFree: map['isFree'] ?? true,
    );
  }
}

// Utility function to parse a time string (e.g., "14:30") into a TimeOfDay object
TimeOfDay timeOfDayFromString(String timeString) {
  final parts = timeString.split(":");
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);
  return TimeOfDay(hour: hour, minute: minute);
}
