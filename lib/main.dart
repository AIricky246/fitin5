import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Root widget of the application
/// Configures the MaterialApp with Material Design 3 theme
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App title
      title: 'Fit in 5',

      // Define the app theme with Material Design 3
      theme: ThemeData(
        // Use Material Design 3 color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),

      // Home screen of the app
      home: const MainApp(),
    );
  }
}

/// Global app state manager
class AppState {
  static final AppState _instance = AppState._internal();

  factory AppState() {
    return _instance;
  }

  AppState._internal();

  late SharedPreferences _prefs;

  // Weekly workout data (0-6 for Mon-Sun)
  List<int> weeklyWorkouts = [0, 0, 0, 0, 0, 0, 0];

  // Completed workouts today
  List<String> completedWorkoutsToday = [];

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadData();
  }

  /// Load data from SharedPreferences
  void _loadData() {
    // Load weekly workouts
    final savedWeekly = _prefs.getStringList('weeklyWorkouts');
    if (savedWeekly != null) {
      weeklyWorkouts = savedWeekly.map((e) => int.parse(e)).toList();
    }

    // Load completed workouts today
    final saved = _prefs.getStringList('completedWorkoutsToday') ?? [];
    completedWorkoutsToday = saved;
  }

  /// Save weekly workouts
  Future<void> saveWeeklyWorkouts() async {
    await _prefs.setStringList(
      'weeklyWorkouts',
      weeklyWorkouts.map((e) => e.toString()).toList(),
    );
  }

  /// Save completed workouts today
  Future<void> saveCompletedWorkouts() async {
    await _prefs.setStringList('completedWorkoutsToday', completedWorkoutsToday);
  }

  /// Add completed workout
  Future<void> addCompletedWorkout(String workoutName) async {
    completedWorkoutsToday.add(workoutName);
    await saveCompletedWorkouts();
  }

  /// Increment today's workout count
  Future<void> incrementTodayWorkouts() async {
    final today = DateTime.now().weekday - 1; // 0 = Monday
    weeklyWorkouts[today]++;
    await saveWeeklyWorkouts();
  }

  /// Reset weekly data
  Future<void> resetWeeklyData() async {
    weeklyWorkouts = [0, 0, 0, 0, 0, 0, 0];
    completedWorkoutsToday = [];
    await saveWeeklyWorkouts();
    await saveCompletedWorkouts();
  }

  /// Calculate consecutive days of workouts
  int getConsecutiveDays() {
    int consecutive = 0;
    final today = DateTime.now().weekday - 1; // 0 = Monday

    // Count backwards from today
    for (int i = today; i >= 0; i--) {
      if (weeklyWorkouts[i] > 0) {
        consecutive++;
      } else {
        break;
      }
    }

    return consecutive;
  }
}

/// Main app widget with bottom navigation
/// Manages navigation between different screens
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

/// State for MainApp
/// Tracks which screen is currently displayed
class _MainAppState extends State<MainApp> {
  // Current selected tab index
  int _selectedIndex = 0;
  // App state instance
  final appState = AppState();

  @override
  void initState() {
    super.initState();
    // Initialize app state
    appState.init().then((_) {
      setState(() {});
    });
  }

  /// Set the selected index and update the UI
  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar
      appBar: AppBar(
        title: const Text('Fit in 5'),
        centerTitle: true,
      ),

      // Body - displays different screens based on selected tab
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
            appState: appState,
            onNavigate: (index) => setState(() => _selectedIndex = index),
          ),
          WorkoutLibraryScreen(
            appState: appState,
            onNavigate: (index) => setState(() => _selectedIndex = index),
          ),
          WorkoutGeneratorScreen(
            appState: appState,
            onNavigate: (index) => setState(() => _selectedIndex = index),
          ),
          ProgressTrackerScreen(
            appState: appState,
            onDataChanged: () => setState(() {}),
            onNavigate: (index) => setState(() => _selectedIndex = index),
          ),
        ],
      ),

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle),
            label: 'Generate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}

/// HomeScreen - Welcome screen with app overview
/// Shows quick stats and navigation options
class HomeScreen extends StatelessWidget {
  final AppState appState;
  final Function(int) onNavigate;

  const HomeScreen({
    super.key,
    required this.appState,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            const Text(
              'Welcome to Fit in 5!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            const Text(
              'Quick, equipment-free bodyweight workouts for all fitness levels.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Feature cards
            const Text(
              'Features:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Feature 1: Workout Library
            _buildFeatureCard(
              icon: Icons.fitness_center,
              title: 'Workout Library',
              description: 'Browse 15+ bodyweight exercises with descriptions',
              onTap: () {
                // Navigate to Exercises tab (index 1)
                onNavigate(1);
              },
            ),
            const SizedBox(height: 12),

            // Feature 2: Workout Generator
            _buildFeatureCard(
              icon: Icons.play_circle,
              title: 'Workout Generator',
              description: 'Generate random workouts by time and difficulty',
              onTap: () {
                // Navigate to Generate tab (index 2)
                onNavigate(2);
              },
            ),
            const SizedBox(height: 12),

            // Feature 3: Progress Tracker
            _buildFeatureCard(
              icon: Icons.trending_up,
              title: 'Progress Tracker',
              description: 'Track your weekly workout completion',
              onTap: () {
                // Navigate to Progress tab (index 3)
                onNavigate(3);
              },
            ),
            const SizedBox(height: 32),

            // Call to action
            const Text(
              'Get Started:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '1. Browse exercises in the "Exercises" tab\n'
              '2. Generate a workout in the "Generate" tab\n'
              '3. Track your progress in the "Progress" tab',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget to build feature cards
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.green),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Workout model - represents a single exercise
class Workout {
  final String name;
  final String description;
  final String difficulty; // 'easy', 'medium', or 'hard'
  final int durationSeconds; // Duration in seconds
  final String instructions; // Step-by-step instructions

  Workout({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.durationSeconds,
    required this.instructions,
  });
}

/// WorkoutLibraryScreen - displays all available exercises
class WorkoutLibraryScreen extends StatefulWidget {
  final AppState appState;
  final Function(int) onNavigate;

  const WorkoutLibraryScreen({
    super.key,
    required this.appState,
    required this.onNavigate,
  });

  @override
  State<WorkoutLibraryScreen> createState() => _WorkoutLibraryScreenState();
}

class _WorkoutLibraryScreenState extends State<WorkoutLibraryScreen> {
  // Sample workout library with 15 exercises
  final List<Workout> workouts = [
    Workout(
      name: 'Push-ups',
      description: 'Classic upper body exercise',
      difficulty: 'easy',
      durationSeconds: 30,
      instructions: '1. Start in a plank position with hands shoulder-width apart\n2. Lower your body until your chest nearly touches the floor\n3. Keep your elbows close to your body\n4. Push back up to the starting position\n5. Repeat for 30 seconds',
    ),
    Workout(
      name: 'Squats',
      description: 'Lower body strength builder',
      difficulty: 'easy',
      durationSeconds: 30,
      instructions: '1. Stand with feet shoulder-width apart\n2. Lower your body by bending your knees and hips\n3. Keep your chest up and weight in your heels\n4. Go down until your thighs are parallel to the ground\n5. Push through your heels to return to standing\n6. Repeat for 30 seconds',
    ),
    Workout(
      name: 'Lunges',
      description: 'Single leg strength exercise',
      difficulty: 'easy',
      durationSeconds: 30,
      instructions: '1. Stand with feet hip-width apart\n2. Step forward with one leg\n3. Lower your body until both knees are at 90 degrees\n4. Push back to the starting position\n5. Alternate legs and repeat for 30 seconds',
    ),
    Workout(
      name: 'Plank',
      description: 'Core stability exercise',
      difficulty: 'easy',
      durationSeconds: 30,
      instructions: '1. Start in a forearm plank position\n2. Keep your body in a straight line from head to heels\n3. Engage your core and glutes\n4. Don\'t let your hips sag or pike up\n5. Hold for 30 seconds',
    ),
    Workout(
      name: 'Jumping Jacks',
      description: 'Full body cardio exercise',
      difficulty: 'easy',
      durationSeconds: 30,
      instructions: '1. Stand with feet together and arms at your sides\n2. Jump while spreading your feet shoulder-width apart\n3. Raise your arms overhead as you jump\n4. Jump back to the starting position\n5. Repeat continuously for 30 seconds',
    ),
    Workout(
      name: 'Mountain Climbers',
      description: 'Cardio and core exercise',
      difficulty: 'medium',
      durationSeconds: 30,
      instructions: '1. Start in a plank position\n2. Bring one knee toward your chest\n3. Quickly switch legs in a running motion\n4. Keep your hips level and core engaged\n5. Continue alternating for 30 seconds',
    ),
    Workout(
      name: 'Burpees',
      description: 'Full body high intensity',
      difficulty: 'medium',
      durationSeconds: 30,
      instructions: '1. Stand with feet shoulder-width apart\n2. Squat down and place hands on the floor\n3. Jump or step back into a plank position\n4. Do a push-up\n5. Jump feet back to squat position\n6. Jump up with arms overhead\n7. Repeat for 30 seconds',
    ),
    Workout(
      name: 'Tricep Dips',
      description: 'Upper body strength',
      difficulty: 'medium',
      durationSeconds: 30,
      instructions: '1. Use a chair or bench behind you\n2. Place hands on the edge, fingers pointing forward\n3. Lower your body by bending your elbows\n4. Keep elbows close to your body\n5. Push back up to the starting position\n6. Repeat for 30 seconds',
    ),
    Workout(
      name: 'High Knees',
      description: 'Cardio and leg exercise',
      difficulty: 'medium',
      durationSeconds: 30,
      instructions: '1. Stand with feet hip-width apart\n2. Run in place, lifting your knees up to hip height\n3. Pump your arms as if running\n4. Keep your core engaged\n5. Continue for 30 seconds at a fast pace',
    ),
    Workout(
      name: 'Wall Sit',
      description: 'Isometric leg exercise',
      difficulty: 'easy',
      durationSeconds: 30,
      instructions: '1. Stand with your back against a wall\n2. Slide down until your thighs are parallel to the ground\n3. Keep your back flat against the wall\n4. Hold this position for 30 seconds\n5. Keep your weight in your heels',
    ),
    Workout(
      name: 'Glute Bridges',
      description: 'Lower body and glute exercise',
      difficulty: 'easy',
      durationSeconds: 30,
      instructions: '1. Lie on your back with knees bent and feet flat\n2. Place feet hip-width apart\n3. Push through your heels to lift your hips\n4. Squeeze your glutes at the top\n5. Lower back down and repeat for 30 seconds',
    ),
    Workout(
      name: 'Leg Raises',
      description: 'Core and lower ab exercise',
      difficulty: 'medium',
      durationSeconds: 30,
      instructions: '1. Lie on your back with legs straight\n2. Keep your lower back pressed to the floor\n3. Raise both legs to about 90 degrees\n4. Lower legs without touching the floor\n5. Repeat for 30 seconds',
    ),
    Workout(
      name: 'Push-up to T',
      description: 'Upper body and core',
      difficulty: 'medium',
      durationSeconds: 30,
      instructions: '1. Start in a plank position\n2. Do a push-up\n3. At the top, rotate your body and raise one arm to the sky\n4. Return to plank and repeat on the other side\n5. Continue alternating for 30 seconds',
    ),
    Workout(
      name: 'Bicycle Crunches',
      description: 'Core and ab exercise',
      difficulty: 'easy',
      durationSeconds: 30,
      instructions: '1. Lie on your back with hands behind your head\n2. Bring one knee toward your chest\n3. Twist your torso to bring the opposite elbow to the knee\n4. Switch sides in a pedaling motion\n5. Repeat for 30 seconds',
    ),
    Workout(
      name: 'Step-ups',
      description: 'Lower body and cardio',
      difficulty: 'easy',
      durationSeconds: 30,
      instructions: '1. Stand in front of a step or bench\n2. Step up with one leg\n3. Bring the other leg up to meet it\n4. Step back down\n5. Alternate leading legs and repeat for 30 seconds',
    ),
    Workout(
      name: 'Pistol Squats',
      description: 'Advanced single leg squat',
      difficulty: 'hard',
      durationSeconds: 30,
      instructions: '1. Stand on one leg with the other leg extended forward\n2. Lower your body by bending the standing leg\n3. Keep your chest up and core engaged\n4. Go as low as you can control\n5. Push back up and repeat for 30 seconds\n6. Switch legs halfway through',
    ),
    Workout(
      name: 'Handstand Push-ups',
      description: 'Advanced upper body strength',
      difficulty: 'hard',
      durationSeconds: 30,
      instructions: '1. Start in a handstand position against a wall\n2. Lower your head toward the floor by bending your elbows\n3. Keep your body straight and core tight\n4. Push back up to the starting position\n5. Repeat for 30 seconds\n6. Modify by doing wall walks if needed',
    ),
    Workout(
      name: 'Muscle Ups',
      description: 'Advanced pulling and pushing',
      difficulty: 'hard',
      durationSeconds: 30,
      instructions: '1. Hang from a pull-up bar with hands shoulder-width apart\n2. Pull yourself up explosively\n3. Transition to a dip position at the top\n4. Push yourself up to full extension\n5. Lower back down and repeat for 30 seconds\n6. Requires significant upper body strength',
    ),
    Workout(
      name: 'Archer Push-ups',
      description: 'Advanced asymmetrical push-up',
      difficulty: 'hard',
      durationSeconds: 30,
      instructions: '1. Start in a wide plank position\n2. Lower your body toward one side\n3. The arm on that side bends while the other stays straight\n4. Push back to center\n5. Repeat on the other side\n6. Continue alternating for 30 seconds',
    ),
    Workout(
      name: 'Dragon Flags',
      description: 'Advanced core and strength',
      difficulty: 'hard',
      durationSeconds: 30,
      instructions: '1. Lie on a bench with your head at one end\n2. Hold the bench behind your head\n3. Raise your body in a straight line\n4. Lower slowly without touching the bench\n5. Repeat for 30 seconds\n6. Keep your body rigid throughout',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Back to Home and Reset buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                  ),
                  onPressed: () {
                    widget.onNavigate(0); // Navigate to Home (index 0)
                  },
                  icon: const Icon(Icons.home, color: Colors.white),
                  label: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    // Reset all completed workouts
                    widget.appState.completedWorkoutsToday.clear();
                    await widget.appState.saveCompletedWorkouts();
                    setState(() {});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All workouts reset!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Reset All',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Exercises list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              final isCompleted = widget.appState.completedWorkoutsToday.contains(workout.name);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    // Show instructions dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(workout.name),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Difficulty: ${workout.difficulty.toUpperCase()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: workout.difficulty == 'easy'
                                      ? Colors.green
                                      : workout.difficulty == 'medium'
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Description: ${workout.description}',
                                style: const TextStyle(fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'How to Perform:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(workout.instructions),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: ListTile(
                    // Icon based on difficulty
                    leading: Icon(
                      workout.difficulty == 'easy'
                          ? Icons.check_circle
                          : workout.difficulty == 'medium'
                              ? Icons.flash_on
                              : Icons.local_fire_department,
                      color: workout.difficulty == 'easy'
                          ? Colors.green
                          : workout.difficulty == 'medium'
                              ? Colors.orange
                              : Colors.red,
                    ),
                    // Workout name
                    title: Text(
                      workout.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        color: isCompleted ? Colors.grey : Colors.black,
                      ),
                    ),
                    // Description
                    subtitle: Text(workout.description),
                    // Complete button
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted ? Colors.grey : Colors.green,
                      ),
                      onPressed: () async {
                        if (!isCompleted) {
                          final ctx = context;
                          // Mark as completed
                          await widget.appState.addCompletedWorkout(workout.name);
                          await widget.appState.incrementTodayWorkouts();

                          if (mounted) {
                            setState(() {});
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text('${workout.name} completed!'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: Text(
                        isCompleted ? 'Done' : 'Complete',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// WorkoutGeneratorScreen - generates random workouts
class WorkoutGeneratorScreen extends StatefulWidget {
  final AppState appState;
  final Function(int) onNavigate;

  const WorkoutGeneratorScreen({
    super.key,
    required this.appState,
    required this.onNavigate,
  });

  @override
  State<WorkoutGeneratorScreen> createState() => _WorkoutGeneratorScreenState();
}

/// State for WorkoutGeneratorScreen
class _WorkoutGeneratorScreenState extends State<WorkoutGeneratorScreen> {
  // Selected time in minutes
  int? _selectedTime;
  // Selected difficulty
  String? _selectedDifficulty;
  // Generated workout list
  List<Workout> _generatedWorkout = [];

  // Sample workout library - same as WorkoutLibraryScreen
  late final List<Workout> _allWorkouts;

  @override
  void initState() {
    super.initState();
    // Initialize with the same workouts as WorkoutLibraryScreen
    _allWorkouts = _getWorkoutLibrary();
  }

  /// Get the complete workout library
  List<Workout> _getWorkoutLibrary() {
    return [
      Workout(
        name: 'Push-ups',
        description: 'Classic upper body exercise',
        difficulty: 'easy',
        durationSeconds: 30,
        instructions: '1. Start in a plank position with hands shoulder-width apart\n2. Lower your body until your chest nearly touches the floor\n3. Keep your elbows close to your body\n4. Push back up to the starting position\n5. Repeat for 30 seconds',
      ),
      Workout(
        name: 'Squats',
        description: 'Lower body strength builder',
        difficulty: 'easy',
        durationSeconds: 30,
        instructions: '1. Stand with feet shoulder-width apart\n2. Lower your body by bending your knees and hips\n3. Keep your chest up and weight in your heels\n4. Go down until your thighs are parallel to the ground\n5. Push through your heels to return to standing\n6. Repeat for 30 seconds',
      ),
      Workout(
        name: 'Lunges',
        description: 'Single leg strength exercise',
        difficulty: 'easy',
        durationSeconds: 30,
        instructions: '1. Stand with feet hip-width apart\n2. Step forward with one leg\n3. Lower your body until both knees are at 90 degrees\n4. Push back to the starting position\n5. Alternate legs and repeat for 30 seconds',
      ),
      Workout(
        name: 'Plank',
        description: 'Core stability exercise',
        difficulty: 'easy',
        durationSeconds: 30,
        instructions: '1. Start in a forearm plank position\n2. Keep your body in a straight line from head to heels\n3. Engage your core and glutes\n4. Don\'t let your hips sag or pike up\n5. Hold for 30 seconds',
      ),
      Workout(
        name: 'Jumping Jacks',
        description: 'Full body cardio exercise',
        difficulty: 'easy',
        durationSeconds: 30,
        instructions: '1. Stand with feet together and arms at your sides\n2. Jump while spreading your feet shoulder-width apart\n3. Raise your arms overhead as you jump\n4. Jump back to the starting position\n5. Repeat continuously for 30 seconds',
      ),
      Workout(
        name: 'Mountain Climbers',
        description: 'Cardio and core exercise',
        difficulty: 'medium',
        durationSeconds: 30,
        instructions: '1. Start in a plank position\n2. Bring one knee toward your chest\n3. Quickly switch legs in a running motion\n4. Keep your hips level and core engaged\n5. Continue alternating for 30 seconds',
      ),
      Workout(
        name: 'Burpees',
        description: 'Full body high intensity',
        difficulty: 'medium',
        durationSeconds: 30,
        instructions: '1. Stand with feet shoulder-width apart\n2. Squat down and place hands on the floor\n3. Jump or step back into a plank position\n4. Do a push-up\n5. Jump feet back to squat position\n6. Jump up with arms overhead\n7. Repeat for 30 seconds',
      ),
      Workout(
        name: 'Tricep Dips',
        description: 'Upper body strength',
        difficulty: 'medium',
        durationSeconds: 30,
        instructions: '1. Use a chair or bench behind you\n2. Place hands on the edge, fingers pointing forward\n3. Lower your body by bending your elbows\n4. Keep elbows close to your body\n5. Push back up to the starting position\n6. Repeat for 30 seconds',
      ),
      Workout(
        name: 'High Knees',
        description: 'Cardio and leg exercise',
        difficulty: 'medium',
        durationSeconds: 30,
        instructions: '1. Stand with feet hip-width apart\n2. Run in place, lifting your knees up to hip height\n3. Pump your arms as if running\n4. Keep your core engaged\n5. Continue for 30 seconds at a fast pace',
      ),
      Workout(
        name: 'Wall Sit',
        description: 'Isometric leg exercise',
        difficulty: 'easy',
        durationSeconds: 30,
        instructions: '1. Stand with your back against a wall\n2. Slide down until your thighs are parallel to the ground\n3. Keep your back flat against the wall\n4. Hold this position for 30 seconds\n5. Keep your weight in your heels',
      ),
      Workout(
        name: 'Glute Bridges',
        description: 'Lower body and glute exercise',
        difficulty: 'easy',
        durationSeconds: 30,
        instructions: '1. Lie on your back with knees bent and feet flat\n2. Place feet hip-width apart\n3. Push through your heels to lift your hips\n4. Squeeze your glutes at the top\n5. Lower back down and repeat for 30 seconds',
      ),
      Workout(
        name: 'Leg Raises',
        description: 'Core and lower ab exercise',
        difficulty: 'medium',
        durationSeconds: 30,
        instructions: '1. Lie on your back with legs straight\n2. Keep your lower back pressed to the floor\n3. Raise both legs to about 90 degrees\n4. Lower legs without touching the floor\n5. Repeat for 30 seconds',
      ),
      Workout(
        name: 'Push-up to T',
        description: 'Upper body and core',
        difficulty: 'medium',
        durationSeconds: 30,
        instructions: '1. Start in a plank position\n2. Do a push-up\n3. At the top, rotate your body and raise one arm to the sky\n4. Return to plank and repeat on the other side\n5. Continue alternating for 30 seconds',
      ),
      Workout(
        name: 'Bicycle Crunches',
        description: 'Core and ab exercise',
        difficulty: 'easy',
        durationSeconds: 30,
        instructions: '1. Lie on your back with hands behind your head\n2. Bring one knee toward your chest\n3. Twist your torso to bring the opposite elbow to the knee\n4. Switch sides in a pedaling motion\n5. Repeat for 30 seconds',
      ),
      Workout(
        name: 'Step-ups',
        description: 'Lower body and cardio',
        difficulty: 'easy',
        durationSeconds: 30,
        instructions: '1. Stand in front of a step or bench\n2. Step up with one leg\n3. Bring the other leg up to meet it\n4. Step back down\n5. Alternate leading legs and repeat for 30 seconds',
      ),
      Workout(
        name: 'Pistol Squats',
        description: 'Advanced single leg squat',
        difficulty: 'hard',
        durationSeconds: 30,
        instructions: '1. Stand on one leg with the other leg extended forward\n2. Lower your body by bending the standing leg\n3. Keep your chest up and core engaged\n4. Go as low as you can control\n5. Push back up and repeat for 30 seconds\n6. Switch legs halfway through',
      ),
      Workout(
        name: 'Handstand Push-ups',
        description: 'Advanced upper body strength',
        difficulty: 'hard',
        durationSeconds: 30,
        instructions: '1. Start in a handstand position against a wall\n2. Lower your head toward the floor by bending your elbows\n3. Keep your body straight and core tight\n4. Push back up to the starting position\n5. Repeat for 30 seconds\n6. Modify by doing wall walks if needed',
      ),
      Workout(
        name: 'Muscle Ups',
        description: 'Advanced pulling and pushing',
        difficulty: 'hard',
        durationSeconds: 30,
        instructions: '1. Hang from a pull-up bar with hands shoulder-width apart\n2. Pull yourself up explosively\n3. Transition to a dip position at the top\n4. Push yourself up to full extension\n5. Lower back down and repeat for 30 seconds\n6. Requires significant upper body strength',
      ),
      Workout(
        name: 'Archer Push-ups',
        description: 'Advanced asymmetrical push-up',
        difficulty: 'hard',
        durationSeconds: 30,
        instructions: '1. Start in a wide plank position\n2. Lower your body toward one side\n3. The arm on that side bends while the other stays straight\n4. Push back to center\n5. Repeat on the other side\n6. Continue alternating for 30 seconds',
      ),
      Workout(
        name: 'Dragon Flags',
        description: 'Advanced core and strength',
        difficulty: 'hard',
        durationSeconds: 30,
        instructions: '1. Lie on a bench with your head at one end\n2. Hold the bench behind your head\n3. Raise your body in a straight line\n4. Lower slowly without touching the bench\n5. Repeat for 30 seconds\n6. Keep your body rigid throughout',
      ),
    ];
  }

  /// Generate a random workout based on selected time and difficulty
  void _generateWorkout() {
    if (_selectedTime == null || _selectedDifficulty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both time and difficulty'),
        ),
      );
      return;
    }

    // Filter workouts by difficulty
    final filteredWorkouts = _allWorkouts
        .where((w) => w.difficulty == _selectedDifficulty)
        .toList();

    // Calculate how many exercises fit in the selected time
    final totalSeconds = _selectedTime! * 60;
    final numExercises = (totalSeconds / 30).ceil();

    // Shuffle all exercises and select the required number
    final random = Random();
    final shuffled = List<Workout>.from(filteredWorkouts);
    shuffled.shuffle(random);

    // Take only the number of exercises needed for the duration
    final generated = shuffled.take(numExercises).toList();

    setState(() {
      _generatedWorkout = generated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back to Home and Reset buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                    ),
                    onPressed: () {
                      widget.onNavigate(0); // Navigate to Home (index 0)
                    },
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedTime = null;
                        _selectedDifficulty = null;
                        _generatedWorkout = [];
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Workout reset!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Generate Your Workout',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Time selection
            const Text(
              'Select Duration:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTimeButton(5),
                const SizedBox(width: 12),
                _buildTimeButton(10),
                const SizedBox(width: 12),
                _buildTimeButton(15),
              ],
            ),
            const SizedBox(height: 24),

            // Difficulty selection
            const Text(
              'Select Difficulty:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDifficultyButton('easy', 'Easy'),
                const SizedBox(width: 12),
                _buildDifficultyButton('medium', 'Medium'),
                const SizedBox(width: 12),
                _buildDifficultyButton('hard', 'Hard'),
              ],
            ),
            const SizedBox(height: 32),

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: _generateWorkout,
                child: const Text(
                  'Generate Workout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Generated workout display
            if (_generatedWorkout.isNotEmpty) ...[
              const Text(
                'Your Workout:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _generatedWorkout.length,
                itemBuilder: (context, index) {
                  final workout = _generatedWorkout[index];
                  final isCompleted = widget.appState.completedWorkoutsToday.contains(workout.name);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCompleted ? Colors.green : Colors.grey,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        workout.name,
                        style: TextStyle(
                          decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                          color: isCompleted ? Colors.grey : Colors.black,
                        ),
                      ),
                      subtitle: Text('30 seconds'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCompleted ? Colors.grey : Colors.green,
                        ),
                        onPressed: () async {
                          if (!isCompleted) {
                            final ctx = context;
                            await widget.appState.addCompletedWorkout(workout.name);
                            await widget.appState.incrementTodayWorkouts();

                            if (mounted) {
                              setState(() {});
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text('${workout.name} completed!'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Text(
                          isCompleted ? 'Done' : 'Complete',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Complete all button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () async {
                    final ctx = context;
                    for (final workout in _generatedWorkout) {
                      if (!widget.appState.completedWorkoutsToday.contains(workout.name)) {
                        await widget.appState.addCompletedWorkout(workout.name);
                      }
                    }
                    await widget.appState.incrementTodayWorkouts();

                    if (mounted) {
                      setState(() {});
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Workout completed! Great job!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Complete All',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build time selection button
  Widget _buildTimeButton(int minutes) {
    final isSelected = _selectedTime == minutes;
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.green : Colors.grey[300],
        ),
        onPressed: () {
          setState(() {
            _selectedTime = minutes;
          });
        },
        child: Text(
          '$minutes min',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Build difficulty selection button
  Widget _buildDifficultyButton(String value, String label) {
    final isSelected = _selectedDifficulty == value;

    // Determine color based on difficulty
    Color getColor() {
      if (!isSelected) return Colors.grey[300]!;
      switch (value) {
        case 'easy':
          return Colors.green;
        case 'medium':
          return Colors.orange;
        case 'hard':
          return Colors.red;
        default:
          return Colors.green;
      }
    }

    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: getColor(),
        ),
        onPressed: () {
          setState(() {
            _selectedDifficulty = value;
          });
        },
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// ProgressTrackerScreen - shows weekly workout progress
class ProgressTrackerScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback onDataChanged;
  final Function(int) onNavigate;

  const ProgressTrackerScreen({
    super.key,
    required this.appState,
    required this.onDataChanged,
    required this.onNavigate,
  });

  @override
  State<ProgressTrackerScreen> createState() => _ProgressTrackerScreenState();
}

/// State for ProgressTrackerScreen
class _ProgressTrackerScreenState extends State<ProgressTrackerScreen> {
  final List<String> _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    // Calculate total workouts this week
    final totalWorkouts = widget.appState.weeklyWorkouts.reduce((a, b) => a + b);
    final bestDay = widget.appState.weeklyWorkouts.reduce((a, b) => a > b ? a : b);
    final daysActive = widget.appState.weeklyWorkouts.where((w) => w > 0).length;
    final consecutiveDays = widget.appState.getConsecutiveDays();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back to Home button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                ),
                onPressed: () {
                  widget.onNavigate(0); // Navigate to Home (index 0)
                },
                icon: const Icon(Icons.home, color: Colors.white),
                label: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title with reset button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weekly Progress',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset Progress?'),
                        content: const Text('This will clear all weekly data. Are you sure?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await widget.appState.resetWeeklyData();
                              widget.onDataChanged();
                              if (context.mounted) {
                                Navigator.pop(context);
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Progress reset!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Total workouts card with consecutive days badge
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Workouts This Week',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                        Text(
                          '$totalWorkouts',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Consecutive days badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: consecutiveDays > 0 ? Colors.orange[100] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: consecutiveDays > 0 ? Colors.orange : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: consecutiveDays > 0 ? Colors.orange : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            consecutiveDays > 0
                                ? '🔥 $consecutiveDays Day${consecutiveDays > 1 ? 's' : ''} Streak!'
                                : 'Start your streak today!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: consecutiveDays > 0 ? Colors.orange[800] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Daily breakdown
            const Text(
              'Daily Breakdown:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Bar chart representation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                7,
                (index) => Column(
                  children: [
                    // Bar
                    Container(
                      width: 30,
                      height: widget.appState.weeklyWorkouts[index] * 30.0,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Day label
                    Text(
                      _dayLabels[index],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Count
                    Text(
                      '${widget.appState.weeklyWorkouts[index]}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Stats
            const Text(
              'Statistics:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatCard('Average per day', (totalWorkouts / 7).toStringAsFixed(1)),
            const SizedBox(height: 12),
            _buildStatCard('Best day', '$bestDay workouts'),
            const SizedBox(height: 12),
            _buildStatCard('Days active', '$daysActive/7'),
          ],
        ),
      ),
    );
  }

  /// Build stat card
  Widget _buildStatCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
