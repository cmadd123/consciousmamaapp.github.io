const admin = require("firebase-admin/app");
admin.initializeApp();

const generateChildTasks = require("./generate_child_tasks.js");
exports.generateChildTasks = generateChildTasks.generateChildTasks;
const scahdulNotification = require("./scahdul_notification.js");
exports.scahdulNotification = scahdulNotification.scahdulNotification;
const processReminders = require("./process_reminders.js");
exports.processReminders = processReminders.processReminders;
const scahdulNotifications = require("./scahdul_notifications.js");
exports.scahdulNotifications = scahdulNotifications.scahdulNotifications;
const sendUserNotification = require("./send_user_notification.js");
exports.sendUserNotification = sendUserNotification.sendUserNotification;
const extractRecipe = require("./extract_recipe.js");
exports.extractRecipe = extractRecipe.extractRecipe;
const generateDailyRecurringTasks = require("./generate_daily_recurring_tasks.js");
exports.generateDailyRecurringTasks =
  generateDailyRecurringTasks.generateDailyRecurringTasks;
const verifyMealTags = require("./verify_meal_tags.js");
exports.verifyMealTags = verifyMealTags.verifyMealTags;
const cleanupUnlabeledContent = require("./cleanup_unlabeled_content.js");
exports.cleanupUnlabeledContent = cleanupUnlabeledContent.cleanupUnlabeledContent;
