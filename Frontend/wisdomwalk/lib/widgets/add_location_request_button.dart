import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddLocationRequestButton extends StatelessWidget {
  const AddLocationRequestButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        context.go('/add-location-request');
      },
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.add),
    );
  }
}
