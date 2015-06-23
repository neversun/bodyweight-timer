.import QtQuick.LocalStorage 2.0 as LS

//  BEGIN  GLOBALS
var dbVersion="1.0";
//  END GLOBALS

/*  Open and/or create the database
*/
function openDatabase() {
    try {
        return LS.LocalStorage.openDatabaseSync("bodyweighttimer","1.0","Database for bodyweight-timer",100000);
    } catch (err) {
        console.log("OpenDatabaseSync:"+err );
    }
}

/*  Intialize the database with default values, if needed
*/
function initializeDatabase() {
    var checkInitialized;
    var currentDbVersion;
    var checkMetaExists;
    var db = openDatabase();

    //Check if db is at current global dbVersion
    try {
        db.transaction( function (tx) {checkMetaExists = tx.executeSql('SELECT name FROM sqlite_master WHERE type=? AND name=?',['table','meta']);})
    } catch (err) { console.log("checkMetaExists: "+ err); }

    if((checkMetaExists.rows.length === 1)) {
        try {
             db.transaction( function (tx) {currentDbVersion = tx.executeSql('SELECT version FROM meta;');})
        } catch (err) { console.log ("checkMetaExists: "+err); }

        if(currentDbVersion.rows.item(0)["version"] !== dbVersion) {
            defaultDatabaseValuesForAll();
            db.transaction(
                function(tx) {
                tx.executeSql('UPDATE meta SET version =?',[dbVersion]);})
        }
    } else {
        try {
            db.transaction(
                function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS meta (version TEXT)');
                tx.executeSql('INSERT INTO meta (version) VALUES (?)',[dbVersion]);})
        } catch (err) { console.log("create and fill meta table: "+err); }
    }


    //Init table with default exercises, if not exists
    try {
    db.transaction( function(tx) {checkInitialized = tx.executeSql('SELECT name FROM sqlite_master WHERE type=? AND name=?',['table','exercises']);})
    } catch (err) {
        console.log("initializeDatabase.checkExist:" + err);
    }

     if(!(checkInitialized.rows.length === 1)) {
        try {
        db.transaction(
            function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS exercises (exercise TEXT UNIQUE, value1Desc TEXT, value2Desc TEXT, value3Desc TEXT, value4Desc TEXT, value1 INT, value2 INT, value3 INT, value4 INT, explanation TEXT)');
            tx.executeSql('INSERT INTO exercises (exercise) VALUES (?),(?),(?),(?),(?)', ['circleInterval','intervalSet','superSet','ladder','tabata']); }
        )
        } catch (err) {
            console.log("initializeDatabase.createTable:" + err);
    }
        defaultDatabaseValuesForAll();
    }
}

/*  Sets the default values for all exercises
*/
function defaultDatabaseValuesForAll() {
    defaultDatabaseValuesFor('circleInterval');
    defaultDatabaseValuesFor('intervalSet');
    defaultDatabaseValuesFor('superSet');
    defaultDatabaseValuesFor('ladder');
    defaultDatabaseValuesFor('tabata');
}

/*  Sets the default values for a exercise
*   @param {string} exercise - Name of exercise, which should be reset to default
*/
function defaultDatabaseValuesFor(exercise) {
    var value1=0;
    var value2=0;
    var value3=0;
    var value4=0;
    var value1Desc="";
    var value2Desc="";
    var value3Desc="";
    var value4Desc="";
    var explanation="";

    //ε = empty (word)
    switch(exercise){
    case "circleInterval":
        value1=1200; value2=0;value3=0;value4=0;value1Desc="duration";value2Desc="ε";value3Desc="ε";value4Desc="ε";explanation="Do as much as you can in the specified time without making a pause.\nAt least reduce pauses to a minimum.";
        break;
    case "superSet":
        value1=240; value2=3;value3=4;value4=0;value1Desc="duration per set";value2Desc="sets per exercise";value3Desc="number exercises";value4Desc="ε";explanation="In a 4 minute set do the first superset (a pair of 2 exercises).\nDo at repetition 1 to 5 the pair-exercise 1, and at repetition 6 to 12 pair-exercise 2. \nFirst pair-exercise should not cause you musle malfunction.";
        break;
    case "intervalSet":
        value1=180; value2=3;value3=4;value4=0;value1Desc="duration per set";value2Desc="sets per exercise";value3Desc="number exercises";value4Desc="ε";explanation="In a 3 minute set do 6 to 12 repetitions (stop on muscle malfunction). Pause rest of the set.\n1 of 3 sets should cause you to muscle malfunction. Do harder/another exercise if not.";
        break;
    case "ladder":
        value1=450; value2=4;value3=0;value4=0;value1Desc="duration per exercise";value2Desc="exercises";value3Desc="ε";value4Desc="ε";explanation="Do 1 repetition of an exercise and then pause the time you needed for this one.\nThen do 2 repetitions and pause the time you needed now and so on.\nOn muscle malfunction reduce the repitions by 1, then by another and so on.\nAlready at 1 repition again and time is not over? Start a new ladder!";
        break;
    case "tabata":
        value1=8; value2=20;value3=10;value4=3;value1Desc="rounds per exercise";value2Desc="duration of active time";value3Desc="duration of pause";value4Desc="number exercises";explanation="Do one set of exercises after another. While 'active time' move on. While 'pause time' pause.\nTry to find your ideal tempo (consistent repetitions).";
        break;
    }

    var db = openDatabase();

    try {
    db.transaction(
                function(tx) {
                    tx.executeSql('UPDATE exercises SET value1=?, value2=?, value3=?, value4=?, value1Desc=?, value2Desc=?, value3Desc=?, value4Desc=?,explanation=? WHERE exercise=?', [value1,value2,value3,value4,value1Desc,value2Desc,value3Desc,value4Desc,explanation,exercise]);
                }
    )
    } catch (err)
    {
        console.log("defaultDatabaseValuesFor" + err);
    }
}

/*  Update a column at exercises-table where a specific exercise is present
*   @param {string} exercise - Name of exercise, which should be touched
*   @param {string} column - Name of the column to update
*   @param {string} value - Value to set at column
*/
function setDatabaseValuesFor(exercise,column,value) {
    var ErrorOccured=false;
    console.log(exercise)
    console.log(column)
    console.log(value)

    var db = openDatabase();
    try {
        db.transaction(
                function(tx) {
                    //TODO: Why cant I use positional parameter for column?
                    tx.executeSql('UPDATE exercises SET ' + column + ' = ? WHERE exercise=?', [value,exercise]);
                }
        )
    } catch (err)
    {
        console.log("setDatabaseValuesFor:"+err);
        ErrorOccured=true;
    }
    return ErrorOccured;
}

/*  Get a column value of a specific exercise. Returns if this value should be displayed in view and if it is a time value.
*   @param {string} exercise - Name of exercise, which should be showed
*   @param {string} column - Name of the column to read value of
*   @returns {string} [0] - column value
*   @returns {bool} [1] - should be displayed in view?
*   @returns {bool} [2] - is a time value?
*/
function getDatabaseValuesFor(exercise,column) {
    var result;
    var db = openDatabase();

    //false = dont display in qml view
    var used=true;

    //false = not a time
    var timeValue=false;

    //return a array to qml
    var returnValue=[];


    try {
    db.transaction( function(tx) {
        result = tx.executeSql('SELECT * FROM exercises WHERE exercise=?;', [exercise]);
                }
    )
    } catch (err) {
        console.log("getDatabaseValuesFor" +err);
    }

    //should this db-entry be viewed?
    if(result.rows.item(0)[column]===0) {
        used=false;
    }

    //is this entry a time value?
    var timeString = result.rows.item(0)[column].toString();
    timeValue = timeString.match(/(^|\s)duration(?=\s|$)/g)
    if(timeValue===null){timeValue=false}else{timeValue=true}

    returnValue.push(result.rows.item(0)[column]);
    returnValue.push(used);
    returnValue.push(timeValue)
    return returnValue;
}
