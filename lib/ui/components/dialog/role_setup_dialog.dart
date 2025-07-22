import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mr_collection/generated/s.dart';
import 'package:mr_collection/data/model/freezed/member.dart';
import 'package:mr_collection/ui/components/dialog/role_assignment_dialog.dart';

class RoleSetupDialog extends StatefulWidget {
  final List<Member> members;
  final VoidCallback onConfirm;
  final Function(List<Map<String, dynamic>>) onRoleConfirm;
  final Map<String, String> memberRoles;
  final bool shouldRestoreDefaultRoles;
  final List<Map<String, dynamic>>? existingRoles;

  const RoleSetupDialog({
    super.key,
    required this.members,
    required this.onConfirm,
    required this.onRoleConfirm,
    required this.memberRoles,
    this.shouldRestoreDefaultRoles = false,
    this.existingRoles,
  });

  @override
  State<RoleSetupDialog> createState() => _RoleSetupDialogState();
}

class _RoleSetupDialogState extends State<RoleSetupDialog> {
  List<Map<String, dynamic>> roles = [];
  final _numFmt = NumberFormat.decimalPattern();
  bool _isAddingNewRole = false;
  final TextEditingController _newRoleNameController = TextEditingController();
  final TextEditingController _newRoleAmountController =
      TextEditingController();
  final FocusNode _newRoleNameFocusNode = FocusNode();
  final FocusNode _newRoleAmountFocusNode = FocusNode();

  // 既存ロールの金額編集用
  int? _editingRoleIndex;
  final TextEditingController _editRoleAmountController =
      TextEditingController();
  final FocusNode _editRoleAmountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 既存のロールがある場合はそれを使用、ない場合は空のリストから開始
    if (widget.existingRoles != null) {
      roles = List<Map<String, dynamic>>.from(widget.existingRoles!);
    }

    // フォーカスノードのリスナーを設定
    _newRoleNameFocusNode.addListener(() {
      if (!_newRoleNameFocusNode.hasFocus && _isAddingNewRole) {
        _handleRoleNameFocusLoss();
      }
    });

    _newRoleAmountFocusNode.addListener(() {
      if (!_newRoleAmountFocusNode.hasFocus && _isAddingNewRole) {
        _handleAmountFocusLoss();
      }
    });

    // 既存ロール金額編集用のフォーカスリスナー
    _editRoleAmountFocusNode.addListener(() {
      if (!_editRoleAmountFocusNode.hasFocus && _editingRoleIndex != null) {
        _confirmEditRoleAmount();
      }
    });
  }

  @override
  void dispose() {
    _newRoleNameController.dispose();
    _newRoleAmountController.dispose();
    _newRoleNameFocusNode.dispose();
    _newRoleAmountFocusNode.dispose();
    _editRoleAmountController.dispose();
    _editRoleAmountFocusNode.dispose();
    super.dispose();
  }

  void _initializeDefaultRoles() {
    // 既存ロールがなく、デフォルトロール復元フラグがtrueで、現在ロールが空の場合のみデフォルトロールを追加
    if (widget.existingRoles == null &&
        roles.isEmpty &&
        widget.shouldRestoreDefaultRoles) {
      roles = [
        {'role': S.of(context)!.seniorStudent, 'amount': 3000, 'members': []},
        {'role': S.of(context)!.freshmanStudent, 'amount': 1000, 'members': []},
      ];
    }
  }

  void _addRole(String roleName, int amount) {
    setState(() {
      roles.add({'role': roleName, 'amount': amount, 'members': []});
    });
  }

  void _startAddingNewRole() {
    setState(() {
      _isAddingNewRole = true;
      _newRoleNameController.text = '';
      _newRoleAmountController.text = '0';
    });
    // 次のフレームでフォーカスを設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _newRoleNameFocusNode.requestFocus();
    });
  }

  void _handleRoleNameFocusLoss() {
    // 役割名が入力されていて、金額フィールドにフォーカスが移動していない場合
    if (_newRoleNameController.text.isNotEmpty &&
        !_newRoleAmountFocusNode.hasFocus) {
      // 金額が空の場合はデフォルト値を設定
      if (_newRoleAmountController.text.isEmpty) {
        _newRoleAmountController.text = '0';
      }
      // 新しいロールを追加
      _confirmNewRole();
    } else if (_newRoleNameController.text.isEmpty) {
      // 役割名が空の場合はキャンセル
      _cancelNewRoleIfEmpty();
    }
  }

  void _handleAmountFocusLoss() {
    // 金額入力完了時の処理（特に何もしない）
    // 役割名が入力されていれば、既に _handleRoleNameFocusLoss で処理済み
  }

  void _cancelNewRoleIfEmpty() {
    if (_newRoleNameController.text.isEmpty) {
      setState(() {
        _isAddingNewRole = false;
        _newRoleNameController.clear();
        _newRoleAmountController.clear();
      });
    }
  }

  void _confirmNewRole() {
    if (_newRoleNameController.text.isNotEmpty) {
      final amount =
          int.tryParse(_newRoleAmountController.text.replaceAll(',', '')) ?? 0;
      _addRole(_newRoleNameController.text, amount);
      setState(() {
        _isAddingNewRole = false;
        _newRoleNameController.clear();
        _newRoleAmountController.clear();
      });
    }
  }

  void _startEditingRoleAmount(int index) {
    setState(() {
      _editingRoleIndex = index;
      _editRoleAmountController.text = roles[index]['amount'].toString();
    });
    // 次のフレームでフォーカスを設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editRoleAmountFocusNode.requestFocus();
    });
  }

  void _confirmEditRoleAmount() {
    if (_editingRoleIndex != null) {
      final amount =
          int.tryParse(_editRoleAmountController.text.replaceAll(',', '')) ?? 0;
      setState(() {
        roles[_editingRoleIndex!]['amount'] = amount;
        _editingRoleIndex = null;
        _editRoleAmountController.clear();
      });
    }
  }

  void _cancelEditRoleAmount() {
    setState(() {
      _editingRoleIndex = null;
      _editRoleAmountController.clear();
    });
  }

  void _showRoleInputDialog() {
    final TextEditingController roleController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context)!.roleSetup),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: roleController,
              decoration: InputDecoration(
                hintText: S.of(context)!.roleNameInput,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF75DCC6)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: S.of(context)!.enterAmount,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF75DCC6)),
                ),
                suffixText: '円',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              if (roleController.text.isNotEmpty &&
                  amountController.text.isNotEmpty) {
                _addRole(roleController.text, int.parse(amountController.text));
                Navigator.pop(context);
              }
            },
            child: Text(S.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  void _deleteRole(int index) {
    setState(() {
      roles.removeAt(index);
    });
  }

  Widget _buildNewRoleListTile() {
    return Column(
      children: [
        Container(
          child: ListTile(
            visualDensity: const VisualDensity(
              horizontal: 0,
              vertical: -2,
            ),
            dense: true,
            contentPadding: const EdgeInsets.only(left: 16, top: 2),
            title: _isAddingNewRole
                ? Row(
                    children: [
                      // 役割名入力フィールド
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            // TextFieldのタップイベントを止める
                          },
                          child: TextField(
                            controller: _newRoleNameController,
                            focusNode: _newRoleNameFocusNode,
                            decoration: const InputDecoration(
                              hintText: '役割名',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                            onSubmitted: (_) {
                              // 役割名が入力されている場合は金額フィールドにフォーカス
                              if (_newRoleNameController.text.isNotEmpty) {
                                _newRoleAmountFocusNode.requestFocus();
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 金額入力フィールド
                      GestureDetector(
                        onTap: () {
                          // TextFieldのタップイベントを止める
                        },
                        child: Container(
                          width: 68,
                          height: 36,
                          child: TextField(
                            controller: _newRoleAmountController,
                            focusNode: _newRoleAmountFocusNode,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    const BorderSide(color: Color(0xFFC6C6C8)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                            onSubmitted: (_) {
                              // Enterキーで明示的に確定する場合
                              if (_newRoleNameController.text.isNotEmpty) {
                                _confirmNewRole();
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '円',
                        style: GoogleFonts.notoSansJp(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _confirmNewRole,
                        icon: SvgPicture.asset(
                          'assets/icons/ic_next.svg',
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF75DCC6),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: _startAddingNewRole,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              S.of(context)!.roleNameInput,
                              style: GoogleFonts.notoSansJp(
                                fontSize: 14,
                                color: const Color(0xFF999999),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        const Divider(
          thickness: 1,
          height: 1,
          color: Color(0xFFE8E8E8),
        ),
      ],
    );
  }

  Map<String, String> _getCurrentMemberRoles() {
    final Map<String, String> currentMemberRoles = {};
    for (final role in roles) {
      final roleName = role['role'] as String;
      final roleMembers = role['members'] as List<dynamic>;
      for (final member in roleMembers) {
        if (member is Member) {
          currentMemberRoles[member.memberId] = roleName;
        }
      }
    }
    return currentMemberRoles;
  }

  void _showRoleAssignmentDialog(int roleIndex) {
    showDialog(
      context: context,
      builder: (context) => RoleAssignmentDialog(
        roleName: roles[roleIndex]['role'],
        members: widget.members,
        memberRoles: _getCurrentMemberRoles(),
        onAssign: (selectedMembers) {
          setState(() {
            // 他の役割から選択されたメンバーを削除
            for (int i = 0; i < roles.length; i++) {
              if (i != roleIndex) {
                final roleMembers =
                    List<Member>.from(roles[i]['members'] as List);
                roleMembers.removeWhere((member) => selectedMembers
                    .any((selected) => selected.memberId == member.memberId));
                roles[i]['members'] = roleMembers;
              }
            }
            // 現在の役割にメンバーを設定
            roles[roleIndex]['members'] = selectedMembers;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _initializeDefaultRoles();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: GestureDetector(
        onTap: () {
          // 編集モードの場合は現在の入力値で確定
          if (_editingRoleIndex != null) {
            _confirmEditRoleAmount();
          }
          if (_isAddingNewRole) {
            // 役割名が入力されている場合は確定、空の場合はキャンセル
            if (_newRoleNameController.text.isNotEmpty) {
              // 金額が空の場合はデフォルト値を設定
              if (_newRoleAmountController.text.isEmpty) {
                _newRoleAmountController.text = '0';
              }
              _confirmNewRole();
            } else {
              _cancelNewRoleIfEmpty();
            }
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.of(context)!.roleSetup,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ClipRect(
                    child: SlidableAutoCloseBehavior(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: roles.length + 1, // 新しいロール追加用に +1
                        itemBuilder: (context, index) {
                          // 最後のアイテムは新しいロール追加用
                          if (index == roles.length) {
                            return _buildNewRoleListTile();
                          }

                          final role = roles[index];
                          return Column(
                            children: [
                              Slidable(
                                key: ValueKey(role['role']),
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  extentRatio: 0.25,
                                  children: [
                                    CustomSlidableAction(
                                      onPressed: (context) {
                                        _deleteRole(index);
                                      },
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      child: SvgPicture.asset(
                                        'assets/icons/ic_slide_delete.svg',
                                        width: 18,
                                        height: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  visualDensity: const VisualDensity(
                                    horizontal: 0,
                                    vertical: -2,
                                  ),
                                  dense: true,
                                  contentPadding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 8),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          role['role'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ),
                                      _editingRoleIndex == index
                                          ? GestureDetector(
                                              onTap: () {
                                                // TextFieldのタップイベントを止める
                                              },
                                              child: Container(
                                                width: 68,
                                                height: 36,
                                                child: TextField(
                                                  controller:
                                                      _editRoleAmountController,
                                                  focusNode:
                                                      _editRoleAmountFocusNode,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.right,
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      borderSide:
                                                          const BorderSide(
                                                              color: Color(
                                                                  0xFFC6C6C8)),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 6,
                                                            vertical: 4),
                                                  ),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                  onSubmitted: (_) {
                                                    _confirmEditRoleAmount();
                                                  },
                                                  onEditingComplete: () {
                                                    _confirmEditRoleAmount();
                                                  },
                                                ),
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: () =>
                                                  _startEditingRoleAmount(
                                                      index),
                                              child: Container(
                                                width: 68,
                                                height: 36,
                                                padding: const EdgeInsets.only(
                                                    top: 4,
                                                    bottom: 4,
                                                    left: 12,
                                                    right: 6),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: const Color(
                                                          0xFFC6C6C8)),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                    _numFmt
                                                        .format(role['amount']),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge,
                                                    textAlign: TextAlign.right),
                                              ),
                                            ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '円',
                                        style: GoogleFonts.notoSansJp(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        onPressed: () =>
                                            _showRoleAssignmentDialog(index),
                                        icon: SvgPicture.asset(
                                          'assets/icons/ic_next.svg',
                                          width: 14,
                                          height: 14,
                                          colorFilter: const ColorFilter.mode(
                                            Color(0xFF75DCC6),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(
                                thickness: 1,
                                height: 1,
                                color: Color(0xFFE8E8E8),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 108,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    // 新しい役割の追加を確定
                    if (_isAddingNewRole && _newRoleNameController.text.isNotEmpty) {
                      // 金額が空の場合はデフォルト値を設定
                      if (_newRoleAmountController.text.isEmpty) {
                        _newRoleAmountController.text = '0';
                      }
                      _confirmNewRole();
                    }
                    widget.onRoleConfirm(roles);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF75DCC6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    S.of(context)!.confirm,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
