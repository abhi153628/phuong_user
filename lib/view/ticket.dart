import 'package:flutter/material.dart';
import 'package:phuong/view/homepage/widgets/colors.dart';
import 'package:super_ticket_package/super_ticket_package.dart';
import 'package:super_ticket_package/super_ticket_package_view.dart';

class ConcertTicketView extends StatelessWidget {
  const ConcertTicketView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A0E37), 
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A0E37),
        title: const Text(
          'Music Concert 2023',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: SuperTicket(
          itemCount: 1,
          arcColor: const Color(0xFF2A0E37),
          ticketText: 'World Tour',
          colors: const [
          AppColors.activeGreen,
            AppColors.activeGreen,
              AppColors.activeGreen,

          ],
          ticketTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          ticketTitleText: 'Music Concert 2023',
          ticketTitleTextStyle: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          firstIcon: Icons.access_time,
          firstIconsText: "5 PM, August 5, 2023",
          firstIconsTextStyle: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
          ticketHeight: MediaQuery.of(context).size.height * 0.30,
          
          secondIcon: Icons.location_on,
          secondIconsText: "Borcelle Stadium\n123 Anywhere St, Any City",
          secondIconsTextStyle: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
          onPressed: () {
            // Add your ticket action here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ticket selected!')),
            );
          },
          buttonBg: const Color(0xFFFF69B4),
          buttonBorderColor: Colors.black,
          buttonText: 'VIEW TICKET',
          buttonIcon: Icons.confirmation_number,
          buttonIconColor: Colors.black,
          buttonTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          firstIconColor: Colors.black,
          secondIconColor: Colors.black,
        ),
      ),
    );
  }
}
