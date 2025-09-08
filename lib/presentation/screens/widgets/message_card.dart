import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/message_model.dart';
import '../../bloc/favorite/favorite_bloc.dart';
import '../../bloc/favorite/favorite_event.dart';
import '../../bloc/favorite/favorite_state.dart';

class MessageCard extends StatelessWidget {
  final MessageModel message;
  final VoidCallback? onFavoriteChanged;

  const MessageCard({super.key, required this.message, this.onFavoriteChanged});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FavoriteBloc, FavoriteState>(
      listener: (context, state) {
        if (onFavoriteChanged != null && state is FavoriteLoaded) {
          onFavoriteChanged!();
        }
      },
      builder: (context, state) {
        bool isFav = false;
        if (state is FavoriteLoaded) {
          isFav = state.favorites.any((m) => m.id == message.id);
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message.text,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    final bloc = BlocProvider.of<FavoriteBloc>(context);
                    if (isFav) {
                      bloc.add(RemoveFavorite(message));
                    } else {
                      bloc.add(AddFavorite(message));
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.blue),
                  onPressed: () => Share.share(message.text),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
