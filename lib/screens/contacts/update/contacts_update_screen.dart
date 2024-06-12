import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hello_nitr/core/utils/nav_to_create_pin_or_home.dart';
import 'package:hello_nitr/screens/contacts/update/widgets/loading_widget.dart';
import 'package:hello_nitr/screens/contacts/update/widgets/status_message.dart';
import 'package:hello_nitr/screens/contacts/update/widgets/success_widget.dart';
import 'package:hello_nitr/screens/contacts/update/widgets/error_dialog.dart';
import 'package:hello_nitr/controllers/contacts_update_controller.dart';
import 'package:logging/logging.dart';

class ContactsUpdateScreen extends StatefulWidget {
  @override
  _ContactsUpdateScreenState createState() => _ContactsUpdateScreenState();
}

class _ContactsUpdateScreenState extends State<ContactsUpdateScreen>
    with SingleTickerProviderStateMixin {
  final ContactsUpdateController _controller = ContactsUpdateController();
  final Logger _logger = Logger('ContactsUpdateScreen');
  double _progress = 0.0;
  bool _isLoading = true;
  int _updatedContacts = 0;
  late StreamSubscription<double> _progressSubscription;
  late StreamSubscription<String> _statusSubscription;
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _logger.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
    _logger.info('ContactsUpdateScreen initialized');

    _controller.startUpdatingContacts();
    _progressSubscription = _controller.progressStream.listen((progress) {
      setState(() {
        _progress = progress;
        _updatedContacts = (_progress * _controller.totalContacts).toInt();
        if (_progress == 1.0) {
          _isLoading = false;
          _animationController.forward();
          _logger.info('Contacts update completed');
        }
      });
    });

    _statusSubscription = _controller.statusStream.listen((status) {
      setState(() {
        _statusMessage = status;
      });
      _logger.info('Status updated: $status');
    }, onError: (error) {
      _showErrorDialog(error.toString());
      _logger.severe('Error status: $error');
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _progressSubscription.cancel();
    _statusSubscription.cancel();
    _animationController.dispose();
    _controller.dispose();
    _logger.info('ContactsUpdateScreen disposed');
    super.dispose();
  }

  void _showErrorDialog(String message) {
    _logger.warning('Showing error dialog: $message');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(
          message: message,
          onDismiss: () {
            Navigator.of(context).pop();
            _logger.info('Error dialog dismissed');
          },
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    //if contacts are not updated, dont allow back press
    if (_isLoading) {
      return false;
    }
    navigateToPinOrHome(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('Building ContactsUpdateScreen');
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatusMessage(statusMessage: _statusMessage),
                const SizedBox(height: 20),
                if (_isLoading)
                  LoadingWidget(
                    progress: _progress,
                    updatedContacts: _updatedContacts,
                    totalContacts: _controller.totalContacts,
                  )
                else
                  SuccessWidget(
                    animation: _animation,
                    updatedContacts: _updatedContacts,
                    totalContacts: _controller.totalContacts,
                    onPressed: () {
                      navigateToPinOrHome(context);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
