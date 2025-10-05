// Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         "Event",
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                               fontSize: 10.0,
//                               fontWeight: FontWeight.w700,
//                             ),
//                       ),
//                     ),
//                     Container(
//                       width: 272,
//                       height: 48,
//                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: const Color(0xFFE8E8E8)),
//                       ),
//                       child: TextField(
//                         controller: _controller,
//                         // textAlignVertical: TextAlignVertical.center,
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Container(
//                       height: 20,
//                       width: double.infinity,
//                       color: Colors.white,
//                       alignment: Alignment.centerRight,
//                       child: _errorMessage != null
//                           ? Text(
//                               _errorMessage!,
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .labelSmall
//                                   ?.copyWith(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w300,
//                                     color: Colors.red,
//                                   ),
//                             )
//                           : null,
//                     ),
//                     const SizedBox(height: 4),
//                     // Options Section
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Column(
//                         children: [
//                           SizedBox(
//                             width: 272,
//                             height: 48,
//                             child: ListTile(
//                               contentPadding: EdgeInsets.zero,
//                               title: Text(
//                                 S.of(context)!.transferMembers,
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodyMedium
//                                     ?.copyWith(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.black),
//                               ),
//                               trailing: SizedBox(
//                                 width: 112,
//                                 height: 28,
//                                 child: ElevatedButton(
//                                   onPressed:
//                                       _isButtonEnabled ? _choiceEvent : null,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: _isTransferMode
//                                         ? const Color(0xFF76DCC6)
//                                         : const Color(0xFFECECEC),
//                                     elevation: 2,
//                                     shape: const StadiumBorder(),
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 4, vertical: 0),
//                                   ),
//                                   child: Text(
//                                     _selectedEvent?.eventName ??
//                                         S.of(context)!.selectEvent,
//                                     maxLines: 1,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .bodyMedium
//                                         ?.copyWith(
//                                           fontSize: 10,
//                                           fontWeight: FontWeight.w500,
//                                           color: _isTransferMode
//                                               ? Colors.white
//                                               : Colors.black,
//                                         ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 272,
//                             height: 48,
//                             child: ListTile(
//                               contentPadding: EdgeInsets.zero,
//                               dense: true,
//                               title: Text(
//                                 S.of(context)!.addFromLine,
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodyMedium
//                                     ?.copyWith(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.black),
//                               ),
//                               trailing: lineGroup != null
//                                   ? SizedBox(
//                                       width: 112,
//                                       height: 28,
//                                       child: ElevatedButton(
//                                         onPressed: () {},
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor:
//                                               const Color(0xFF06C755),
//                                           elevation: 2,
//                                           shape: const StadiumBorder(),
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 4, vertical: 0),
//                                         ),
//                                         child: Text(
//                                           lineGroup!.groupName,
//                                           maxLines: 1,
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyMedium
//                                               ?.copyWith(
//                                                   fontSize: 10,
//                                                   fontWeight: FontWeight.w500,
//                                                   color: Colors.white),
//                                         ),
//                                       ))
//                                   : IconButton(
//                                       icon: SvgPicture.asset(
//                                         'assets/icons/line.svg',
//                                         width: 32,
//                                         height: 32,
//                                       ),
//                                       onPressed: (_isButtonEnabled &&
//                                               !ref.watch(loadingProvider))
//                                           ? () => _selectLineGroup()
//                                           : null,
//                                     ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     SizedBox(
//                       width: 272,
//                       height: 40,
//                       child: ElevatedButton(
//                         onPressed:
//                             _isButtonEnabled ? () => _createEvent() : null,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFF2F2F2),
//                           elevation: 2,
//                           shape: const StadiumBorder(),
//                         ),
//                         child: Text(
//                           S.of(context)!.confirm,
//                           style: GoogleFonts.notoSansJp(
//                               color: Colors.black,
//                               fontSize: 14.0,
//                               fontWeight: FontWeight.w400),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
