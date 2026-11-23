import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const ElevatorApp());
}

class ElevatorApp extends StatelessWidget {
  const ElevatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Elevator Simulator', home: const ElevatorPage());
  }
}

class ElevatorPage extends StatefulWidget {
  const ElevatorPage({super.key});

  @override
  State<ElevatorPage> createState() {
    return _ElevatorPageState();
  }
}

class _ElevatorPageState extends State<ElevatorPage> {
  static const _floorCount = 12;

  int _currentFloor = 1;
  int? _destinationFloor;
  bool _doorsOpen = false;
  bool _isMoving = false;
  Timer? _travelTimer;
  Timer? _doorTimer;

  String get _doorStatus {
    if (_isMoving) {
      if (_destinationFloor! > _currentFloor) {
        return 'MOVING UP';
      } else {
        return 'MOVING DOWN';
      }
    } else if (_doorsOpen) {
      return 'DOORS OPEN';
    } else {
      return 'DOORS CLOSED';
    }
  }

  void _selectFloor(int floor) {
    if (_isMoving) {
      setState(() => _destinationFloor = floor);
      return;
    }

    _doorTimer?.cancel();
    if (floor == _currentFloor) {
      _openDoors();
      return;
    }

    setState(() {
      _destinationFloor = floor;
      _doorsOpen = false;
      _isMoving = true;
    });

    _travelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final destination = _destinationFloor;
      if (destination == null) {
        timer.cancel();
        return;
      }

      setState(() {
        if (destination != _currentFloor) {
          _currentFloor += destination > _currentFloor ? 1 : -1;
        }
        if (_currentFloor == destination) {
          timer.cancel();
          _travelTimer = null;
          _destinationFloor = null;
          _isMoving = false;
          _doorsOpen = true;
        }
      });

      if (!_isMoving) {
        _scheduleDoorClose();
      }
    });
  }

  void _openDoors() {
    if (_isMoving) return;
    _doorTimer?.cancel();
    setState(() => _doorsOpen = true);
    _scheduleDoorClose();
  }

  void _closeDoors() {
    if (_isMoving) return;
    _doorTimer?.cancel();
    setState(() => _doorsOpen = false);
  }

  void _scheduleDoorClose() {
    _doorTimer?.cancel();
    _doorTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_isMoving) {
        setState(() => _doorsOpen = false);
      }
    });
  }

  @override
  void dispose() {
    _travelTimer?.cancel();
    _doorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Elevator Simulator',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusPanel(theme, accent),
              const SizedBox(height: 24),
              Text(
                'CHOOSE A FLOOR',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF66716E),
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _buildFloorButtons(accent),
              const SizedBox(height: 24),
              _buildDoorControls(accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPanel(ThemeData theme, Color accent) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.elevator_outlined, color: Colors.blueGrey),
              const SizedBox(width: 8),
              Text('ELEVATOR STATUS'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT FLOOR',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.blueAccent,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_currentFloor',
                      key: const ValueKey('current-floor'),
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 64,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      key: const ValueKey('door-status'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      child: Text(_doorStatus),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildElevatorDoors(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElevatorDoors() {
    return Container(
      width: 112,
      height: 142,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xFF293A36),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFF0C1714)),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: 0,
              width: _doorsOpen ? 27 : 49,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB7C7C1), Color(0xFF778A83)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: 0,
              width: _doorsOpen ? 27 : 49,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF778A83), Color(0xFFB7C7C1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            const Center(
              child: SizedBox(
                width: 2,
                height: double.infinity,
                child: ColoredBox(color: Color(0xFF53645E)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorButtons(Color accent) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _floorCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.18,
      ),
      itemBuilder: (context, index) {
        final floor = index + 1;
        final isSelected = _destinationFloor == floor;
        final isCurrent = !_isMoving && _currentFloor == floor;

        return OutlinedButton(
          key: ValueKey('floor-$floor'),
          onPressed: () => _selectFloor(floor),
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected || isCurrent ? accent : Colors.white,
            foregroundColor: isSelected || isCurrent
                ? Colors.white
                : const Color(0xFF24332F),
            side: BorderSide(
              color: isSelected || isCurrent ? accent : const Color(0xFFDCE4E0),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$floor',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isCurrent)
                const Text(
                  'YOU ARE HERE',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoorControls(Color accent) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isMoving ? null : _openDoors,
            icon: const Icon(Icons.unfold_more),
            label: const Text('OPEN DOOR'),
            style: OutlinedButton.styleFrom(
              foregroundColor: accent,
              minimumSize: const Size.fromHeight(52),
              side: BorderSide(color: accent.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: _isMoving ? null : _closeDoors,
            icon: const Icon(Icons.unfold_less),
            label: const Text('CLOSE DOOR'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF24332F),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
