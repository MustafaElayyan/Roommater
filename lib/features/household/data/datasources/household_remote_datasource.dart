import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/household_model.dart';
import '../models/member_model.dart';

/// Handles household Firestore reads/writes.
class HouseholdRemoteDataSource {
  HouseholdRemoteDataSource(this._firestore, this._firebaseAuth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Future<HouseholdModel> createHousehold(String name) async {
    try {
      final user = _firebaseAuth.currentUser;
      final householdRef = _firestore.collection('households').doc();
      final inviteCode = _generateInviteCode();
      final creator = await _buildMemberModel(user);

      await householdRef.set({
        'id': householdRef.id,
        'name': name,
        'inviteCode': inviteCode,
        'createdByUserId': creator.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'members': [creator.toFirestore()],
      }, SetOptions(merge: true));

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email ?? '',
          'displayName': user.displayName,
          'photoUrl': user.photoURL,
          'householdId': householdRef.id,
        }, SetOptions(merge: true));
      }

      final created = await householdRef.get();
      return HouseholdModel.fromFirestore(created);
    } on FirebaseException catch (e) {
      throw ApiException('Failed to create household.', e);
    }
  }

  Future<HouseholdModel> joinHousehold(String inviteCode) async {
    try {
      final query = await _firestore
          .collection('households')
          .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        throw const ApiException('Invalid invite code.');
      }

      final householdRef = query.docs.first.reference;
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final member = await _buildMemberModel(user);
        final current = await householdRef.get();
        final data = current.data() ?? const <String, dynamic>{};
        final members = (data['members'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(MemberModel.fromFirestore)
            .toList();
        final alreadyJoined = members.any((m) => m.uid == member.uid);
        if (!alreadyJoined) {
          members.add(member);
          await householdRef.update({
            'members': members.map((m) => m.toFirestore()).toList(),
          });
        }
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email ?? '',
          'displayName': user.displayName,
          'photoUrl': user.photoURL,
          'householdId': householdRef.id,
        }, SetOptions(merge: true));
      }

      final joined = await householdRef.get();
      return HouseholdModel.fromFirestore(joined);
    } on FirebaseException catch (e) {
      throw ApiException('Failed to join household.', e);
    }
  }

  Future<HouseholdModel> getHousehold(String id) async {
    try {
      final doc = await _firestore.collection('households').doc(id).get();
      if (!doc.exists) {
        throw const ApiException('Household not found.');
      }
      return HouseholdModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ApiException('Failed to load household.', e);
    }
  }

  Future<List<MemberModel>> getMembers(String householdId) async {
    try {
      final household = await getHousehold(householdId);
      return household.members
          .map(
            (member) => MemberModel(
              uid: member.uid,
              displayName: member.displayName,
              email: member.email,
              photoUrl: member.photoUrl,
            ),
          )
          .toList();
    } on FirebaseException catch (e) {
      throw ApiException('Failed to load members.', e);
    }
  }

  Future<void> removeMember(String householdId, String userId) async {
    try {
      final householdRef = _firestore.collection('households').doc(householdId);
      final snapshot = await householdRef.get();
      final data = snapshot.data() ?? const <String, dynamic>{};
      final members = (data['members'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .where((member) => member['uid'] != userId)
          .toList();
      await householdRef.update({'members': members});
      await _firestore.collection('users').doc(userId).set({
        'householdId': null,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ApiException('Failed to remove member.', e);
    }
  }

  Future<void> deleteHousehold(String id) async {
    try {
      await _firestore.collection('households').doc(id).delete();
    } on FirebaseException catch (e) {
      throw ApiException('Failed to delete household.', e);
    }
  }

  Future<MemberModel> _buildMemberModel(User? user) async {
    if (user == null) {
      return const MemberModel(
        uid: 'guest',
        displayName: 'Guest',
        email: 'guest@roommater.local',
      );
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? const <String, dynamic>{};
    return MemberModel(
      uid: user.uid,
      displayName: (userData['displayName'] as String?) ??
          user.displayName ??
          'Roommate',
      email: (userData['email'] as String?) ?? user.email ?? '',
      photoUrl: (userData['photoUrl'] as String?) ?? user.photoURL,
    );
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
