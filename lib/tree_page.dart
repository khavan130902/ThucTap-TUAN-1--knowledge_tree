import 'dart:math';
import 'package:flutter/material.dart';
import 'messages.dart';
import 'login_page.dart';
import 'user_data.dart';

class TreePage extends StatefulWidget {
  const TreePage({super.key});

  @override
  State<TreePage> createState() => _TreePageState();
}

class _TreePageState extends State<TreePage> {
  final int totalEnvelopes = 100;
  final Random random = Random();
  late List<Offset> envelopePositions;
  int? openedIndex;

  @override
  void initState() {
    super.initState();
    envelopePositions = List.generate(
      totalEnvelopes,
          (_) => Offset(random.nextDouble(), random.nextDouble()),
    );
  }

  // 🔹 Mở phong thư thật, giảm lượt
  void _openMessage(int index) {
    final currentUser = UserData.username!;

    final msg = UserData.checkAndResetClicks(currentUser);
    if (msg.isNotEmpty && UserData.getRemainingClicks(currentUser) == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      return;
    }

    if (UserData.getRemainingClicks(currentUser) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn đã hết lượt mở hôm nay!")),
      );
      return;
    }

    final message = messages[random.nextInt(messages.length)];

    setState(() {
      openedIndex = index;
      UserData.useClick(currentUser, message); // giảm lượt và lưu lịch sử
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "💌 Thông điệp hôm nay",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              message,
              style: const TextStyle(fontSize: 18, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text("Đóng", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Xem tất cả 100 phong thư (không trừ lượt)
  void _previewAllMessages() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: ListView.builder(
            itemCount: totalEnvelopes,
            itemBuilder: (context, index) {
              final msg = messages[index % messages.length];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.mail_outline, color: Colors.blueAccent),
                  title: Text("Phong thư ${index + 1}"),
                  subtitle: Text(msg),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // 🔹 Xem lịch sử những phong thư đã mở
  void _viewHistory() {
    final history = UserData.getHistory(UserData.username!);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              final time = entry['time'] as DateTime;
              return ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(entry['message']),
                subtitle: Text(
                    "${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}:${time.second.toString().padLeft(2,'0')}"),
              );
            },
          ),
        ),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = UserData.username!;
    final remainingOpens = UserData.getRemainingClicks(currentUser);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("🌳 Cây Tri Thức"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black87),
            tooltip: "Lịch sử mở + xem tất cả",
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: _previewAllMessages,
                        child: const Text("Xem tất cả phong thư"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _viewHistory,
                        child: const Text("Xem lịch sử mở"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _logout,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const treeScale = 1.5;
            final treeWidth = constraints.maxWidth * treeScale;
            final treeHeight = constraints.maxHeight * 0.6;
            final treeLeft = (constraints.maxWidth - treeWidth) / 2;
            final treeTop = (constraints.maxHeight - treeHeight) / 2;

            return Stack(
              children: [
                // 🌳 Cây
                Positioned(
                  left: treeLeft,
                  top: treeTop,
                  width: treeWidth,
                  height: treeHeight,
                  child: Image.asset("assets/images/tree.png",
                      fit: BoxFit.contain),
                ),

                // 🎯 Badge lượt còn
                Positioned(
                  top: treeTop - 40,
                  left: (constraints.maxWidth - 120) / 2,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite, color: Colors.red, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          "Lượt còn: $remainingOpens",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),

                // ✉️ Phong thư
                ...List.generate(totalEnvelopes, (index) {
                  final isOpened = openedIndex == index;
                  final pos = envelopePositions[index];

                  final envelopeAreaWidth = treeWidth * 0.7;
                  final envelopeAreaHeight = treeHeight * 0.55;

                  final left = treeLeft +
                      (treeWidth - envelopeAreaWidth) / 2 +
                      pos.dx * envelopeAreaWidth;
                  final top =
                      treeTop + treeHeight * 0.05 + pos.dy * envelopeAreaHeight;

                  return Positioned(
                    left: left,
                    top: top,
                    child: GestureDetector(
                      onTap: () => _openMessage(index),
                      child: AnimatedScale(
                        scale: isOpened ? 1.3 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        child: Image.asset(
                          isOpened
                              ? "assets/images/envelope_open.png"
                              : "assets/images/envelope_closed.png",
                          width: 28,
                          height: 28,
                          color: isOpened
                              ? Colors.amber
                              : Colors.primaries[index % Colors.primaries.length]
                              .shade400,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
