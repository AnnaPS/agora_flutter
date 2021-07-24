import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';

class UserView extends StatefulWidget {
  UserView({Key? key, required this.userName, required this.role})
      : super(key: key);

  final String userName;
  final ClientRole role;

  @override
  _UserViewState createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.2,
          decoration: BoxDecoration(
            color: widget.role == ClientRole.Audience
                ? Colors.blueAccent
                : Colors.deepPurpleAccent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: widget.role == ClientRole.Audience
                  ? const Icon(Icons.people, color: Colors.white)
                  : const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(widget.userName)
      ],
    );
  }
}
