import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'config/theme_config.dart';
import 'services/auction_service.dart';
import 'screens/auction_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  runApp(const EquilendAuctionApp());
}

class EquilendAuctionApp extends StatelessWidget {
  const EquilendAuctionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuctionService(),
      child: MaterialApp(
        title: 'Equilend Auction',
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig.darkTheme,
        home: const AuctionScreen(),
      ),
    );
  }
}
