import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/complaint_model.dart';
import 'package:mobile/models/user_model.dart';
import 'package:mobile/widgets/priority_badge.dart';
import 'package:mobile/widgets/status_badge.dart';
import 'package:flutter/material.dart';

void main() {
  group('Model & Widget Tests - Doctor Grievance System', () {
    test('User model deserializes role and doctor profile correctly', () {
      final userJson = {
        'id': 6,
        'email': 'doctor.rahul@tch.telangana.gov.in',
        'role': 'Doctor',
        'full_name': 'Dr. Rahul Varma',
        'phone': '+91 98480 44441',
        'is_active': true,
        'doctor_profile': {
          'user_id': 6,
          'registration_number': 'TSMC/2020/48912',
          'specialization': 'General Medicine',
          'department': 'Internal Medicine',
          'district': 'Hyderabad',
        }
      };

      final user = User.fromJson(userJson);
      expect(user.id, 6);
      expect(user.isDoctor, true);
      expect(user.doctorProfile?.registrationNumber, 'TSMC/2020/48912');
      expect(user.doctorProfile?.specialization, 'General Medicine');
    });

    test('Complaint model deserializes properly with priority and status', () {
      final complaintJson = {
        'id': 1,
        'complaint_number': 'TCH-2026-00001',
        'doctor_id': 6,
        'category_id': 6,
        'priority': 'Critical',
        'status': 'Under Investigation',
        'subject': 'Security lapse in ICU',
        'description': 'Attendants turned aggressive without security presence.',
        'incident_date': '2026-08-24',
        'created_at': '2026-08-24T10:00:00Z',
      };

      final complaint = Complaint.fromJson(complaintJson);
      expect(complaint.complaintNumber, 'TCH-2026-00001');
      expect(complaint.priority, 'Critical');
      expect(complaint.status, 'Under Investigation');
    });

    testWidgets('StatusBadge renders correct text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: 'Under Investigation'),
          ),
        ),
      );

      expect(find.text('Under Investigation'), findsOneWidget);
    });

    testWidgets('PriorityBadge renders Critical priority', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriorityBadge(priority: 'Critical'),
          ),
        ),
      );

      expect(find.text('Critical'), findsOneWidget);
    });
  });
}
