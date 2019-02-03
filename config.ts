const nodeEnv = process.env.NODE_ENV || 'development';
const isProd = nodeEnv === 'production';

let password = require('./data/password');
let dataPath = './data/';

export default class Config {

  // The bot's command prefix. The bot will recognize as command any message that begins with it.
  // i.e: "-got bot foo" will trigger the command "foo",
  //      whereas "Got Bot foo" will do nothing at all.
  static readonly prefix = isProd ? '-got bot' : '-dev bot';

  // Your bot name. Typically, this is your bot's username without the discriminator.
  // i.e: if your bot's username is MemeBot#0420, then this option would be MemeBot.
  static readonly botName = isProd ? 'Got Bot' : 'Proto Bot';
  static readonly dataPath = dataPath;

  static readonly token =isProd ? password.prod : password.dev;
  static readonly gotServer = '235536091011088394'; // id of the GoT fleet server
  static readonly adminId = '232748347860058112'; // id of the bot administrator
  static readonly botServer = '307163779680960512'; // if of bot home server

  static readonly httpport = 3030;
  static readonly baseUrl = 'http://got.glorat.net/';
  static nedbpath =  Config.dataPath + 'stt.json';
  static readonly clilogpath = Config.dataPath + 'clilog.json';
  static readonly wikidbpath = Config.dataPath + 'wikidb.json';
};
