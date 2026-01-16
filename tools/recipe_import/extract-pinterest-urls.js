/**
 * Extract Recipe URLs from Pinterest Export HTML
 *
 * This script parses the Pinterest data export HTML file and extracts
 * all recipe source URLs from the "Recipes for app" board.
 *
 * Usage: node extract-pinterest-urls.js <path-to-pinterest.html>
 */

import { readFileSync, writeFileSync } from 'fs';

const BOARD_NAME = 'Recipes for app';
const OUTPUT_FILE = 'recipe-urls.txt';

function extractRecipeUrls(htmlPath) {
  console.log(`Reading Pinterest export from: ${htmlPath}`);

  const html = readFileSync(htmlPath, 'utf-8');

  // Split by pin entries - each pin starts with a pattern like "<br>Title:"
  // We'll look for blocks that contain "Board Name: Recipes for app"

  const urls = [];
  const seenUrls = new Set();

  // Find all pins belonging to our target board
  // Pattern: Look for "Board Name: Recipes for app" and extract the nearby Canonical Link

  // Split into lines for easier processing
  const lines = html.split('\n');

  let currentPin = {};
  let inRecipeBoard = false;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Check if we're starting a new pin (Title line)
    if (line.includes('<br>Title:')) {
      // Save previous pin if it was in our board
      if (inRecipeBoard && currentPin.url) {
        if (!seenUrls.has(currentPin.url)) {
          seenUrls.add(currentPin.url);
          urls.push({
            url: currentPin.url,
            title: currentPin.title || '',
            details: currentPin.details || ''
          });
        }
      }
      // Reset for new pin
      currentPin = {};
      inRecipeBoard = false;

      // Extract title
      const titleMatch = line.match(/<br>Title:\s*(.+?)(?:,|$)/);
      if (titleMatch) {
        currentPin.title = titleMatch[1].trim();
        if (currentPin.title === 'No data') currentPin.title = '';
      }
    }

    // Extract details/description
    if (line.includes('<br>Details:')) {
      const detailsMatch = line.match(/<br>Details:\s*(.+?)(?:,|$)/);
      if (detailsMatch) {
        currentPin.details = detailsMatch[1].trim();
        if (currentPin.details === 'No data') currentPin.details = '';
      }
    }

    // Check if this pin is in our target board
    if (line.includes(`Board Name: ${BOARD_NAME}`)) {
      inRecipeBoard = true;
    }

    // Extract canonical link (the source URL)
    if (line.includes('<br>Canonical Link:') && line.includes('href=')) {
      const urlMatch = line.match(/href="([^"]+)"/);
      if (urlMatch) {
        currentPin.url = urlMatch[1];
      }
    }
  }

  // Don't forget the last pin
  if (inRecipeBoard && currentPin.url) {
    if (!seenUrls.has(currentPin.url)) {
      seenUrls.add(currentPin.url);
      urls.push({
        url: currentPin.url,
        title: currentPin.title || '',
        details: currentPin.details || ''
      });
    }
  }

  return urls;
}

function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log('Usage: node extract-pinterest-urls.js <path-to-pinterest.html>');
    console.log('');
    console.log('Example: node extract-pinterest-urls.js "C:\\Users\\Administrator\\Downloads\\pinterest (1).html"');
    process.exit(1);
  }

  const htmlPath = args[0];

  try {
    const recipes = extractRecipeUrls(htmlPath);

    console.log(`\nFound ${recipes.length} recipe URLs from "${BOARD_NAME}" board\n`);

    // Write URLs to file (one per line)
    const urlsOnly = recipes.map(r => r.url).join('\n');
    writeFileSync(OUTPUT_FILE, urlsOnly);
    console.log(`URLs written to: ${OUTPUT_FILE}`);

    // Also write a JSON file with more details
    const jsonOutput = {
      board: BOARD_NAME,
      extractedAt: new Date().toISOString(),
      count: recipes.length,
      recipes: recipes
    };
    writeFileSync('pinterest-recipes.json', JSON.stringify(jsonOutput, null, 2));
    console.log(`Full details written to: pinterest-recipes.json`);

    // Print first few for preview
    console.log('\nFirst 10 recipes:');
    recipes.slice(0, 10).forEach((r, i) => {
      console.log(`${i + 1}. ${r.details || r.title || 'Untitled'}`);
      console.log(`   ${r.url}`);
    });

    if (recipes.length > 10) {
      console.log(`\n... and ${recipes.length - 10} more`);
    }

  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

main();
