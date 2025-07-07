import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EventListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Event {
  final String id;
  final String title;
  final String description;
  final String platform;
  final DateTime date;
  final String time;
  final int duration;
  final String meetingLink;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.platform,
    required this.date,
    required this.time,
    required this.duration,
    required this.meetingLink,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      platform: json['platform'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      duration: json['duration'],
      meetingLink: json['meetingLink'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get formattedDate => DateFormat('EEE, MMM d, y').format(date);
  String get formattedTime => time;
  String get platformIcon {
    switch (platform.toLowerCase()) {
      case 'zoom':
        return 'assets/zoom.png'; // You'll need to add these assets
      case 'google meet':
        return 'assets/google_meet.png';
      default:
        return 'assets/video.png';
    }
  }

  Color get platformColor {
    switch (platform.toLowerCase()) {
      case 'zoom':
        return Colors.blue;
      case 'google meet':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }
}

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Event> events = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://your-api-url/api/events'),
        headers: {'Authorization': 'Bearer your-access-token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          events = data.map((json) => Event.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load events: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching events: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _launchMeeting(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
void _showEventDetails(Event event) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: event.platformColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  event.platformIcon,
                  width: 24,
                  height: 24,
                ),
              ),
              SizedBox(width: 10),
              Text(
                event.platform,
                style: TextStyle(
                  color: event.platformColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                DateFormat('MMM d, y').format(event.createdAt),
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            event.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Divider(),
          SizedBox(height: 15),
          Text(
            event.description,
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          SizedBox(height: 25),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey, size: 20),
              SizedBox(width: 10),
              Text(
                event.formattedDate,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.grey, size: 20),
              SizedBox(width: 10),
              Text(
                '${event.formattedTime} • ${event.duration} mins',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.link, color: Colors.grey, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  event.meetingLink,
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _launchMeeting(event.meetingLink),
              child: Text('Join Meeting'),
              style: ElevatedButton.styleFrom(
                backgroundColor: event.platformColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Events'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchEvents,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : events.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event, size: 60, color: Colors.grey),
                            SizedBox(height: 20),
                            Text(
                              'No events scheduled',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchEvents,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () => _showEventDetails(event),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: event.platformColor
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Image.asset(
                                              event.platformIcon,
                                              width: 20,
                                              height: 20,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            event.platform,
                                            style: TextStyle(
                                              color: event.platformColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Spacer(),
                                          Text(
                                            event.formattedDate,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                      Text(
                                        event.title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        event.description.length > 100
                                            ? '${event.description.substring(0, 100)}...'
                                            : event.description,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            '${event.formattedTime} • ${event.duration} mins',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Spacer(),
                                          ElevatedButton(
                                            onPressed: () =>
                                                _launchMeeting(
                                                    event.meetingLink),
                                            child: Text('Join'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}