import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phuong/modal/organizer_profile_modal.dart';
import 'package:phuong/services/chat_services/chat_service.dart';
import 'package:phuong/services/organizer_profile_firebase_service.dart';
import 'package:phuong/view/chat_section/chat_listing_screen/chat_list_bloc/chat_listing_event.dart';
import 'package:phuong/view/chat_section/chat_listing_screen/chat_list_bloc/chat_listing_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  final UserOrganizerProfileService _profileService;
  List<OrganizerProfile> _allOrganizers = [];

  ChatBloc({
    required ChatService chatService,
    required UserOrganizerProfileService profileService,
  })  : _chatService = chatService,
        _profileService = profileService,
        super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<SearchChats>(_onSearchChats);
    on<LoadOrganizers>(_onLoadOrganizers);
  }

  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final chatRooms = _chatService.getUserChatRooms();
      await _loadOrganizers();
      emit(ChatLoaded(
        organizers: _allOrganizers,
        filteredOrganizers: _allOrganizers,
        chatRooms: chatRooms,
      ));
    } catch (e) {
      emit(ChatError('Failed to load chats: ${e.toString()}'));
    }
  }

  Future<void> _onLoadOrganizers(
      LoadOrganizers event, Emitter<ChatState> emit) async {
    try {
      await _loadOrganizers();
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        emit(ChatLoaded(
          organizers: _allOrganizers,
          filteredOrganizers: _allOrganizers,
          chatRooms: currentState.chatRooms,
        ));
      }
    } catch (e) {
      emit(ChatError('Failed to load organizers: ${e.toString()}'));
    }
  }

  Future<void> _loadOrganizers() async {
    _allOrganizers = await _profileService.getAllOrganizers();
  }

  void _onSearchChats(SearchChats event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final filteredOrganizers = _allOrganizers
          .where((organizer) =>
              organizer.name.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(ChatLoaded(
        organizers: currentState.organizers,
        filteredOrganizers: filteredOrganizers,
        chatRooms: currentState.chatRooms,
      ));
    }
  }
}
