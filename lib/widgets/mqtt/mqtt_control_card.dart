import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/providers/mqtt_provider.dart';
import 'package:mobile_flutter_iot/utils/mqtt_dialogs.dart';
import 'package:mobile_flutter_iot/widgets/common/glass_card.dart';

class MqttControlCard extends StatelessWidget {
  final MqttProvider mqtt;

  const MqttControlCard({required this.mqtt, super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLocked = mqtt.isTimeRestricted();
    final String lockTimeStr =
        '${mqtt.startLockHour.toString().padLeft(2, '0')}:00 - '
        '${mqtt.endLockHour.toString().padLeft(2, '0')}:00';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isLocked
                  ? Colors.redAccent.withValues(alpha: 0.1)
                  : mqtt.isLedOn
                      ? Colors.yellow.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLocked
                  ? Icons.lock_clock
                  : mqtt.isLedOn
                      ? Icons.lightbulb
                      : Icons.lightbulb_outline,
              color: isLocked
                  ? Colors.redAccent
                  : mqtt.isLedOn
                      ? Colors.yellow
                      : Colors.white24,
            ),
          ),
          title: Row(
            children: [
              Text(
                isLocked ? 'LED System (Locked)' : 'Smart LED System',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon:
                    const Icon(Icons.security, size: 16, color: Colors.white38),
                onPressed: () => MqttDialogs.showSetLockPolicy(context, mqtt),
              ),
            ],
          ),
          subtitle: Text(
            isLocked
                ? 'Restricted hours ($lockTimeStr)'
                : mqtt.isLedOn
                    ? 'Active (ON)'
                    : 'Inactive (OFF)',
            style: TextStyle(
              fontSize: 11,
              color: isLocked
                  ? Colors.redAccent.withValues(alpha: 0.7)
                  : Colors.white38,
            ),
          ),
          trailing: Switch(
            value: !isLocked && mqtt.isLedOn,
            activeThumbColor: Colors.yellow,
            onChanged: (bool value) {
              if (isLocked) {
                mqtt.toggleLed();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ACCESS DENIED: System lock policy active'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } else {
                mqtt.toggleLed();
              }
            },
          ),
        ),
      ),
    );
  }
}
