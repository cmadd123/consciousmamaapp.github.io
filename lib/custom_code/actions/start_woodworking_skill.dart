// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:cloud_firestore/cloud_firestore.dart';

Future<DocumentReference?> startWoodworkingSkill(
  DocumentReference childRef,
) async {
  // Create a new Woodworking skill path for the child with all 15 milestones

  final skillPathData = createSkillPathRecordData(
    skillName: 'Woodworking',
    skillIcon: '🪚',
    childRef: childRef,
    totalMilestones: 15,
    completedMilestones: 0,
    totalSubMilestones: 45,
    completedSubMilestones: 0,
    progressPercentage: 0.0,
    startedDate: DateTime.now(),
    lastUpdated: DateTime.now(),
  );

  // Add the milestones array
  final milestones = _getWoodworkingMilestones();

  final docRef = await SkillPathRecord.collection.add({
    ...skillPathData,
    'milestones': milestones.map((m) => getSkillMilestoneFirestoreData(m, true)).toList(),
  });

  return docRef;
}

List<SkillMilestoneStruct> _getWoodworkingMilestones() {
  return [
    createSkillMilestoneStruct(
      number: 1,
      title: 'Learn Basic Hand Tools',
      completed: false,
      fieldValues: {
        'sub_milestones': [
          {
            'title': 'Sand a piece of wood smooth',
            'video_search': 'teaching kids to sand wood safely',
            'completed': false,
          },
          {
            'title': 'Hammer nails straight',
            'video_search': 'teaching kids how to hammer nails',
            'completed': false,
          },
          {
            'title': 'Use a screwdriver (flat and Phillips)',
            'video_search': 'kids using screwdriver basics',
            'completed': false,
          },
        ],
      },
    ),
    createSkillMilestoneStruct(
      number: 2,
      title: 'Understand Wood Safety & Preparation',
      completed: false,
      fieldValues: {
        'sub_milestones': [
          {
            'title': 'Identify different types of wood (pine, oak, plywood, hardwood vs softwood)',
            'video_search': 'types of wood for beginners understanding grain',
            'completed': false,
          },
          {
            'title': 'Learn to measure with a ruler, mark wood, and use a square',
            'video_search': 'how to measure and mark wood accurately',
            'completed': false,
          },
          {
            'title': 'Practice proper hand position and safety grip',
            'video_search': 'woodworking safety hand position techniques',
            'completed': false,
          },
        ],
      },
    ),
    createSkillMilestoneStruct(
      number: 3,
      title: 'Master Basic Joints & Assembly',
      completed: false,
      fieldValues: {
        'sub_milestones': [
          {
            'title': 'Create butt joints with glue and nails',
            'video_search': 'butt joint woodworking techniques',
            'completed': false,
          },
          {
            'title': 'Use clamps properly (bar clamps, C-clamps, corner clamps)',
            'video_search': 'how to use woodworking clamps properly',
            'completed': false,
          },
          {
            'title': 'Build a simple box with corner joints',
            'video_search': 'simple wooden box project corner joints',
            'completed': false,
          },
        ],
      },
    ),
    createSkillMilestoneStruct(
      number: 4,
      title: 'Introduction to Power Tools (Supervised)',
      completed: false,
      fieldValues: {
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
    ),
    createSkillMilestoneStruct(
      number: 5,
      title: 'Complete First Real Project',
      completed: false,
      fieldValues: {
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
    ),
    createSkillMilestoneStruct(
      number: 6,
      title: 'Advanced Joinery Techniques',
      completed: false,
      fieldValues: {
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
    ),
    createSkillMilestoneStruct(
      number: 7,
      title: 'Precision Cutting & Table Saw Mastery',
      completed: false,
      fieldValues: {
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
    ),
    createSkillMilestoneStruct(
      number: 8,
      title: 'Router Skills & Edge Work',
      completed: false,
      fieldValues: {
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
    ),
    createSkillMilestoneStruct(
      number: 9,
      title: 'Build Functional Furniture',
      completed: false,
      fieldValues: {
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
    ),
    createSkillMilestoneStruct(
      number: 10,
      title: 'Mortise & Tenon Joinery',
      completed: false,
      fieldValues: {
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
    ),
    createSkillMilestoneStruct(
      number: 11,
      title: 'Advanced Finishing Techniques',
      completed: false,
      fieldValues: {
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
    ),
    createSkillMilestoneStruct(
      number: 12,
      title: 'Specialty Techniques',
      completed: false,
      fieldValues: {
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
    ),
    createSkillMilestoneStruct(
      number: 13,
      title: 'Build Complex Furniture Piece',
      completed: false,
      fieldValues: {
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
    ),
    createSkillMilestoneStruct(
      number: 14,
      title: 'Professional-Level Skills',
      completed: false,
      fieldValues: {
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
    ),
    createSkillMilestoneStruct(
      number: 15,
      title: 'Business & Selling Projects',
      completed: false,
      fieldValues: {
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
    ),
  ];
}
