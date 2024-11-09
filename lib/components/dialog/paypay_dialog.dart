import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PayPayDialog extends StatelessWidget {
  const PayPayDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: 296,
          height: 240,
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset("assets/icons/close_circle.svg")),
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset("assets/icons/check_circle.svg"),
                )
              ]),
              Text(
                'PayPayリンクを\n入力してください',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 30),
              // Input field
              SizedBox(
                width: 247,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
