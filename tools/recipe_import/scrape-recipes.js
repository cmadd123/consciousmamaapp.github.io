/**
 * Recipe Scraper using JSON-LD structured data
 *
 * Most recipe sites use JSON-LD Schema.org markup for SEO.
 * This script extracts recipe data from that structured data.
 *
 * Usage: node scrape-recipes.js
 * Input: recipe-urls.txt (one URL per line)
 * Output: recipes.json
 */

import { readFileSync, writeFileSync, existsSync } from 'fs';
import https from 'https';
import http from 'http';

const INPUT_FILE = 'recipe-urls.txt';
const OUTPUT_FILE = 'recipes.json';
const DELAY_MS = 500; // Delay between requests to be polite

/**
 * Fetch URL content with redirect following
 */
function fetchUrl(url, redirectCount = 0) {
  return new Promise((resolve, reject) => {
    if (redirectCount > 5) {
      reject(new Error('Too many redirects'));
      return;
    }

    const protocol = url.startsWith('https') ? https : http;

    const request = protocol.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
      }
    }, (response) => {
      // Handle redirects
      if (response.statusCode >= 300 && response.statusCode < 400 && response.headers.location) {
        let redirectUrl = response.headers.location;
        // Handle relative URLs
        if (redirectUrl.startsWith('/')) {
          const urlObj = new URL(url);
          redirectUrl = `${urlObj.protocol}//${urlObj.host}${redirectUrl}`;
        }
        resolve(fetchUrl(redirectUrl, redirectCount + 1));
        return;
      }

      if (response.statusCode !== 200) {
        reject(new Error(`HTTP ${response.statusCode}`));
        return;
      }

      let data = '';
      response.on('data', (chunk) => {
        data += chunk;
      });
      response.on('end', () => {
        resolve(data);
      });
    });

    request.on('error', reject);
    request.setTimeout(30000, () => {
      request.destroy();
      reject(new Error('Request timeout'));
    });
  });
}

/**
 * Extract recipe data from HTML using JSON-LD structured data
 */
function extractRecipeFromHtml(html, sourceUrl) {
  // Try to find JSON-LD structured data
  const jsonLdMatches = html.match(/<script[^>]*type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/gi);

  if (jsonLdMatches) {
    for (const match of jsonLdMatches) {
      try {
        const jsonContent = match.replace(/<script[^>]*>|<\/script>/gi, '').trim();
        const data = JSON.parse(jsonContent);

        // Handle array of items
        const items = Array.isArray(data) ? data : [data];

        for (const item of items) {
          const recipe = findRecipeInJsonLd(item);
          if (recipe) {
            return normalizeRecipe(recipe, sourceUrl);
          }
        }
      } catch (e) {
        // Continue to next match
        continue;
      }
    }
  }

  // Fallback: Try to extract from meta tags
  return extractFromMetaTags(html, sourceUrl);
}

/**
 * Find Recipe object in JSON-LD data (handles @graph and nested structures)
 */
function findRecipeInJsonLd(data) {
  if (!data) return null;

  // Direct recipe
  if (data['@type'] === 'Recipe' ||
      (Array.isArray(data['@type']) && data['@type'].includes('Recipe'))) {
    return data;
  }

  // Check @graph array
  if (data['@graph'] && Array.isArray(data['@graph'])) {
    for (const item of data['@graph']) {
      const recipe = findRecipeInJsonLd(item);
      if (recipe) return recipe;
    }
  }

  return null;
}

/**
 * Normalize recipe data to our format
 */
function normalizeRecipe(recipe, sourceUrl) {
  // Parse ingredients
  let ingredients = [];
  if (recipe.recipeIngredient) {
    ingredients = Array.isArray(recipe.recipeIngredient)
      ? recipe.recipeIngredient
      : [recipe.recipeIngredient];
  }

  // Parse instructions
  let instructions = [];
  if (recipe.recipeInstructions) {
    if (Array.isArray(recipe.recipeInstructions)) {
      instructions = recipe.recipeInstructions.map(step => {
        if (typeof step === 'string') return step;
        if (step.text) return step.text;
        if (step.itemListElement) {
          return step.itemListElement.map(s => s.text || s).join(' ');
        }
        return String(step);
      });
    } else if (typeof recipe.recipeInstructions === 'string') {
      instructions = recipe.recipeInstructions.split(/\n+/).filter(s => s.trim());
    }
  }

  // Parse image
  let imageUrl = '';
  if (recipe.image) {
    if (typeof recipe.image === 'string') {
      imageUrl = recipe.image;
    } else if (Array.isArray(recipe.image)) {
      imageUrl = recipe.image[0];
      if (typeof imageUrl === 'object') imageUrl = imageUrl.url || '';
    } else if (recipe.image.url) {
      imageUrl = recipe.image.url;
    }
  }

  // Parse times
  const prepTime = parseDuration(recipe.prepTime);
  const cookTime = parseDuration(recipe.cookTime);
  const totalTime = parseDuration(recipe.totalTime);

  // Parse servings/yield
  let servings = '';
  if (recipe.recipeYield) {
    servings = Array.isArray(recipe.recipeYield)
      ? recipe.recipeYield[0]
      : String(recipe.recipeYield);
  }

  return {
    recipeName: recipe.name || 'Untitled Recipe',
    description: recipe.description || '',
    imageUrl: imageUrl,
    ingredients: ingredients.filter(i => i && i.trim()),
    cookingInstructions: instructions.filter(i => i && i.trim()),
    prepTime: formatTime(prepTime),
    cookTime: formatTime(cookTime),
    totalTime: formatTime(totalTime || (prepTime + cookTime)),
    servings: servings,
    sourceUrl: sourceUrl,
    success: true
  };
}

/**
 * Parse ISO 8601 duration to minutes
 */
function parseDuration(duration) {
  if (!duration) return 0;
  if (typeof duration === 'number') return duration;

  const match = String(duration).match(/PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/i);
  if (match) {
    const hours = parseInt(match[1] || 0);
    const minutes = parseInt(match[2] || 0);
    const seconds = parseInt(match[3] || 0);
    return hours * 60 + minutes + Math.round(seconds / 60);
  }

  // Try simple number
  const num = parseInt(duration);
  return isNaN(num) ? 0 : num;
}

/**
 * Format minutes to readable string
 */
function formatTime(minutes) {
  if (!minutes) return '';
  if (minutes < 60) return `${minutes} mins`;
  const hrs = Math.floor(minutes / 60);
  const mins = minutes % 60;
  if (mins === 0) return `${hrs} hour${hrs > 1 ? 's' : ''}`;
  return `${hrs} hour${hrs > 1 ? 's' : ''} ${mins} mins`;
}

/**
 * Fallback: Extract from meta tags
 */
function extractFromMetaTags(html, sourceUrl) {
  const getMetaContent = (property) => {
    const match = html.match(new RegExp(`<meta[^>]*(?:property|name)=["']${property}["'][^>]*content=["']([^"']*)["']`, 'i')) ||
                  html.match(new RegExp(`<meta[^>]*content=["']([^"']*)["'][^>]*(?:property|name)=["']${property}["']`, 'i'));
    return match ? match[1] : '';
  };

  const title = getMetaContent('og:title') ||
                getMetaContent('twitter:title') ||
                (html.match(/<title>([^<]*)<\/title>/i) || [])[1] || '';

  const description = getMetaContent('og:description') ||
                      getMetaContent('description') || '';

  const imageUrl = getMetaContent('og:image') ||
                   getMetaContent('twitter:image') || '';

  if (!title) return null;

  return {
    recipeName: title.trim(),
    description: description.trim(),
    imageUrl: imageUrl,
    ingredients: [],
    cookingInstructions: [],
    prepTime: '',
    cookTime: '',
    totalTime: '',
    servings: '',
    sourceUrl: sourceUrl,
    success: true,
    partialData: true // Flag that this is incomplete
  };
}

/**
 * Sleep for a given number of milliseconds
 */
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Main function
 */
async function main() {
  // Check for input file
  if (!existsSync(INPUT_FILE)) {
    console.log(`\nError: ${INPUT_FILE} not found.`);
    console.log('Please create a file with recipe URLs, one per line.');
    console.log('\nOr run: node extract-pinterest-urls.js <pinterest-export.html>');
    return;
  }

  // Read URLs
  const urls = readFileSync(INPUT_FILE, 'utf-8')
    .split('\n')
    .map(u => u.trim())
    .filter(u => u && u.startsWith('http'));

  if (urls.length === 0) {
    console.log('No valid URLs found in recipe-urls.txt');
    return;
  }

  console.log(`Found ${urls.length} URLs to scrape...\n`);

  const recipes = [];
  const failed = [];
  let successCount = 0;
  let partialCount = 0;

  for (let i = 0; i < urls.length; i++) {
    const url = urls[i];
    console.log(`[${i + 1}/${urls.length}] Processing...`);
    console.log(`Scraping: ${url}`);

    try {
      const html = await fetchUrl(url);
      const recipe = extractRecipeFromHtml(html, url);

      if (recipe) {
        recipes.push(recipe);
        if (recipe.partialData) {
          console.log(`  Partial: ${recipe.recipeName} (no structured data)`);
          partialCount++;
        } else {
          console.log(`  Success: ${recipe.recipeName}`);
          successCount++;
        }
      } else {
        console.log(`  Failed: No recipe data found`);
        failed.push({ url, error: 'No recipe data found' });
      }
    } catch (error) {
      console.log(`  Failed: ${error.message}`);
      failed.push({ url, error: error.message });
    }

    // Be polite to servers
    if (i < urls.length - 1) {
      await sleep(DELAY_MS);
    }
  }

  // Write results
  const output = {
    scrapedAt: new Date().toISOString(),
    totalUrls: urls.length,
    successful: successCount,
    partial: partialCount,
    failed: failed.length,
    recipes: recipes
  };

  writeFileSync(OUTPUT_FILE, JSON.stringify(output, null, 2));

  console.log(`\n==================================================`);
  console.log(`Scraping Complete!`);
  console.log(`==================================================`);
  console.log(`Total URLs:     ${urls.length}`);
  console.log(`Full Success:   ${successCount}`);
  console.log(`Partial Data:   ${partialCount}`);
  console.log(`Failed:         ${failed.length}`);
  console.log(`\nResults saved to: ${OUTPUT_FILE}`);
  console.log(`\nNext step: Run 'node import-to-firestore.js' to import recipes`);
  console.log(`==================================================`);

  if (failed.length > 0) {
    console.log('\nFailed URLs:');
    failed.slice(0, 20).forEach(f => {
      console.log(`  ${f.url}: ${f.error}`);
    });
    if (failed.length > 20) {
      console.log(`  ... and ${failed.length - 20} more`);
    }
  }
}

main().catch(console.error);
