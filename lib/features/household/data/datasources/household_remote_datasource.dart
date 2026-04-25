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
      final creator = await _buildMemberModel(user, role: 'owner');

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
      final memberIds = household.members.map((member) => member.uid).toList();
      final usersById = <String, Map<String, dynamic>>{};
      for (var i = 0; i < memberIds.length; i += 10) {
        final chunk = memberIds.skip(i).take(10).toList();
        if (chunk.isEmpty) continue;
        final snapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (final doc in snapshot.docs) {
          usersById[doc.id] = doc.data();
        }
      }

      final enrichedMembers = household.members.map((member) {
        final userData = usersById[member.uid] ?? const <String, dynamic>{};
        return MemberModel(
          uid: member.uid,
          displayName:
              (userData['displayName'] as String?)?.trim().isNotEmpty == true
                  ? (userData['displayName'] as String).trim()
                  : member.displayName,
          email:
              (userData['email'] as String?)?.trim().isNotEmpty == true
                  ? (userData['email'] as String).trim()
                  : member.email,
          photoUrl: userData['photoUrl'] as String? ?? member.photoUrl,
          role: member.role,
        );
      }).toList();
      return enrichedMembers;
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

  Future<void> leaveHousehold(String householdId) async {
    try {
      final currentUid = _firebaseAuth.currentUser?.uid;
      if (currentUid == null) {
        throw const ApiException('You must be signed in to leave a household.');
      }
      final householdRef = _firestore.collection('households').doc(householdId);
      final snapshot = await householdRef.get();
      final data = snapshot.data() ?? const <String, dynamic>{};
      final existingMembers = (data['members'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final remainingMembers = existingMembers
          .where((member) => member['uid'] != currentUid)
          .toList();
      final currentOwnerId = data['createdByUserId'] as String?;

      if (remainingMembers.isEmpty) {
        // If the last member leaves, remove the household record entirely.
        await householdRef.delete();
      } else {
        String? nextOwnerId = currentOwnerId;
        if (currentOwnerId == currentUid) {
          nextOwnerId = remainingMembers.first['uid'] as String?;
        }
        final updatedMembers = remainingMembers.map((member) {
          final uid = member['uid'] as String?;
          if (uid == null) return member;
          final role = uid == nextOwnerId ? 'owner' : 'member';
          return {
            ...member,
            'role': role,
          };
        }).toList();
        await householdRef.update({
          'members': updatedMembers,
          if (nextOwnerId != null) 'createdByUserId': nextOwnerId,
        });
      }

      await _firestore.collection('users').doc(currentUid).set({
        'householdId': null,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ApiException('Failed to leave household.', e);
    }
  }

  Future<HouseholdModel> updateHouseholdName({
    required String householdId,
    required String name,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ApiException('Household name cannot be empty.');
    }
    try {
      final currentUid = _firebaseAuth.currentUser?.uid;
      if (currentUid == null) {
        throw const AuthException('You must be signed in to update household name.');
      }
      final householdRef = _firestore.collection('households').doc(householdId);
      final snapshot = await householdRef.get();
      if (!snapshot.exists) {
        throw const ApiException('Household not found.');
      }
      final data = snapshot.data() ?? const <String, dynamic>{};
      final ownerId = data['createdByUserId'] as String?;
      if (ownerId != currentUid) {
        throw const AuthException('Only the household owner can update household name.');
      }
      await householdRef.update({'name': trimmedName});
      final updated = await householdRef.get();
      return HouseholdModel.fromFirestore(updated);
    } on FirebaseException catch (e) {
      throw ApiException('Failed to update household name.', e);
    }
  }

  Future<void> deleteHousehold(String id) async {
    try {
      await _firestore.collection('households').doc(id).delete();
    } on FirebaseException catch (e) {
      throw ApiException('Failed to delete household.', e);
    }
  }

  Future<MemberModel> _buildMemberModel(
    User? user, {
    String role = 'member',
  }) async {
    if (user == null) {
      throw const ApiException(
        'You must be signed in to create or join a household.',
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
      role: role,
    );
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
