.import QtQuick.LocalStorage 2.0 as LS

//  BEGIN  GLOBALS
var dbVersion = "1.1";
var columnNames = ['value1', 'value2', 'value3', 'value4']
var exerciseTimeValues = {
  CircleInterval: {
    value1: true
  },
  IntervalSet: {
    value1: true
  },
  SuperSet: {
    value1: true
  },
  Ladder: {
    value1: true
  },
  Tabata: {
    value2: true,
    value3: true
  }
}
var exerciseNames = Object.keys(exerciseTimeValues)
//  END GLOBALS

function openDatabase() {
  try {
    return LS.LocalStorage.openDatabaseSync("bodyweighttimer", "1.0", "Database for bodyweight-timer", 100000);
  } catch (err) {
    console.log("OpenDatabaseSync:", err, err.stack);
  }
}

function initializeDatabase() {
  var checkInitialized;
  var currentDbVersion;
  var checkMetaExists;
  var db = openDatabase();

  try {
    db.transaction(function (tx) {
      checkMetaExists = tx.executeSql('SELECT name FROM sqlite_master WHERE type=? AND name=?', ['table', 'meta']);

      if ((checkMetaExists.rows.length !== 1)) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS meta (version TEXT, blankingDisabled INTEGER)');
        tx.executeSql('INSERT INTO meta (version, blankingDisabled) VALUES (?,?)', [dbVersion, 1]);
        tx.executeSql('CREATE TABLE IF NOT EXISTS exercises (exercise TEXT UNIQUE, value1 INT, value2 INT, value3 INT, value4 INT)')
        tx.executeSql('INSERT INTO exercises (exercise) VALUES (?),(?),(?),(?),(?)', exerciseNames)
        defaultDatabaseValuesForAll()
      } else {
        currentDbVersion = tx.executeSql('SELECT version FROM meta;')
    
        if (currentDbVersion.rows.item(0)["version"] !== dbVersion) {
          tx.executeSql('UPDATE meta SET version =?', [dbVersion]);
          tx.executeSql('DROP TABLE IF EXISTS exercises')
          tx.executeSql('CREATE TABLE IF NOT EXISTS exercises (exercise TEXT UNIQUE, value1 INT, value2 INT, value3 INT, value4 INT)')
          tx.executeSql('INSERT INTO exercises (exercise) VALUES (?),(?),(?),(?),(?)', exerciseNames)
          defaultDatabaseValuesForAll()
        }
      }
    })
  } catch (err) {
    console.log("initializeDatabase: ", err, err.stack);
  }
}

function defaultDatabaseValuesForAll() {
  for (var i = 0; i < exerciseNames.length; i++) {
    defaultDatabaseValuesFor(exerciseNames[i])
  }
}

function defaultDatabaseValuesFor(exercise) {
  var value1 = 0;
  var value2 = 0;
  var value3 = 0;
  var value4 = 0;

  switch (exercise) {
    case "CircleInterval":
      value1 = 1200
      break;
    case "IntervalSet":
      value1 = 180
      value2 = 3
      value3 = 4
      break;
    case "SuperSet":
      value1 = 240
      value2 = 3
      value3 = 4
      break;
    case "Ladder":
      value1 = 450
      value2 = 4
      break;
    case "Tabata":
      value1 = 8
      value2 = 20
      value3 = 10
      value4 = 3
      break;
  }

  var db = openDatabase();

  try {
    db.transaction(
      function (tx) {
        tx.executeSql('UPDATE exercises SET value1=?, value2=?, value3=?, value4=? WHERE exercise=?', [value1, value2, value3, value4, exercise]);
      }
    )
  } catch (err) {
    console.log("defaultDatabaseValuesFor", err, err.stack);
  }
}

function setDatabaseValuesFor(exercise, column, value) {
  var ErrorOccured = false;

  var db = openDatabase();
  try {
    db.transaction(
      function (tx) {
        //TODO: Why cant I use positional parameter for column?
        tx.executeSql('UPDATE exercises SET ' + column + ' = ? WHERE exercise=?', [value, exercise]);
      }
    )
  } catch (err) {
    console.log("setDatabaseValuesFor:", err, err.stack);
    ErrorOccured = true;
  }
  return ErrorOccured;
}


function getDatabaseValuesFor(exerciseName, cb) {
  try {
    var db = openDatabase()
    db.transaction(function (tx) {
      var result = tx.executeSql('SELECT * FROM exercises WHERE exercise=?;', [exerciseName])
      var databaseEntry = result.rows.item(0)

      var column = {}
      for (var i = 0; i < columnNames.length; i++) {
        var columnName = columnNames[i]
        var value = databaseEntry[columnName]
        // TODO: cleanup old database table. Remove equality check for 0 afterwards
        if (value === 0 || value == null) {
            continue
        }

        column[columnName] = {
          name: columnName,
          shallDisplay: value !== 0,
          value: value,
          isTime: exerciseTimeValues[exerciseName][columnName] === true
        }
      }

      cb(column)
    })
  } catch (err) {
    console.log("getDatabaseValuesFor", err, err.stack)
    return null
  }
}
