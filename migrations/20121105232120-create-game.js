var dbm = require('db-migrate');
var type = dbm.dataType;

exports.up = function(db, callback) {
  db.createTable('games', {
    id: { type: 'int', primaryKey: true, autoIncrement: true },
    name: 'string',
    turn_time: 'int',
    winner: 'int',
    owner: 'int'
  }, callback);
};

exports.down = function(db, callback) {
  db.dropTable('games', callback);
};
