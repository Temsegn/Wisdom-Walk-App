import 'package:flutter/material.dart';

class SisterSpotlightCard extends StatelessWidget {
  const SisterSpotlightCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE8E2DB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sister Spotlight',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'Anonymous Sister',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.favorite_border,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  // Like the testimony
                },
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'After years of struggling with anxiety, I found peace through prayer and community support. This journey taught me that vulnerability is not weakness—its the path to true healing.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 15),
          Center(
            child: TextButton(
              onPressed: () {
                _showFullTestimony(context);
              },
              child: Text(
                'Read Full Testimony',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullTestimony(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sister Spotlight',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'Anonymous Sister',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Finding Peace Through Vulnerability',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              Text(
                'For years, I struggled with anxiety that seemed to control every aspect of my life. I would put on a brave face at church, pretending everything was fine, while inside I was falling apart. I was afraid that if people knew my struggles, they would think I didn\'t have enough faith.\n\nOne Sunday, after a particularly difficult week, I finally broke down and shared my struggles with a sister in my Bible study group. To my surprise, she didn\'t judge me. Instead, she shared her own journey with anxiety and how prayer and community had helped her.\n\nThat conversation was the beginning of my healing journey. I started attending a support group at church and began to be more open about my mental health challenges. I learned that vulnerability is not weakness—it\'s the path to true healing.\n\nThrough prayer, therapy, and the support of my sisters in Christ, I\'ve found a peace I never thought possible. I still have anxious days, but I no longer face them alone. I\'ve learned that God often works through community, and that sharing our struggles allows others to be the hands and feet of Jesus in our lives.\n\nIf you\'re struggling today, please know that you\'re not alone. Your vulnerability might be the key to your healing, and it might also help someone else who\'s silently fighting the same battle.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // Send virtual hug
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Virtual hug sent!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.favorite),
                    label: const Text('Send Virtual Hug'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Pray for this sister
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You\'re now praying for this sister'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.volunteer_activism),
                    label: const Text('I\'m Praying'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
