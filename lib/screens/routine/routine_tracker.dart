import 'package:flutter/material.dart';
import 'package:glowmate_app/main.dart';
import 'package:table_calendar/table_calendar.dart';
import '../auth/login.dart'; 
import '../../models/product_model.dart';
import '../../utils/constants.dart'; // Colors
import '../../main_page.dart'; // For navigation back to Home
import 'package:intl/intl.dart';
import '../makeup/makeup.dart';
import '../product/product_browser.dart';
import '../profile/profile.dart';
import 'monthly_report.dart';

class RoutineTracker extends StatefulWidget {
  const RoutineTracker({super.key});

  @override
  State<RoutineTracker> createState() => _RoutineTrackerState();
}

class _RoutineTrackerState extends State<RoutineTracker> {
  // Calendar State
  CalendarFormat _calendarFormat = CalendarFormat.month; 
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now(); 
  
  // Master Routine List (Does not change with date)
  List<Product> _dayRoutine = [];
  List<Product> _nightRoutine = [];
  
  // Daily Logs (Changes with date)
  Set<String> _completedProductIds = {}; // Stores IDs of products checked for _selectedDay
  
  // Profile Info
  String _skinType = "Loading...";
  List<String> _skinConcerns = [];

  bool _isLoading = true;
  int _selectedIndex = 0; 

  @override
  void initState() {
    super.initState();
    _fetchMasterData(); // Fetch the static lists first
    _fetchDailyLogs(_selectedDay); // Then fetch logs for today
  }

  // --- 1. FETCH MASTER DATA (Profile & Routine List) ---
  // This runs once on startup. It gets the list of products the user has added.
  Future<void> _fetchMasterData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // A. Fetch Profile
      final profileData = await supabase.from('profiles').select('skintype, skinconcerns').eq('id', user.id).maybeSingle();
      
      // B. Fetch Master Routine List (user_routines)
      // This list is independent of the date.
      final routineData = await supabase
          .from('user_routines')
          .select('routine_type, products(*)') // Join with products table
          .eq('user_id', user.id);
      
      final List<Product> dayList = [];
      final List<Product> nightList = [];

      for (var item in routineData) {
        if (item['products'] != null) {
          final product = Product.fromSupabase(item['products']);
          if (item['routine_type'] == 'Day') { dayList.add(product); } 
          else if (item['routine_type'] == 'Night') { nightList.add(product); }
        }
      }

      if (mounted) {
        setState(() {
          if (profileData != null) {
            _skinType = profileData['skintype'] ?? 'Unknown';
            final dynamic concernsData = profileData['skinconcerns'];
            if (concernsData is List) {
               _skinConcerns = concernsData.map((e) => e.toString()).toList();
            } else {
               _skinConcerns = [];
            }
          } else {
             _skinConcerns = ['Unset']; 
          }
          _dayRoutine = dayList;
          _nightRoutine = nightList;
          // Don't set isLoading to false yet, wait for logs
        });
      }
    } catch (e) {
      print('Error loading master data: $e');
    }
  }

  // --- 2. FETCH DAILY LOGS (Ticks for a specific date) ---
  // This runs every time the user taps a new date on the calendar.
  Future<void> _fetchDailyLogs(DateTime date) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() { _isLoading = true; }); // Show spinner while switching days

    try {
      final String dateStr = DateFormat('yyyy-MM-dd').format(date);
      
      // Get all logs for this user on this specific date
      final logData = await supabase
          .from('routine_logs')
          .select('product_id')
          .eq('user_id', user.id)
          .eq('log_date', dateStr);

      // Create a set of IDs that are "done" for this day
      final Set<String> completedIds = logData.map((log) => log['product_id'].toString()).toSet();

      if (mounted) {
        setState(() {
          _completedProductIds = completedIds;
          _isLoading = false; 
        });
      }
    } catch (e) {
      print('Error loading daily logs: $e');
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  // --- 3. TOGGLE CHECKBOX LOGIC ---
  Future<void> _toggleProductCompletion(String productId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDay);
    final bool isCurrentlyCompleted = _completedProductIds.contains(productId);

    // Optimistic Update (Immediate UI feedback)
    setState(() {
      if (isCurrentlyCompleted) { _completedProductIds.remove(productId); } 
      else { _completedProductIds.add(productId); }
    });

    try {
      if (isCurrentlyCompleted) {
        // Untick: Delete the log entry
        await supabase
            .from('routine_logs')
            .delete()
            .match({'user_id': user.id, 'product_id': productId, 'log_date': dateStr});
      } else {
        // Tick: Create a log entry
        await supabase
            .from('routine_logs')
            .insert({'user_id': user.id, 'product_id': productId, 'log_date': dateStr, 'is_completed': true});
      }
    } catch (e) {
      print("Error toggling log: $e");
      // Revert UI on failure
      setState(() {
        if (isCurrentlyCompleted) { _completedProductIds.add(productId); } 
        else { _completedProductIds.remove(productId); }
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update status")));
    }
  }

  // ... (Navigation Logic remains the same) ...
  Future<void> _handleLogout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Login()));
    }
  }

  void _onNavBarTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 2) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainPage()));
    } else if (index == 4) {
      _handleLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Column(
        children: [
          // --- TOP SECTION: Header & Calendar ---
          Expanded(
            flex: 45, 
            child: Container(
              color: const Color(0xFFFFF0F5),
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: TextColor),
                              onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainPage())),
                            ),
                            const Text("Routine Tracker", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TextColor)),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 10, right: 10),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          daysOfWeekVisible: true,
                          calendarFormat: _calendarFormat, 
                          // FIX: Reduce row height slightly to fit better
                          rowHeight: 40,
                          onFormatChanged: (format) => setState(() => _calendarFormat = format),
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            if (!isSameDay(_selectedDay, selectedDay)) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                              _fetchDailyLogs(selectedDay); 
                            }
                          },
                          daysOfWeekStyle: const DaysOfWeekStyle(
                            weekdayStyle: TextStyle(fontWeight: FontWeight.w600, color: TextColor), 
                            weekendStyle: TextStyle(fontWeight: FontWeight.w600, color: PrimaryAccent)
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false, 
                            titleCentered: true, 
                            titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TextColor)
                          ),
                          calendarStyle: const CalendarStyle(
                            todayDecoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: PrimaryAccent, width: 1.5))),
                            selectedDecoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                            defaultTextStyle: TextStyle(color: TextColor),
                            weekendTextStyle: TextStyle(color: TextColor), // Added for consistency
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- BOTTOM SECTION: Routine Lists ---
          Expanded(
            flex: 55, 
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(gradient: BackgroundGradient),
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: PrimaryAccent))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    children: [
                      _buildSkinProfileCard(),
                      const SizedBox(height: 25),
                      // Pass the master list of products. The widget will check _completedProductIds to set checkboxes.
                      _buildRoutineSection("Day Routine", Icons.wb_sunny_outlined, _dayRoutine),
                      const SizedBox(height: 20),
                      _buildRoutineSection("Night Routine", Icons.nightlight_round, _nightRoutine),
                      // 3. NEW: MONTHLY SKIN REPORT SECTION
                      _buildMonthlyReportCard(),
                    ],
                  ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

// --- NEW WIDGET: Monthly Report Card ---
  Widget _buildMonthlyReportCard() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const MonthlyReport()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Using a slightly different color or border to make it look like a "Goal"
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: PrimaryAccent.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: PrimaryAccent.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // Icon / Illustration placeholder
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PrimaryAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.analytics_outlined, color: PrimaryAccent, size: 28),
            ),
            const SizedBox(width: 15),
            
            // Text
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Monthly Skin Report",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TextColor),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Rate your progress & see stats",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            // Arrow
            const Icon(Icons.arrow_forward_ios, size: 16, color: PrimaryAccent),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildSkinProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("My Skin Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TextColor)),
          const SizedBox(height: 15),
          Row(children: [const Icon(Icons.face, color: PrimaryAccent, size: 20), const SizedBox(width: 10), const Text("Skin Type: ", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)), Text(_skinType, style: const TextStyle(fontWeight: FontWeight.bold, color: TextColor, fontSize: 16))]),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: PrimaryAccent, size: 20),
              const SizedBox(width: 10),
              const Padding(
                padding: EdgeInsets.only(top: 4), 
                child: Text("Concerns: ", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
              ),
              const SizedBox(width: 5),
              Expanded( 
                child: _skinConcerns.isEmpty 
                  ? const Text("None", style: TextStyle(color: TextColor))
                  : Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _skinConcerns.map((concern) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: PrimaryAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: PrimaryAccent.withOpacity(0.3)),
                        ),
                        child: Text(concern, style: const TextStyle(fontSize: 11, color: TextColor, fontWeight: FontWeight.w500)),
                      )).toList(),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineSection(String title, IconData icon, List<Product> products) {
    return Column(
      children: [
        Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white, width: 1)), child: Row(children: [Icon(icon, color: TextColor), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TextColor))])),
        const SizedBox(height: 10),
        if (products.isEmpty) Padding(padding: const EdgeInsets.all(15.0), child: Text("No products added yet.", style: TextStyle(color: Colors.black54.withOpacity(0.5), fontStyle: FontStyle.italic))),
        ...products.map((p) {
          final String productId = p.productid;
          final isChecked = _completedProductIds.contains(productId);
          return Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(15)), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5), leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(p.image_url, width: 40, height: 40, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.image_not_supported, color: Colors.grey))), title: Text(p.productname, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TextColor, decoration: isChecked ? TextDecoration.lineThrough : null, decorationColor: PrimaryAccent)), subtitle: Text(p.brand, style: const TextStyle(fontSize: 12, color: Colors.black54)), trailing: Checkbox(value: isChecked, activeColor: PrimaryAccent, shape: const CircleBorder(), onChanged: (bool? value) { _toggleProductCompletion(productId); })));
        }),
      ],
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.black, width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavIcon(0, Icons.show_chart),
            _buildNavIcon(1, Icons.search),
            _buildHomeIcon(),
            _buildNavIcon(3, Icons.sentiment_satisfied_alt),
            _buildNavIcon(4, Icons.person_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(int index, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);

        if (index == 0) { // Routine Icon Index
         Navigator.of(context).push(
           MaterialPageRoute(builder: (context) => const RoutineTracker()),
         );
      } else if (index == 1) { // Product Browser Icon Index
         Navigator.of(context).push(
           MaterialPageRoute(builder: (context) => const ProductBrowser()),
         );
      } else if (index == 2) { // Main Page Icon Index
         Navigator.of(context).push(
           MaterialPageRoute(builder: (context) => const MainPage()),
         );
      } else if (index == 3) { // Makeup Icon Index
         Navigator.of(context).push(
           MaterialPageRoute(builder: (context) => const Makeup()),
         );
      } else if (index == 4) { // Profile Icon Index
         Navigator.of(context).push(
           MaterialPageRoute(builder: (context) => const Profile()),
         );
      }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 1.0)),
        child: Icon(icon, size: 20, color: TextColor),
      ),
    );
  }

  Widget _buildHomeIcon() {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 2),
      child: Container(
        width: 48, height: 48,
        decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        child: const Icon(Icons.home_filled, color: Colors.white, size: 26),
      ),
    );
  }
}