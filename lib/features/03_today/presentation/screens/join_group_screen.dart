
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mironline/core/utils/json_utils.dart';
import 'package:mironline/services/auth_service.dart';
import 'package:mironline/services/providers.dart';

// 1. Define the state
enum GroupStatus { initial, loading, data, error, notEnrolled }

@immutable
class GroupState {
  final GroupStatus status;
  final Map<String, dynamic>? groupData;
  final String? errorMessage;

  const GroupState({
    this.status = GroupStatus.initial,
    this.groupData,
    this.errorMessage,
  });

  GroupState copyWith({
    GroupStatus? status,
    Map<String, dynamic>? groupData,
    String? errorMessage,
  }) {
    return GroupState(
      status: status ?? this.status,
      groupData: groupData ?? this.groupData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// 2. Create the Notifier
class GroupNotifier extends StateNotifier<GroupState> {
  final AuthService _authService;

  GroupNotifier(this._authService) : super(const GroupState());

  Future<void> fetchGroup() async {
    state = state.copyWith(status: GroupStatus.loading);
    try {
      final groupData = await _authService.fetchGroup();
      state = state.copyWith(status: GroupStatus.data, groupData: groupData);
    } on NotEnrolledInGroupException {
      state = state.copyWith(status: GroupStatus.notEnrolled);
    } catch (e) {
      state =
          state.copyWith(status: GroupStatus.error, errorMessage: e.toString());
    }
  }
}

// 3. Create the Provider
final groupProvider = StateNotifierProvider<GroupNotifier, GroupState>((ref) {
  return GroupNotifier(ref.watch(authServiceProvider));
});

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

// 4. Update the UI
class JoinGroupScreen extends ConsumerStatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  ConsumerState<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends ConsumerState<JoinGroupScreen> {
  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();
    // Call fetchGroup when the screen is first loaded
    Future.microtask(() => ref.read(groupProvider.notifier).fetchGroup());
  }

  Future<bool?> _showLeaveConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you really want to leave this group?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _leaveGroup() async {
    final shouldLeave = await _showLeaveConfirmationDialog();
    if (shouldLeave != true) {
      return;
    }

    setState(() {
      _isLeaving = true;
    });

    try {
      await ref.read(authServiceProvider).leaveGroup();
      ref.read(groupProvider.notifier).fetchGroup();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLeaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    String appBarTitle = 'Join a Group';
    if (groupState.status == GroupStatus.data) {
      appBarTitle = 'Group Details';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Builder(
        builder: (context) {
          switch (groupState.status) {
            case GroupStatus.loading:
            case GroupStatus.initial:
              return const Center(child: CircularProgressIndicator());
            case GroupStatus.data:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        textAlign: TextAlign.center,
                        'This is your group:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                  children: [
                                    const TextSpan(
                                      text: 'Group: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          '${groupState.groupData?['data']?['nombre_grupo'] ?? 'N/A'}',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                  children: [
                                    const TextSpan(
                                      text: 'Teacher: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          '${groupState.groupData?['data']?['maestro']?['name'] ?? 'N/A'}',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                  children: [
                                    const TextSpan(
                                      text: 'Enrollment Date: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          '${groupState.groupData?['data']?['fecha_inscripcion'] ?? 'N/A'}',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_isLeaving)
                        Center(child: const CircularProgressIndicator())
                      else
                        Center(
                          child: ElevatedButton(
                            onPressed: _leaveGroup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(
                              'Leave Group',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            case GroupStatus.notEnrolled:
              return const JoinGroupForm();
            case GroupStatus.error:
              return Center(
                  child: Text(
                      groupState.errorMessage ?? 'An unknown error occurred'));
          }
        },
      ),
    );
  }
}

class JoinGroupForm extends ConsumerStatefulWidget {
  const JoinGroupForm({super.key});

  @override
  ConsumerState<JoinGroupForm> createState() => _JoinGroupFormState();
}

class _JoinGroupFormState extends ConsumerState<JoinGroupForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await ref.read(authServiceProvider).joinGroup(_codeController.text);
        // Manually trigger a refresh
        ref.read(groupProvider.notifier).fetchGroup();
      } catch (e) {
        String errorMessage = 'An unknown error occurred.';
        if (e is Exception) {
          final message = e.toString();
          final bodyMatch = RegExp(r'Body: (.*)').firstMatch(message);
          if (bodyMatch != null) {
            final body = bodyMatch.group(1);
            try {
              final decodedBody = await compute(jsonDecode, body!);
              if (decodedBody['error'] != null &&
                  decodedBody['error']['message'] != null) {
                errorMessage = decodedBody['error']['message'];
              }
            } catch (_) {
              // Ignore if body is not a valid json
            }
          }
        }
        setState(() {
          _errorMessage = errorMessage;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _codeController,
                textAlign: TextAlign.center,
                maxLength: 8,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Enter your group code',
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a code';
                  }
                  if (value.length != 8) {
                    return 'Code must be 8 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitCode,
                      child: const Text('Join group'),
                    ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
