// Fake data for Skills & Hobbies preview screens
// This will be replaced with real Firestore data in production

class SkillPreviewData {
  static final woodworkingSkill = {
    'skill_name': 'Woodworking',
    'skill_icon': '🔨',
    'total_milestones': 15,
    'completed_milestones': 3,
    'total_sub_milestones': 45,
    'completed_sub_milestones': 9,
    'progress_percentage': 20.0,
    'milestones': [
      {
        'number': 1,
        'title': 'Learn Basic Hand Tools',
        'completed': true,
        'sub_milestones': [
          {
            'title': 'Sand a piece of wood smooth',
            'video_search': 'teaching kids to sand wood safely',
            'completed': true,
          },
          {
            'title': 'Hammer nails straight',
            'video_search': 'teaching kids how to hammer nails',
            'completed': true,
          },
          {
            'title': 'Use a screwdriver (flat and Phillips)',
            'video_search': 'kids using screwdriver basics',
            'completed': true,
          },
        ],
      },
      {
        'number': 2,
        'title': 'Understand Wood Safety & Preparation',
        'completed': true,
        'sub_milestones': [
          {
            'title': 'Identify different types of wood (pine, oak, plywood, hardwood vs softwood)',
            'video_search': 'types of wood for beginners understanding grain',
            'completed': true,
          },
          {
            'title': 'Learn to measure with a ruler, mark wood, and use a square',
            'video_search': 'how to measure and mark wood accurately',
            'completed': true,
          },
          {
            'title': 'Practice proper hand position and safety grip',
            'video_search': 'woodworking safety hand position techniques',
            'completed': true,
          },
        ],
      },
      {
        'number': 3,
        'title': 'Master Basic Joints & Assembly',
        'completed': true,
        'sub_milestones': [
          {
            'title': 'Create butt joints with glue and nails',
            'video_search': 'butt joint woodworking techniques',
            'completed': true,
          },
          {
            'title': 'Use clamps properly (bar clamps, C-clamps, corner clamps)',
            'video_search': 'how to use woodworking clamps properly',
            'completed': true,
          },
          {
            'title': 'Build a simple box with corner joints',
            'video_search': 'simple wooden box project corner joints',
            'completed': true,
          },
        ],
      },
      {
        'number': 4,
        'title': 'Introduction to Power Tools (Supervised)',
        'completed': false,
        'sub_milestones': [
          {
            'title': 'Use a power drill and different drill bits safely',
            'video_search': 'power drill safety and basics beginner',
            'completed': false,
          },
          {
            'title': 'Learn to use an orbital sander',
            'video_search': 'orbital sander tutorial for beginners',
            'completed': false,
          },
          {
            'title': 'Practice with a jigsaw on curved cuts',
            'video_search': 'jigsaw safety and cutting techniques beginner',
            'completed': false,
          },
        ],
      },
      {
        'number': 5,
        'title': 'Complete First Real Project',
        'completed': false,
        'sub_milestones': [
          {
            'title': 'Build a small shelf or stepped plant stand',
            'video_search': 'build simple wooden shelf beginner project',
            'completed': false,
          },
          {
            'title': 'Create a cutting board with edge grain',
            'video_search': 'how to make cutting board edge grain',
            'completed': false,
          },
          {
            'title': 'Sand, stain, and finish the completed project',
            'video_search': 'wood staining and finishing tutorial beginner',
            'completed': false,
          },
        ],
      },
      {
        'number': 6,
        'title': 'Advanced Joinery Techniques',
        'completed': false,
        'sub_milestones': [
          {
            'title': 'Create pocket hole joints with a Kreg jig',
            'video_search': 'pocket hole joinery kreg jig tutorial',
            'completed': false,
          },
          {
            'title': 'Learn to make dowel joints',
            'video_search': 'dowel joint woodworking technique accurate',
            'completed': false,
          },
          {
            'title': 'Practice making lap joints',
            'video_search': 'lap joint woodworking how to cut',
            'completed': false,
          },
        ],
      },
      {
        'number': 7,
        'title': 'Precision Cutting & Table Saw Mastery',
        'completed': false,
        'sub_milestones': [
          {
            'title': 'Use a table saw safely (with push sticks, guards)',
            'video_search': 'table saw safety basics push stick technique',
            'completed': false,
          },
          {
            'title': 'Make rip cuts and crosscuts accurately',
            'video_search': 'rip cut vs crosscut table saw technique',
            'completed': false,
          },
          {
            'title': 'Cut dados and rabbets with a table saw',
            'video_search': 'cutting dados and rabbets table saw',
            'completed': false,
          },
        ],
      },
      {
        'number': 8,
        'title': 'Router Skills & Edge Work',
        'completed': false,
        'sub_milestones': [
          {
            'title': 'Use a handheld router with straight bit',
            'video_search': 'router basics for beginners handheld',
            'completed': false,
          },
          {
            'title': 'Create decorative edges with roundover and chamfer bits',
            'video_search': 'router edge profiles roundover chamfer',
            'completed': false,
          },
          {
            'title': 'Make grooves and dados with a router',
            'video_search': 'cutting grooves with router technique',
            'completed': false,
          },
        ],
      },
      {
        'number': 9,
        'title': 'Build Functional Furniture',
        'completed': false,
        'sub_milestones': [
          {
            'title': 'Design and build a small side table or nightstand',
            'video_search': 'build side table woodworking plans',
            'completed': false,
          },
          {
            'title': 'Create a bookshelf with adjustable shelves',
            'video_search': 'bookshelf build adjustable shelves plans',
            'completed': false,
          },
          {
            'title': 'Build a simple chair or stool',
            'video_search': 'wooden stool chair build beginner plans',
            'completed': false,
          },
        ],
      },
      {
        'number': 10,
        'title': 'Mortise & Tenon Joinery',
        'completed': false,
        'sub_milestones': [
          {
            'title': 'Cut mortises with a chisel or mortiser',
            'video_search': 'mortise cutting techniques chisel router',
            'completed': false,
          },
          {
            'title': 'Create matching tenons with saw and chisel',
            'video_search': 'cutting tenons hand saw table saw',
            'completed': false,
          },
          {
            'title': 'Assemble a mortise and tenon joint properly',
            'video_search': 'mortise tenon joint assembly glue up',
            'completed': false,
          },
        ],
      },
      {
        'number': 11,
        'title': 'Advanced Finishing Techniques',
        'completed': false,
        'sub_milestones': [
          {
            'title': 'Apply polyurethane or lacquer finish',
            'video_search': 'polyurethane finish application technique smooth',
            'completed': false,
          },
          {
            'title': 'Use wood filler and grain filler for flawless finish',
            'video_search': 'wood filler grain filler proper use',
            'completed': false,
          },
          {
            'title': 'Practice rubbing out a finish to high gloss',
            'video_search': 'rubbing out wood finish high gloss',
            'completed': false,
          },
        ],
      },
      {
        'number': 12,
        'title': 'Specialty Techniques',
        'completed': false,
        'sub_milestones': [
          {
            'title': 'Learn to use a lathe for turning (bowls, pens, legs)',
            'video_search': 'wood lathe basics beginners turning',
            'completed': false,
          },
          {
            'title': 'Practice steam bending wood',
            'video_search': 'steam bending wood technique tutorial',
            'completed': false,
          },
          {
            'title': 'Create dovetail joints (hand-cut or with jig)',
            'video_search': 'dovetail joint cutting hand cut vs jig',
            'completed': false,
          },
        ],
      },
      {
        'number': 13,
        'title': 'Build Complex Furniture Piece',
        'completed': false,
        'sub_milestones': [
          {
            'title': 'Design and build a dresser or chest of drawers',
            'video_search': 'build dresser drawers woodworking plans',
            'completed': false,
          },
          {
            'title': 'Create a desk with drawers and cable management',
            'video_search': 'diy desk build plans drawers cable management',
            'completed': false,
          },
          {
            'title': 'Build a dining table with extension leaves',
            'video_search': 'dining table build extension leaves plans',
            'completed': false,
          },
        ],
      },
      {
        'number': 14,
        'title': 'Professional-Level Skills',
        'completed': false,
        'sub_milestones': [
          {
            'title': 'Use a CNC router for precision cuts and carvings',
            'video_search': 'CNC router woodworking beginner tutorial',
            'completed': false,
          },
          {
            'title': 'Learn veneer application and inlay work',
            'video_search': 'wood veneer application inlay technique',
            'completed': false,
          },
          {
            'title': 'Practice wood carving (relief or in-the-round)',
            'video_search': 'wood carving techniques beginner relief',
            'completed': false,
          },
        ],
      },
      {
        'number': 15,
        'title': 'Business & Selling Projects',
        'completed': false,
        'sub_milestones': [
          {
            'title': 'Price materials and labor for custom projects',
            'video_search': 'pricing woodworking projects profit margins',
            'completed': false,
          },
          {
            'title': 'Create a portfolio and sell first piece online (Etsy, local)',
            'video_search': 'selling woodworking projects etsy tips',
            'completed': false,
          },
          {
            'title': 'Learn to take commissions and work from client plans',
            'video_search': 'taking woodworking commissions tips process',
            'completed': false,
          },
        ],
      },
    ],
  };

  static final allSkills = [
    {
      'skill_name': 'Woodworking',
      'skill_icon': '🔨',
      'progress_percentage': 20.0,
      'completed_milestones': 3,
      'total_milestones': 15,
    },
    {
      'skill_name': 'Photography',
      'skill_icon': '📷',
      'progress_percentage': 0.0,
      'completed_milestones': 0,
      'total_milestones': 15,
    },
    {
      'skill_name': 'Cooking',
      'skill_icon': '👨‍🍳',
      'progress_percentage': 0.0,
      'completed_milestones': 0,
      'total_milestones': 15,
    },
    {
      'skill_name': 'Gardening',
      'skill_icon': '🌱',
      'progress_percentage': 0.0,
      'completed_milestones': 0,
      'total_milestones': 15,
    },
    {
      'skill_name': 'Piano',
      'skill_icon': '🎹',
      'progress_percentage': 0.0,
      'completed_milestones': 0,
      'total_milestones': 15,
    },
    {
      'skill_name': 'Art & Drawing',
      'skill_icon': '🎨',
      'progress_percentage': 0.0,
      'completed_milestones': 0,
      'total_milestones': 15,
    },
    {
      'skill_name': 'Coding',
      'skill_icon': '💻',
      'progress_percentage': 0.0,
      'completed_milestones': 0,
      'total_milestones': 15,
    },
    {
      'skill_name': 'Sewing',
      'skill_icon': '🧵',
      'progress_percentage': 0.0,
      'completed_milestones': 0,
      'total_milestones': 15,
    },
    {
      'skill_name': 'Writing',
      'skill_icon': '✍️',
      'progress_percentage': 0.0,
      'completed_milestones': 0,
      'total_milestones': 15,
    },
    {
      'skill_name': 'Soccer',
      'skill_icon': '⚽',
      'progress_percentage': 0.0,
      'completed_milestones': 0,
      'total_milestones': 15,
    },
  ];
}
