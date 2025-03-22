import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:roomeet/main.dart';

final HttpLink httpLink = HttpLink('http://10.176.0.112/query');

final ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(link: httpLink, cache: GraphQLCache(store: InMemoryStore())),
);
void main() {
  runApp(
    GraphQLProvider(
      client: client,
      child: MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false),
    ),
  );
}
