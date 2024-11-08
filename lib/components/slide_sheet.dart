import 'package:flutter/material.dart';

class SlideSheet extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onDismissRequest;
  final VoidCallback onPayPayIntegration;
  final VoidCallback onLogout;

  const SlideSheet({
    super.key,
    required this.isVisible,
    required this.onDismissRequest,
    required this.onPayPayIntegration,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return isVisible
        ? Stack(
            children: [
              GestureDetector(
                onTap: onDismissRequest,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: const Offset(0, 0),
                  ).animate(
                    CurvedAnimation(
                      parent: AnimationController(
                        vsync: NavigatorState(),
                        duration: const Duration(milliseconds: 300),
                      )..forward(),
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Container(
                    width: 280,
                    height: double.infinity,
                    color: const Color(0xFFF2F2F2),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "設定",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        MenuItem(
                          text: "PayPay連携",
                          onTap: onPayPayIntegration,
                        ),
                        const Divider(),
                        MenuItem(
                          text: "ログアウト",
                          onTap: onLogout,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }
}

class MenuItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const MenuItem({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
