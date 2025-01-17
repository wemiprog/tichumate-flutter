import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:tichumate/models.dart';
import 'package:tichumate/dialogs/player.dart';

class TeamForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final FormFieldSetter<String> teamNameCallback;
  final FormFieldSetter<List<Player>> playersCallback;
  final List<Player> secondaryPlayers;
  final Team team;

  TeamForm({
    required this.formKey,
    required this.team,
    required this.teamNameCallback,
    required this.playersCallback,
    required this.secondaryPlayers,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                  labelText: FlutterI18n.translate(context, 'team.team_name')),
              initialValue: team.name,
              onSaved: teamNameCallback,
            ),
            TeamPlayersSelect(
              context: context,
              initialValue: team.players,
              onSaved: playersCallback,
              secondaryPlayers: secondaryPlayers,
            ),
          ],
        ));
  }
}

class TeamPlayersSelect extends FormField<List<Player>> {
  static List<Player>? _addPlayerToList(List<Player>? list, Player player) {
    list?.add(player);
    return list;
  }

  TeamPlayersSelect({
    required FormFieldSetter<List<Player>> onSaved,
    required List<Player> initialValue,
    required List<Player> secondaryPlayers,
    required BuildContext context,
  }) : super(
            onSaved: onSaved,
            initialValue: initialValue,
            builder: (FormFieldState<List<Player>> state) {
              return Column(children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: InputDecorator(
                              decoration: InputDecoration(
                                  labelText: FlutterI18n.translate(
                                      context, 'player.players')),
                              child: Wrap(
                                spacing: 5,
                                children: state.value?.isEmpty ?? true
                                    ? [
                                        Text(FlutterI18n.translate(
                                            context, 'player.no_players'))
                                      ]
                                    : state.value!
                                        .map((player) => Chip(
                                              avatar: Text(player.icon),
                                              label: Text(player.name),
                                              onDeleted: () => state.didChange(
                                                  state
                                                      .value!
                                                      .where((item) =>
                                                          item != player)
                                                      .toList()),
                                            ))
                                        .toList(),
                              )),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 18),
                          child: IconButton(
                              icon: Icon(Icons.add_circle),
                              onPressed: () async {
                                Player? result = await PlayerDialog(context)
                                    .selectPlayer(state.value ?? [Player()],
                                        secondary: secondaryPlayers);
                                if (result?.id == null) {
                                  result = await PlayerDialog(context)
                                      .newPlayer() as Player;
                                }
                                state.didChange(_addPlayerToList(
                                    state.value, result as Player));
                              }),
                        ),
                      ],
                    ))
              ]);
            });
}
