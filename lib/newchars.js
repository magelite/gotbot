'use strict';

var fs = require('fs');
const _ = require('underscore');
const cheerio = require('cheerio');
const Promise = require("bluebird");
Promise.promisifyAll(fs);

const morecrew = require('../client/morecrew.json');

let cmd = "wget -O 'client/stt.wiki/newpages.html' https://stt.wiki/w/index.php?title=Special:NewPages";
const shell = require('child_process').execSync ;
shell(cmd);

const file = `client/stt.wiki/newpages.html`;
return fs.readFileAsync(file, 'utf8')
  .then(cheerio.load)
  .then(function($) {
    const crewlinks = $('ul li');
    let newCrew = 0;
    //const crewlinks = $('.mw-category-generated a');
    crewlinks.each(function(i,elem) {
      const a = $(this);
      if (a.text().match('Crew/add')) {
        const crew = a.find('.mw-newpages-pagename');
        const title = crew.text();
        const wiki = crew.attr('href');
        const stars = a.text().match('stars=([1-5])')[1];

        if (_.some(morecrew, x=>x.name === title)) {
          console.log(`${title} already is in morecrew`);
        }
        else {
          newCrew++;
          morecrew.push({name:title, wiki:wiki, stars:+stars});
          console.log(title + wiki + stars);
        }

        //wikidb.crewentries.push({name: copyString(a.text()), wiki: copyString(a.attr('href')), stars: stars});
      }
    });

    if (newCrew) {
      fs.renameSync('client/morecrew.json', `client/.morecrew.${+Date.now()}.json`, err=>{if (err) {console.log('Failed to rename:'+err);}});
      console.log('Writing new morecrew.json');
      fs.writeFileSync('client/morecrew.json', JSON.stringify(morecrew,null,4) );
    }

  })
  .catch(function(e){throw e;});