import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart'; // For date formatting

// Helper function to create a MaterialColor from a single Color value
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Castle Challenge 🏰',
      theme: ThemeData(
        primarySwatch: createMaterialColor(
          const Color(0xFFA62714),
        ), // Primary color: #a62714
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFA62714), // AppBar background color
          foregroundColor: Colors.white, // AppBar text/icon color
        ),
      ),
      home: const HomePage(), // Set HomePage as the starting screen
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Map display names to Firestore document IDs
  final Map<String, String> _userMap = {
    'Mrs. Castle 🏰': 'mrs_castle',
    'Juanjo 🔥': 'juanjo',
  };
  String?
  _selectedDisplayName; // Variable to hold the currently selected user's display name

  String _currentWinner = 'Cargando...'; // To display the winner's name
  int _winnerPoints = 0; // To display the winner's points

  @override
  void initState() {
    super.initState();
    _selectedDisplayName =
        'Mrs. Castle 🏰'; // Initialize with the first user option
    _fetchWinner(); // Fetch winner when the page initializes
  }

  // Function to fetch the user with the most total_points
  Future<void> _fetchWinner() async {
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy(
            'total_points',
            descending: true,
          ) // Order by points descending
          .limit(1) // Get only the top user
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        final winnerDoc = usersSnapshot.docs.first;
        final data = winnerDoc.data() as Map<String, dynamic>;

        // You need to map the Firestore ID back to the display name
        // This assumes 'mrs_castle' and 'juanjo' are the document IDs
        // And the map provides their display names.
        String winnerId = winnerDoc.id;
        String winnerDisplayName = _userMap.keys.firstWhere(
          (key) => _userMap[key] == winnerId,
          orElse: () => 'Desconocido', // Fallback if ID not found in map
        );

        setState(() {
          _currentWinner = winnerDisplayName;
          _winnerPoints = data['total_points'] ?? 0;
        });
      } else {
        setState(() {
          _currentWinner = 'N/A';
          _winnerPoints = 0;
        });
      }
    } catch (e) {
      print("Error fetching winner: $e");
      if (mounted) {
        setState(() {
          _currentWinner = 'Error';
          _winnerPoints = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el ganador.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Castle Challenge',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
            Text(
              '(book edition)',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.normal,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '🏰', // The castle emoji
              style: TextStyle(fontSize: 100),
            ),
            const SizedBox(height: 50),

            // Display Current Winner
            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber[300]!, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '¡Líder Actual! 👑',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_currentWinner con $_winnerPoints puntos',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Adjust spacing as needed

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.blueGrey[200]!,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDisplayName,
                      dropdownColor: Colors.blueGrey[100],
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.blueGrey[700],
                      ),
                      style: TextStyle(
                        color: Colors.blueGrey[900],
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDisplayName = newValue;
                        });
                      },
                      items: _userMap.keys.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 25),

                ElevatedButton(
                  onPressed: () {
                    if (_selectedDisplayName != null) {
                      final String? userId = _userMap[_selectedDisplayName];
                      if (userId != null) {
                        print(
                          'Selected User Display Name: $_selectedDisplayName, Firestore ID: $userId',
                        );
                        // Navigate to UserDetailPage, passing the selected user ID
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailPage(
                              userId: userId,
                              displayName: _selectedDisplayName!,
                            ),
                          ),
                        ).then((_) {
                          // When returning from UserDetailPage, refetch winner
                          _fetchWinner();
                        });
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a user!'),
                          backgroundColor: Theme.of(context).primaryColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.all(20),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC3300), // Button color
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFFA62714).withOpacity(0.5),
                  ),
                  child: const Text(
                    'Acceder',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// UserDetailPage Widget (remains unchanged from previous version)
class UserDetailPage extends StatefulWidget {
  final String userId; // User ID passed from the HomePage
  final String displayName; // Display name for UI

  const UserDetailPage({
    super.key,
    required this.userId,
    required this.displayName,
  });

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  int _totalPoints = 0; // Changed from _gymSessions to _totalPoints
  DateTime? _lastSessionDate; // To store the last session date from Firestore
  Map<String, dynamic> _sessionDates =
      {}; // Map to store all recorded session dates
  // New map to store rest day dates
  Map<String, dynamic> _restDayDates = {};
  // Track if a rest day has been used this week
  DateTime? _lastRestDayUsed;

  int _currentStreak = 0;
  int _longestStreak = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch all user data, including last session date
  }

  // Helper to normalize dates for comparison (ignore time part)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Function to calculate current and longest streak
  void _calculateStreaks() {
    // Combine session and rest days to calculate the streak
    Map<String, dynamic> combinedDates = {};
    combinedDates.addAll(_sessionDates);
    combinedDates.addAll(_restDayDates);

    if (combinedDates.isEmpty) {
      _currentStreak = 0;
      _longestStreak = 0;
      return;
    }

    // Convert keys from string to DateTime and sort them
    List<DateTime> sortedDates =
        combinedDates.keys
            .map((dateString) => DateTime.parse(dateString))
            .map(_normalizeDate)
            .toSet() // Remove duplicates in case of data inconsistencies
            .toList()
          ..sort();

    if (sortedDates.isEmpty) {
      _currentStreak = 0;
      _longestStreak = 0;
      return;
    }

    int currentStreakCount = 0;
    int longestStreakCount = 0;
    DateTime? lastDateInSequence;
    final DateTime today = _normalizeDate(DateTime.now());
    final DateTime yesterday = _normalizeDate(
      today.subtract(const Duration(days: 1)),
    );

    // Logic for current streak
    if (sortedDates.contains(today)) {
      currentStreakCount = 1;
      DateTime tempDate = today.subtract(const Duration(days: 1));
      while (sortedDates.contains(tempDate)) {
        currentStreakCount++;
        tempDate = tempDate.subtract(const Duration(days: 1));
      }
    } else if (sortedDates.contains(yesterday)) {
      currentStreakCount = 1;
      DateTime tempDate = yesterday.subtract(const Duration(days: 1));
      while (sortedDates.contains(tempDate)) {
        currentStreakCount++;
        tempDate = tempDate.subtract(const Duration(days: 1));
      }
    } else {
      currentStreakCount = 0;
    }

    // Logic for longest streak
    longestStreakCount = 0;
    int tempLongest = 0;
    lastDateInSequence = null;

    for (int i = 0; i < sortedDates.length; i++) {
      DateTime currentDate = sortedDates[i];
      if (lastDateInSequence == null ||
          _normalizeDate(currentDate) ==
              _normalizeDate(
                lastDateInSequence!,
              ).add(const Duration(days: 1))) {
        tempLongest++;
      } else if (_normalizeDate(currentDate) !=
          _normalizeDate(lastDateInSequence!)) {
        // Gap found (not consecutive and not the same day as previous)
        longestStreakCount = max(longestStreakCount, tempLongest);
        tempLongest = 1; // Start new streak
      }
      lastDateInSequence = currentDate;
    }
    longestStreakCount = max(
      longestStreakCount,
      tempLongest,
    ); // Account for the last streak

    _currentStreak = currentStreakCount;
    _longestStreak = longestStreakCount;
  }

  // A utility to find the maximum of two numbers
  int max(int a, int b) {
    return a > b ? a : b;
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _totalPoints = data['total_points'] ?? 0; // Fetch total_points
          final Timestamp? lastSessionTimestamp =
              data['last_session_date'] as Timestamp?;
          _lastSessionDate = lastSessionTimestamp?.toDate();
          _sessionDates = Map<String, dynamic>.from(
            data['gym_session_dates'] ?? {},
          );
          // Fetch rest day dates
          _restDayDates = Map<String, dynamic>.from(
            data['rest_day_dates'] ?? {},
          );
          final Timestamp? lastRestDayTimestamp =
              data['last_rest_day_used'] as Timestamp?;
          _lastRestDayUsed = lastRestDayTimestamp?.toDate();
          _calculateStreaks(); // Recalculate streaks after fetching data
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los datos del usuario.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // New function to handle adding a rest day
  Future<void> _addRestDay() async {
    final DateTime today = _normalizeDate(DateTime.now());
    final String todayString = DateFormat('yyyy-MM-dd').format(today);

    // Check if a session or a rest day has already been added today
    if (_sessionDates.containsKey(todayString) ||
        _restDayDates.containsKey(todayString)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ya has registrado una sesión o día de descanso hoy.',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Check if a rest day has already been used this week
    if (_lastRestDayUsed != null) {
      // Find the start of the week for the last rest day
      DateTime startOfLastWeek = _normalizeDate(
        _lastRestDayUsed!.subtract(
          Duration(days: _lastRestDayUsed!.weekday - 1),
        ),
      );
      // Find the start of the current week (Monday)
      DateTime startOfThisWeek = _normalizeDate(
        today.subtract(Duration(days: today.weekday - 1)),
      );

      if (startOfLastWeek.isAtSameMomentAs(startOfThisWeek)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ya usaste tu día de descanso esta semana. Resetea el lunes.',
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(20),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    }

    try {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId);

      await userRef.update({
        'rest_day_dates.$todayString': true, // Add today's date as a rest day
        'last_rest_day_used': Timestamp.fromDate(today),
      });

      setState(() {
        _restDayDates[todayString] = true;
        _lastRestDayUsed = today;
        _calculateStreaks();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Día de descanso registrado para ${widget.displayName}!',
            ),
            backgroundColor: Colors.blueAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error adding rest day: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar el día de descanso.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _addGymSession() async {
    try {
      final DateTime today = _normalizeDate(DateTime.now());
      final String todayString = DateFormat('yyyy-MM-dd').format(today);

      // Check if a session has already been added today
      if (_sessionDates.containsKey(todayString)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ya has registrado una sesión de lectura hoy.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(20),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return; // Exit the function if session already added today
      }

      // Determine points based on the day of the week
      // DateTime.sunday is 7, Monday is 1, ..., Saturday is 6
      int pointsToAdd = (today.weekday == DateTime.sunday) ? 2 : 1;

      // Get a reference to the user's document
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId);

      // Prepare updates: increment total points, update last session date, and add today's date to map
      await userRef.update({
        'total_points': FieldValue.increment(
          pointsToAdd,
        ), // Increment total_points
        'last_session_date': Timestamp.fromDate(today),
        'gym_session_dates.$todayString': true, // Add today's date to the map
      });

      // Update local state to reflect the change immediately
      setState(() {
        _totalPoints += pointsToAdd; // Update local total points
        _lastSessionDate = today;
        _sessionDates[todayString] = true; // Update local map
        _calculateStreaks(); // Recalculate streaks after adding session
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡$pointsToAdd puntos agregados para ${widget.displayName}!',
            ), // Show points added
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error adding reading session: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar la sesión de lectura.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the deadline date (August 15th, 2025)
    final DateTime deadlineDate = _normalizeDate(DateTime(2025, 12, 20));

    final DateTime startDate = _normalizeDate(DateTime(2025, 9, 25));

    // final DateTime yesterday = _normalizeDate(
    //   DateTime.now().subtract(const Duration(days: 1)),
    // );

    // Generate dates from yesterday up to the deadline
    List<DateTime> displayDates = [];
    DateTime currentDate = startDate;
    while (currentDate.isBefore(deadlineDate) ||
        currentDate.isAtSameMomentAs(deadlineDate)) {
      displayDates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Determine the ideal fixed width for the calendar
    const double bubbleSize = 22.0;
    const double spacing = 2.0;
    const int crossAxisCount = 7;
    const double calendarFixedWidth =
        (bubbleSize * crossAxisCount) + (spacing * (crossAxisCount - 1));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(widget.displayName)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // const Spacer(), // Pushes the following content to the center/bottom
          // Centered section starts here
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Puntos Totales: $_totalPoints 🪙', // Changed to Total Points
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                // Row for the buttons
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addGymSession,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Agregar Sesión de Lectura'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC3300),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                    ),
                    const SizedBox(height: 10), // Space between buttons
                    ElevatedButton.icon(
                      onPressed: _addRestDay,
                      icon: const Icon(Icons.bedtime_outlined),
                      label: const Text('Día de Descanso'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, // Blue for rest day
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Space before streak info
                Text(
                  'Racha Actual: $_currentStreak días 🔥',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                Text(
                  'Racha Más Larga: $_longestStreak días',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                // Monthly Streak Viewer (fixed size compact calendar)
                Container(
                  width: calendarFixedWidth + 20,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Progreso hasta el 20 de diciembre',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: spacing,
                              mainAxisSpacing: spacing,
                              childAspectRatio: 1.0,
                            ),
                        itemCount: displayDates.length,
                        itemBuilder: (context, index) {
                          DateTime date = displayDates[index];
                          String dateString = DateFormat(
                            'yyyy-MM-dd',
                          ).format(date);
                          bool hasSession = _sessionDates.containsKey(
                            dateString,
                          );
                          // Check if it's a rest day
                          bool isRestDay = _restDayDates.containsKey(
                            dateString,
                          );
                          bool isToday =
                              _normalizeDate(date) ==
                              _normalizeDate(DateTime.now());
                          bool isPastDate = date.isBefore(
                            _normalizeDate(DateTime.now()),
                          );

                          Color bubbleColor;
                          Color textColor;
                          Border? border;

                          if (hasSession) {
                            bubbleColor = Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.8);
                            textColor = Colors.white;
                          }
                          // New color logic for rest day
                          else if (isRestDay) {
                            bubbleColor = Colors.blueAccent.withOpacity(0.8);
                            textColor = Colors.white;
                          } else if (isToday) {
                            bubbleColor = Colors.yellow[200]!;
                            textColor = Colors.blueGrey[800]!;
                            border = Border.all(
                              color: Colors.blueAccent,
                              width: 2,
                            );
                          } else if (isPastDate) {
                            bubbleColor = Colors.grey[200]!;
                            textColor = Colors.grey[600]!;
                          } else {
                            bubbleColor = Colors.blueGrey[50]!;
                            textColor = Colors.blueGrey[400]!;
                          }

                          return Container(
                            width: bubbleSize,
                            height: bubbleSize,
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              shape: BoxShape.circle,
                              border: border,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${date.day}',
                              style: GoogleFonts.montserrat(
                                color: textColor,
                                fontWeight: hasSession || isToday || isRestDay
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Lun-Sab: 1 punto. Dom: 2 puntos. Puedes añadir un día de descanso a la semana (se resetea los lunes).",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
