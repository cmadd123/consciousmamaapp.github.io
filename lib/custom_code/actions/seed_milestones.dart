import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/enums/enums.dart';

/// Seeds the Static_Milestones collection with developmental milestones
/// for ages 0-6 across all 5 categories.
/// Returns the number of milestones created.
/// Set forceReseed to true to delete existing and reseed.
Future<int> seedMilestones({bool forceReseed = false}) async {
  final collection = FirebaseFirestore.instance.collection('Static_Milestones');

  // Check if already seeded
  final existing = await collection.limit(1).get();
  if (existing.docs.isNotEmpty && !forceReseed) {
    print('Milestones already seeded. Skipping.');
    return 0;
  }

  // If force reseed, delete all existing documents first
  if (forceReseed && existing.docs.isNotEmpty) {
    print('Force reseed: deleting existing milestones...');
    final allDocs = await collection.get();
    for (final doc in allDocs.docs) {
      await doc.reference.delete();
    }
    print('Deleted ${allDocs.docs.length} existing milestones.');
  }

  final milestones = _getMilestoneData();
  int count = 0;

  for (final milestone in milestones) {
    await collection.add(milestone);
    count++;
  }

  print('Seeded $count milestones successfully.');
  return count;
}

List<Map<String, dynamic>> _getMilestoneData() {
  return [
    // ==================== AGE 0 (0-12 months) ====================
    // Physical
    {'Title': 'Holds head up during tummy time', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 0.0},
    {'Title': 'Rolls over from tummy to back', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 0.0},
    {'Title': 'Sits without support', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 0.0},
    {'Title': 'Pulls to standing position', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 0.0},
    {'Title': 'Takes first steps with support', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 0.0},
    // Cognitive
    {'Title': 'Follows moving objects with eyes', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 0.0},
    {'Title': 'Reaches for nearby toys', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 0.0},
    {'Title': 'Explores objects by putting them in mouth', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 0.0},
    {'Title': 'Looks for hidden objects', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 0.0},
    {'Title': 'Responds to "no"', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 0.0},
    // Communication
    {'Title': 'Coos and babbles', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 0.0},
    {'Title': 'Responds to own name', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 0.0},
    {'Title': 'Says "mama" or "dada"', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 0.0},
    {'Title': 'Waves bye-bye', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 0.0},
    {'Title': 'Points to things they want', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 0.0},
    // SocialEmotional
    {'Title': 'Smiles at familiar faces', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 0.0},
    {'Title': 'Enjoys playing peek-a-boo', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 0.0},
    {'Title': 'Shows stranger anxiety', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 0.0},
    {'Title': 'Has a favorite toy', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 0.0},
    {'Title': 'Cries when parent leaves', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 0.0},
    // Selfcare
    {'Title': 'Opens mouth for spoon feeding', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 0.0},
    {'Title': 'Holds own bottle', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 0.0},
    {'Title': 'Picks up small foods with fingers', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 0.0},
    {'Title': 'Drinks from sippy cup with help', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 0.0},
    {'Title': 'Sleeps through the night', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 0.0},

    // ==================== AGE 1 (12-24 months) ====================
    // Physical
    {'Title': 'Walks independently', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 1.0},
    {'Title': 'Climbs onto furniture', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 1.0},
    {'Title': 'Kicks a ball forward', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 1.0},
    {'Title': 'Stacks 2-4 blocks', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 1.0},
    {'Title': 'Scribbles with crayon', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 1.0},
    // Cognitive
    {'Title': 'Points to body parts when named', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 1.0},
    {'Title': 'Completes simple shape sorter', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 1.0},
    {'Title': 'Follows one-step instructions', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 1.0},
    {'Title': 'Matches similar objects', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 1.0},
    {'Title': 'Imitates household activities', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 1.0},
    // Communication
    {'Title': 'Says 10-25 single words', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 1.0},
    {'Title': 'Combines two words together', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 1.0},
    {'Title': 'Points to pictures in books', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 1.0},
    {'Title': 'Shakes head for "no"', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 1.0},
    {'Title': 'Names familiar objects', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 1.0},
    // SocialEmotional
    {'Title': 'Plays alongside other children', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 1.0},
    {'Title': 'Shows affection to family members', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 1.0},
    {'Title': 'Has temper tantrums when frustrated', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 1.0},
    {'Title': 'Shows ownership of toys', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 1.0},
    {'Title': 'Seeks comfort when upset', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 1.0},
    // Selfcare
    {'Title': 'Drinks from open cup', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 1.0},
    {'Title': 'Uses spoon to self-feed', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 1.0},
    {'Title': 'Helps with undressing', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 1.0},
    {'Title': 'Indicates wet diaper', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 1.0},
    {'Title': 'Washes hands with help', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 1.0},

    // ==================== AGE 2 (24-36 months) ====================
    // Physical
    {'Title': 'Runs without falling', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 2.0},
    {'Title': 'Walks up stairs with alternating feet', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 2.0},
    {'Title': 'Jumps with both feet off ground', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 2.0},
    {'Title': 'Catches large ball with both arms', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 2.0},
    {'Title': 'Turns book pages one at a time', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 2.0},
    // Cognitive
    {'Title': 'Sorts objects by color', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 2.0},
    {'Title': 'Completes 3-4 piece puzzle', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 2.0},
    {'Title': 'Understands "one" and "two"', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 2.0},
    {'Title': 'Follows two-step instructions', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 2.0},
    {'Title': 'Names colors correctly', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 2.0},
    // Communication
    {'Title': 'Speaks in 2-3 word sentences', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 2.0},
    {'Title': 'Asks "what" and "where" questions', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 2.0},
    {'Title': 'Uses pronouns (I, me, you)', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 2.0},
    {'Title': 'Strangers understand most words', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 2.0},
    {'Title': 'Names body parts', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 2.0},
    // SocialEmotional
    {'Title': 'Plays make-believe games', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 2.0},
    {'Title': 'Takes turns with help', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 2.0},
    {'Title': 'Shows concern for crying friend', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 2.0},
    {'Title': 'Says "no" to assert independence', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 2.0},
    {'Title': 'Separates from parent without crying', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 2.0},
    // Selfcare
    {'Title': 'Pulls pants up and down', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 2.0},
    {'Title': 'Uses fork to eat', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 2.0},
    {'Title': 'Brushes teeth with help', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 2.0},
    {'Title': 'Washes and dries hands', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 2.0},
    {'Title': 'Uses potty with reminders', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 2.0},

    // ==================== AGE 3 (36-48 months) ====================
    // Physical
    {'Title': 'Pedals a tricycle', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 3.0},
    {'Title': 'Catches bounced ball', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 3.0},
    {'Title': 'Hops on one foot', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 3.0},
    {'Title': 'Cuts paper with scissors', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 3.0},
    {'Title': 'Draws a circle', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 3.0},
    // Cognitive
    {'Title': 'Counts to 10', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 3.0},
    {'Title': 'Understands "same" and "different"', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 3.0},
    {'Title': 'Recalls parts of a story', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 3.0},
    {'Title': 'Sorts by shape and color', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 3.0},
    {'Title': 'Completes 6-piece puzzle', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 3.0},
    // Communication
    {'Title': 'Speaks in 4-5 word sentences', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 3.0},
    {'Title': 'Tells simple stories', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 3.0},
    {'Title': 'Asks "why" questions', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 3.0},
    {'Title': 'Uses plurals correctly', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 3.0},
    {'Title': 'Follows three-step instructions', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 3.0},
    // SocialEmotional
    {'Title': 'Takes turns without reminders', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 3.0},
    {'Title': 'Shows empathy to others', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 3.0},
    {'Title': 'Plays cooperatively with others', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 3.0},
    {'Title': 'Understands "mine" vs "theirs"', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 3.0},
    {'Title': 'Manages frustration with words', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 3.0},
    // Selfcare
    {'Title': 'Uses toilet independently (daytime)', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 3.0},
    {'Title': 'Puts on shoes (wrong feet ok)', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 3.0},
    {'Title': 'Buttons large buttons', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 3.0},
    {'Title': 'Pours from small pitcher', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 3.0},
    {'Title': 'Brushes teeth alone (needs check)', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 3.0},

    // ==================== AGE 4 (48-60 months) ====================
    // Physical
    {'Title': 'Stands on one foot for 5+ seconds', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 4.0},
    {'Title': 'Throws ball overhand accurately', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 4.0},
    {'Title': 'Skips on one foot', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 4.0},
    {'Title': 'Draws a person with 3+ body parts', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 4.0},
    {'Title': 'Uses scissors to cut on a line', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 4.0},
    // Cognitive
    {'Title': 'Counts 10+ objects correctly', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 4.0},
    {'Title': 'Names 4+ colors', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 4.0},
    {'Title': 'Understands time concepts (yesterday, today)', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 4.0},
    {'Title': 'Draws shapes from memory', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 4.0},
    {'Title': 'Predicts what happens next in story', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 4.0},
    // Communication
    {'Title': 'Speaks in complete sentences', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 4.0},
    {'Title': 'Tells stories with beginning and end', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 4.0},
    {'Title': 'Uses past tense correctly', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 4.0},
    {'Title': 'Defines simple words', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 4.0},
    {'Title': 'Speaks clearly to strangers', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 4.0},
    // SocialEmotional
    {'Title': 'Plays group games with rules', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 4.0},
    {'Title': 'Prefers certain friends', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 4.0},
    {'Title': 'Expresses feelings with words', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 4.0},
    {'Title': 'Understands taking turns in games', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 4.0},
    {'Title': 'Shows pride in accomplishments', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 4.0},
    // Selfcare
    {'Title': 'Dresses independently', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 4.0},
    {'Title': 'Uses bathroom alone (wipes well)', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 4.0},
    {'Title': 'Brushes teeth properly', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 4.0},
    {'Title': 'Uses knife to spread', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 4.0},
    {'Title': 'Zips jacket zipper', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 4.0},

    // ==================== AGE 5 (60-72 months) ====================
    // Physical
    {'Title': 'Rides bicycle with training wheels', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 5.0},
    {'Title': 'Skips alternating feet', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 5.0},
    {'Title': 'Catches small ball with hands only', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 5.0},
    {'Title': 'Writes some letters legibly', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 5.0},
    {'Title': 'Ties loose knot', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 5.0},
    // Cognitive
    {'Title': 'Recognizes written name', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 5.0},
    {'Title': 'Counts to 20+', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 5.0},
    {'Title': 'Understands concept of addition', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 5.0},
    {'Title': 'Sorts objects by multiple features', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 5.0},
    {'Title': 'Sequences story events correctly', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 5.0},
    // Communication
    {'Title': 'Speaks in complex sentences', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 5.0},
    {'Title': 'Retells stories in detail', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 5.0},
    {'Title': 'Uses future tense correctly', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 5.0},
    {'Title': 'Explains how things work', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 5.0},
    {'Title': 'Rhymes words', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 5.0},
    // SocialEmotional
    {'Title': 'Follows game rules fairly', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 5.0},
    {'Title': 'Resolves conflicts with peers', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 5.0},
    {'Title': 'Shows understanding of right/wrong', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 5.0},
    {'Title': 'Expresses complex emotions', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 5.0},
    {'Title': 'Makes and keeps friends', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 5.0},
    // Selfcare
    {'Title': 'Ties shoelaces', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 5.0},
    {'Title': 'Prepares simple snack', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 5.0},
    {'Title': 'Bathes with minimal help', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 5.0},
    {'Title': 'Chooses weather-appropriate clothes', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 5.0},
    {'Title': 'Manages belongings at school', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 5.0},

    // ==================== AGE 6 (72-84 months) ====================
    // Physical
    {'Title': 'Rides bicycle without training wheels', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 6.0},
    {'Title': 'Catches ball with one hand', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 6.0},
    {'Title': 'Writes first and last name', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 6.0},
    {'Title': 'Draws detailed pictures', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 6.0},
    {'Title': 'Skips rope', 'Category': 'Physical', 'act_goal': ActGoalMilestones.Physical.name, 'age': 6.0},
    // Cognitive
    {'Title': 'Reads simple words', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 6.0},
    {'Title': 'Adds and subtracts within 10', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 6.0},
    {'Title': 'Tells time to the hour', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 6.0},
    {'Title': 'Understands calendar concepts', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 6.0},
    {'Title': 'Solves simple word problems', 'Category': 'Cognitive', 'act_goal': ActGoalMilestones.Cognitive.name, 'age': 6.0},
    // Communication
    {'Title': 'Reads aloud with expression', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 6.0},
    {'Title': 'Writes simple sentences', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 6.0},
    {'Title': 'Uses complex grammar correctly', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 6.0},
    {'Title': 'Explains reasoning clearly', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 6.0},
    {'Title': 'Participates in group discussions', 'Category': 'Communication', 'act_goal': ActGoalMilestones.Communication.name, 'age': 6.0},
    // SocialEmotional
    {'Title': 'Maintains friendships over time', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 6.0},
    {'Title': 'Handles losing gracefully', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 6.0},
    {'Title': 'Shows empathy in complex situations', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 6.0},
    {'Title': 'Works cooperatively in groups', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 6.0},
    {'Title': 'Manages emotions independently', 'Category': 'SocialEmotional', 'act_goal': ActGoalMilestones.SocialEmotional.name, 'age': 6.0},
    // Selfcare
    {'Title': 'Showers independently', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 6.0},
    {'Title': 'Packs own school bag', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 6.0},
    {'Title': 'Makes simple meals', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 6.0},
    {'Title': 'Manages time for activities', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 6.0},
    {'Title': 'Keeps room organized with reminders', 'Category': 'Selfcare', 'act_goal': ActGoalMilestones.Selfcare.name, 'age': 6.0},
  ];
}
