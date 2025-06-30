import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class LeaveReviewPage extends StatelessWidget {
  const LeaveReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Review'),
        centerTitle: true,
        leading: const BackButton(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.brown,
                  side: const BorderSide(color: Colors.brown),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Product Info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/brown_jacket.jpg',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Brown Jacket',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Size : XL  |  Qty : 10pcs',
                          style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Text('\$83.97',
                          style: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Re-Order'),
                )
              ],
            ),

            const SizedBox(height: 24),
            Text("How is your order?",
                style:
                    GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            const Text("Your overall rating",
                style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              unratedColor: Colors.grey.shade300,
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {},
            ),

            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Add detailed review',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter here',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.camera_alt_outlined, color: Colors.brown),
                const SizedBox(width: 6),
                Text('add photo',
                    style: GoogleFonts.poppins(color: Colors.brown)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
