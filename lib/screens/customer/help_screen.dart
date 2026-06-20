import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Help & Support',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6C63FF),
                    Color(0xFF9C94FF)
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.support_agent,
                      color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'ShopFlow Support',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'We are here to help you 24/7',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '📧 support@shopflow.pk',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text('FAQs',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 12),

            ...[
              {
                'q': 'How do I track my order?',
                'a':
                'Go to Profile → My Orders to see real-time status of your orders.'
              },
              {
                'q': 'Can I cancel my order?',
                'a':
                'Yes! You can cancel orders that are in "Confirmed" status from My Orders screen.'
              },
              {
                'q': 'What payment methods are accepted?',
                'a':
                'Currently we accept Cash on Delivery (COD) for all orders.'
              },
              {
                'q': 'How long does delivery take?',
                'a':
                'Standard delivery takes 3-5 business days depending on your location.'
              },
              {
                'q': 'How do I return a product?',
                'a':
                'Contact our support team within 7 days of delivery for return assistance.'
              },
            ].map((faq) => _FaqTile(
              question: faq['q']!,
              answer: faq['a']!,
            )),

            const SizedBox(height: 24),

            const Text('About ShopFlow',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _infoRow('App Name', 'ShopFlow'),
                  _infoRow('Version', '1.0.0'),
                  _infoRow('Developer', 'ShopFlow Team'),
                  _infoRow('Contact',
                      'support@shopflow.pk'),
                  _infoRow('Location', 'Pakistan'),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile(
      {required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          _expanded ? Icons.remove : Icons.add,
          color: const Color(0xFF6C63FF),
          size: 20,
        ),
        onExpansionChanged: (val) =>
            setState(() => _expanded = val),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                16, 0, 16, 16),
            child: Text(
              widget.answer,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}