import 'package:flutter/material.dart';
import '../models/ligne_inventaire.dart';

class LigneInventaireTile extends StatelessWidget {
  final LigneInventaire ligne;
  const LigneInventaireTile({super.key, required this.ligne});

  @override
  Widget build(BuildContext context) {
    final ecart = ligne.ecart;
    final ecartColor = ecart == 0
        ? Colors.green
        : ecart > 0
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ligne.familleNom ?? '—',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (ligne.dimension != null)
                    Text(ligne.dimension!,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  if (ligne.observation != null)
                    Text(ligne.observation!,
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Théo : ${ligne.quantiteTheorique}',
                    style: const TextStyle(fontSize: 12)),
                Text('Compté : ${ligne.quantitePhysique}',
                    style: const TextStyle(fontSize: 12)),
                Text(
                  'Écart : ${ecart > 0 ? '+' : ''}$ecart',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ecartColor,
                      fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
