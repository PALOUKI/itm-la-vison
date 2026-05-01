import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vision/config/constants.dart';
import 'package:vision/domain/models/message.dart';
import 'package:vision/presentation/viewmodels/child_detail_viewmodel.dart';
import 'package:vision/presentation/viewmodels/messages_viewmodel.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  final String childUuid;
  const MessagesScreen({super.key, required this.childUuid});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Tous', 'Envoyés', 'Reçus'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openComposeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ComposeMessageSheet(
        childUuid: widget.childUuid,
        onSent: () {
          ref.read(messagesStateProvider.notifier).fetchMessages();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Communication',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: _openComposeSheet,
        backgroundColor: const Color(0xFF1c3672),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.edit, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildBody(MessagesState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1e3a8a)));
    }

    if (state.isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorOrNull ?? 'Erreur'),
            TextButton(
              onPressed: () => ref.read(messagesStateProvider.notifier).fetchMessages(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final data = state.dataOrNull;
    if (data == null) return const Center(child: Text('Aucun message trouvé.'));

    // Combiner envoyés et reçus selon le filtre
    List<Message> displayMessages;
    if (_selectedFilterIndex == 1) {
      displayMessages = data.response.sent;
    } else if (_selectedFilterIndex == 2) {
      displayMessages = data.response.received;
    } else {
      displayMessages = [...data.response.received, ...data.response.sent];
      displayMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    // Filtrer par recherche
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      displayMessages = displayMessages.where((m) =>
        (m.sender?.name ?? '').toLowerCase().contains(query) ||
        m.subject.toLowerCase().contains(query)
      ).toList();
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20.sp),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ),

        // Filters
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: List.generate(
              _filters.length,
              (index) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _buildFilterChip(
                  title: _filters[index],
                  isSelected: _selectedFilterIndex == index,
                  onTap: () => setState(() => _selectedFilterIndex = index),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(messagesStateProvider.notifier).fetchMessages(),
            child: displayMessages.isEmpty
              ? ListView(children: const [
                  Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Aucun message'),
                  ))
                ])
              : ListView.separated(
                  itemCount: displayMessages.length,
                  padding: EdgeInsets.only(bottom: 96.h),
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (_, index) => _buildMessageItem(displayMessages[index]),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1c3672) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(Message msg) {
    final isSent = msg.sender?.role == 'parent';
    final contact = isSent ? msg.receiver : msg.sender;
    final contactName = contact?.name ?? 'Inconnu';
    final contactAvatar = contact?.avatar;
    final isOnline = contact?.isActive ?? false;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: const Color(0xFFE0E7FF),
                  backgroundImage: contactAvatar != null
                      ? NetworkImage('${AppConstants.storageBaseUrl}/$contactAvatar')
                      : null,
                  child: contactAvatar == null
                      ? Text(
                          contactName.isNotEmpty ? contactName[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: const Color(0xFF1c3672),
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: isOnline ? const Color(0xFF10B981) : Colors.grey.shade300,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          contactName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: Colors.black87),
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM', 'fr_FR').format(msg.createdAt),
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      if (isSent)
                        Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: Icon(Icons.send_outlined, size: 11.sp, color: Colors.grey.shade400),
                        ),
                      Expanded(
                        child: Text(
                          msg.subject,
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF1c3672), fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    msg.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet pour composer un message
class _ComposeMessageSheet extends ConsumerStatefulWidget {
  final String childUuid;
  final VoidCallback onSent;
  const _ComposeMessageSheet({required this.childUuid, required this.onSent});

  @override
  ConsumerState<_ComposeMessageSheet> createState() => _ComposeMessageSheetState();
}

class _ComposeMessageSheetState extends ConsumerState<_ComposeMessageSheet> {
  String _recipientType = 'administration'; // 'teacher' or 'administration'
  Teacher? _selectedTeacher;
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_subjectCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }
    if (_recipientType == 'teacher' && _selectedTeacher == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un professeur.')),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      final notifier = ref.read(messagesStateProvider.notifier);
      if (_recipientType == 'teacher') {
        // Récupérer le child.id (entier) depuis le provider de détail enfant
        final childState = ref.read(childDetailProvider(widget.childUuid));
        final studentId = childState.value?.id ?? 0;
        await notifier.sendToTeacher(
          teacherId: _selectedTeacher!.id,
          studentId: studentId,
          subject: _subjectCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
        );
      } else {
        await notifier.sendToAdministration(
          subject: _subjectCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSent();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message envoyé avec succès !'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final teachersAsync = ref.watch(childTeachersProvider(widget.childUuid));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              'Nouveau Message',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            SizedBox(height: 20.h),

            // Recipient type toggle
            Text('Destinataire', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildToggleBtn('Professeur', 'teacher')),
                  Expanded(child: _buildToggleBtn('Administration', 'administration')),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Teacher selector (visible only if teacher)
            if (_recipientType == 'teacher') ...[
              Text('Sélectionner un professeur', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
              SizedBox(height: 8.h),
              teachersAsync.when(
                data: (teachers) => teachers.isEmpty
                  ? Text('Aucun professeur trouvé.', style: TextStyle(color: Colors.grey, fontSize: 13.sp))
                  : Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12.r),
                        color: Colors.grey.shade50,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Teacher>(
                          isExpanded: true,
                          hint: Text('Choisir un professeur', style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500)),
                          value: _selectedTeacher,
                          items: teachers.map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.fullName, style: TextStyle(fontSize: 14.sp)),
                          )).toList(),
                          onChanged: (t) => setState(() => _selectedTeacher = t),
                        ),
                      ),
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Impossible de charger les professeurs.', style: TextStyle(color: Colors.red, fontSize: 13.sp)),
              ),
              SizedBox(height: 16.h),
            ],

            // Subject
            Text('Objet', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            SizedBox(height: 8.h),
            TextField(
              controller: _subjectCtrl,
              decoration: InputDecoration(
                hintText: 'Ex: Demande de rendez-vous',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFF1c3672), width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              ),
            ),
            SizedBox(height: 16.h),

            // Body
            Text('Message', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            SizedBox(height: 8.h),
            TextField(
              controller: _bodyCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Écrivez votre message ici...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFF1c3672), width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              ),
            ),
            SizedBox(height: 24.h),

            // Send button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1c3672),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  elevation: 0,
                ),
                icon: _isSending
                    ? SizedBox(width: 18.w, height: 18.w, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(Icons.send_rounded, size: 20.sp),
                label: Text(_isSending ? 'Envoi...' : 'Envoyer le message', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleBtn(String label, String value) {
    final isActive = _recipientType == value;
    return GestureDetector(
      onTap: () => setState(() {
        _recipientType = value;
        _selectedTeacher = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1c3672) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade600,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }
}
