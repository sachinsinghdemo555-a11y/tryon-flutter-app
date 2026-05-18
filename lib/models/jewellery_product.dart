enum JewelleryCategory { sets, necklaces, earrings, rings, bangles, custom }

class JewelleryProduct {
  final String id;
  final String name;
  final String type;
  final String emoji;
  final String description;
  final JewelleryCategory category;

  const JewelleryProduct({
    required this.id,
    required this.name,
    required this.type,
    required this.emoji,
    required this.description,
    required this.category,
  });

  // ── Full Jewellery Sets ───────────────────────────────────────────────────
  static const List<JewelleryProduct> sets = [
    JewelleryProduct(
      id: 's1',
      name: 'Royal Bridal Set',
      type: 'full jewellery set',
      emoji: '👑',
      category: JewelleryCategory.sets,
      description:
          'Grand bridal set: heavy 22kt gold Kundan choker necklace with layered chains, '
          'matching chandelier jhumka earrings, gold bangles on both wrists, and a maang tikka. '
          'Rich red and green enamel work with polki diamonds.',
    ),
    JewelleryProduct(
      id: 's2',
      name: 'Diamond Elegance Set',
      type: 'full jewellery set',
      emoji: '💎',
      category: JewelleryCategory.sets,
      description:
          'Contemporary 18kt white gold set: multi-strand diamond necklace with a large solitaire '
          'pendant, matching brilliant-cut diamond drop earrings, a tennis bracelet, '
          'and a diamond cocktail ring. Clean modern lines with VS1 clarity stones.',
    ),
    JewelleryProduct(
      id: 's3',
      name: 'Pearl & Gold Classics',
      type: 'full jewellery set',
      emoji: '🌟',
      category: JewelleryCategory.sets,
      description:
          'Timeless 22kt gold set: three-strand baroque pearl necklace with gold beads, '
          'pearl cluster drop earrings, a delicate gold bangle, and a pearl-set cocktail ring. '
          'Lustrous south sea pearls with gold filigree accents.',
    ),
    JewelleryProduct(
      id: 's4',
      name: 'Emerald Royale Set',
      type: 'full jewellery set',
      emoji: '💚',
      category: JewelleryCategory.sets,
      description:
          'Opulent platinum set: Colombian emerald and diamond collar necklace, '
          'matching emerald drop earrings with diamond halos, an emerald and diamond bangle, '
          'and a statement emerald cocktail ring. Deep green stones with brilliant white diamonds.',
    ),
    JewelleryProduct(
      id: 's5',
      name: 'Traditional Gold Set',
      type: 'full jewellery set',
      emoji: '🏺',
      category: JewelleryCategory.sets,
      description:
          'Classic Indian 22kt gold temple jewellery set: a broad Lakshmi coin necklace, '
          'large jhumka earrings with ruby accents, gold kadas on both wrists, '
          'and a thick gold ring with floral meenakari work. Matt finish with antique texturing.',
    ),
    JewelleryProduct(
      id: 's6',
      name: 'Rose Gold Moderno',
      type: 'full jewellery set',
      emoji: '🌹',
      category: JewelleryCategory.sets,
      description:
          'Trendy 18kt rose gold set: delicate layered chain necklace with a diamond bar pendant, '
          'minimalist huggie hoop earrings, a thin stacking ring set, '
          'and a slim rose gold bangle. Polished finish with a contemporary aesthetic.',
    ),
  ];

  // ── Individual Pieces ─────────────────────────────────────────────────────
  static const List<JewelleryProduct> singles = [
    JewelleryProduct(id: '1', name: 'Diamond Necklace', type: 'necklace',  emoji: '💎', category: JewelleryCategory.necklaces, description: 'Elegant diamond solitaire pendant on a delicate 18kt white gold chain. 1ct round brilliant centre stone.'),
    JewelleryProduct(id: '2', name: 'Pearl Drop Earrings', type: 'earrings', emoji: '🤍', category: JewelleryCategory.earrings, description: 'Classic lustrous south sea pearl drop earrings with 22kt yellow gold settings and diamond accents.'),
    JewelleryProduct(id: '3', name: 'Gold Solitaire Ring', type: 'ring', emoji: '💍', category: JewelleryCategory.rings, description: 'Solid 22kt gold solitaire ring with a 0.75ct cushion-cut diamond. Polished band with tapered shoulders.'),
    JewelleryProduct(id: '4', name: 'Sapphire Bracelet', type: 'bracelet', emoji: '💙', category: JewelleryCategory.bangles, description: 'Blue sapphire and diamond tennis bracelet set in 18kt white gold. 3ct total sapphire weight.'),
    JewelleryProduct(id: '5', name: 'Ruby Pendant', type: 'pendant', emoji: '❤️', category: JewelleryCategory.necklaces, description: 'Vibrant 2ct pigeon-blood ruby pendant surrounded by pavé diamonds, on an 18kt yellow gold chain.'),
    JewelleryProduct(id: '6', name: 'Gold Bangles', type: 'bangles', emoji: '🟡', category: JewelleryCategory.bangles, description: 'Set of four traditional 22kt gold bangles with intricate floral patterns and textured finish.'),
    JewelleryProduct(id: '7', name: 'Diamond Studs', type: 'earrings', emoji: '✨', category: JewelleryCategory.earrings, description: 'Classic round brilliant 1ct total weight diamond stud earrings in platinum four-claw settings.'),
    JewelleryProduct(id: '8', name: 'Emerald Choker', type: 'necklace', emoji: '🌿', category: JewelleryCategory.necklaces, description: 'Statement choker with Colombian emeralds and rose-cut diamonds set in 18kt yellow gold. Antique finish.'),
    JewelleryProduct(id: '9', name: 'Jhumka Earrings', type: 'earrings', emoji: '🔔', category: JewelleryCategory.earrings, description: 'Traditional 22kt gold jhumka earrings with meenakari work, pearl drops, and intricate filigree details.'),
    JewelleryProduct(id: '10', name: 'Custom Product', type: 'custom', emoji: '📸', category: JewelleryCategory.custom, description: 'Upload your own jewellery image for a personalised AI try-on experience.'),
  ];

  static List<JewelleryProduct> get predefinedProducts => [...sets, ...singles];

  bool get isFullSet => category == JewelleryCategory.sets;
  bool get isCustom  => category == JewelleryCategory.custom;
}
