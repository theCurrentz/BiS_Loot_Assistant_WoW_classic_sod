const puppeteer = require('puppeteer');
const fs = require('fs');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto('https://www.zockify.com/wowclassic/builds/#builds');

  const urls = await page.evaluate(() => {
    const builds = document.querySelector('#builds');
    const tableRows = builds.nextElementSibling.nextElementSibling.firstChild.children[1].children

    return Array.from(tableRows).map((tr) =>tr.children[1].firstChild.href)
  });

  console.log(JSON.stringify({urls}, null, 2));

  const lootToClassMap = {};

  for (let i = 0; i < urls.length; i++) {
    await page.goto(urls[i], {timeout: 0})
    const { title, lootItems }= await page.evaluate(() => {
      const title = document.querySelector('h1').children[0].textContent;
      const lootItems = [];

      const slotItemsPairs = document.querySelector('[id^=sod-phase-2-bis-list-').nextElementSibling.nextElementSibling.children


      Array.from(slotItemsPairs).forEach((pair) => {
        const slot = pair.querySelector('strong').textContent;
        const items = Array.from(pair.querySelectorAll('[data-z-tooltip]'));
        lootItems.push(...items.map((e) => {
          const regex = /(\d+)$/;
          const match = e.dataset.zTooltip.match(regex)[1];
          return match
        }));
      });

      return {title, lootItems}
    })

    lootItems.forEach((e) => {
      if (lootToClassMap[e]) {
        lootToClassMap[e].push(title)
      } else {
        lootToClassMap[e] = [title]
      }
    });
  }

  
// Convert JavaScript object to Lua table syntax
  let luaPrefix = 'local AddonName, LootMapSandbox = ...\n'
  let luaTable = luaPrefix + 'LootMapSandbox.lootMap = {\n';
  for (const key in lootToClassMap) {
    luaTable += `  ["${key}"] = {\n    `;
    lootToClassMap[key].forEach((value, index) => {
      luaTable += `'${value}'`;
      if (index !== lootToClassMap[key].length -  1) {
        luaTable += ', ';
      }
    });
    luaTable += '},\n';
  }
  luaTable += '}\n\nreturn lootMap\n';

  fs.writeFile('lootMap.lua', luaTable, (err) => {
    if (err) throw err;
    console.log('Loot map generation success!');
    console.log(lootToClassMap);
  });

  await browser.close();
})();