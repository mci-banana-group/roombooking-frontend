import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErrorScreen extends ConsumerStatefulWidget {
  final Widget? errorWidget;
  final String? errorTitle;
  final String? errorMessage;

  const ErrorScreen({super.key, this.errorWidget, this.errorTitle, this.errorMessage});

  @override
  ConsumerState createState() => _InvalidGroupScreenState();
}

class _InvalidGroupScreenState extends ConsumerState<ErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            widget.errorWidget == null ? Container() : widget.errorWidget!,
            SizedBox(height: 4),
            Text(
              widget.errorTitle ?? "Unknown error occurred",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 32),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(widget.errorMessage ?? "Ouuups...! That shouldn't have happened", textAlign: TextAlign.center),
            ),
            SizedBox(height: 64),
            SizedBox(
              width: 240,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Phoenix.rebirth(context);
                },
                child: Text("Back to Start", style: TextStyle(color: Colors.white, fontFamily: 'PPFormula')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
