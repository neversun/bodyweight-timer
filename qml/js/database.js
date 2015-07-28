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
                    tx.executeSql('CREATE TABLE IF NOT EXISTS meta (version TEXT, blankingDisabled INTEGER)');
                    tx.executeSql('INSERT INTO meta (version, blankingDisabled) VALUES (?,?)',[dbVersion,1]);
                })
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
            tx.executeSql('INSERT INTO exercises (exercise) VALUES (?),(?),(?),(?),(?)', ['CircleInterval','IntervalSet','SuperSet','Ladder','Tabata']); }
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
    defaultDatabaseValuesFor('CircleInterval');
    defaultDatabaseValuesFor('IntervalSet');
    defaultDatabaseValuesFor('SuperSet');
    defaultDatabaseValuesFor('Ladder');
    defaultDatabaseValuesFor('Tabata');
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
    case "CircleInterval":
        value1=1200; value2=0;value3=0;value4=0;value1Desc="duration";value2Desc="ε";value3Desc="ε";value4Desc="ε";explanation="Do as much as you can for the duration of the exercise.\n\nReduce pauses to a minimum.\n\nTripple bell = end.";
        break;
    case "SuperSet":
        value1=240; value2=3;value3=4;value4=0;value1Desc="duration per set";value2Desc="sets per exercise";value3Desc="number exercises";value4Desc="ε";explanation="In a 4 minute set do the first superset (a pair of 2 exercises).\nDo at repetition 1 to 5 the first pair-exercise, and at repetition 6 to 12 the second pair-exercise. \nFirst pair-exercise should not cause you musle malfunction.\n\nSingle bell = next set\nDouble bell = next exercise\nTripple bell = end.";
        break;
    case "IntervalSet":
        value1=180; value2=3;value3=4;value4=0;value1Desc="duration per set";value2Desc="sets per exercise";value3Desc="number exercises";value4Desc="ε";explanation="In a 3 minute set do 6 to 12 repetitions (stop on muscle malfunction). Pause rest of the set.\n\n1 of 3 sets should cause you to muscle malfunction. Do harder/another exercise if not.\n\nSingle bell = next set\nDouble bell = next exercise\nTripple bell = end";
        break;
    case "Ladder":
        value1=450; value2=4;value3=0;value4=0;value1Desc="duration per exercise";value2Desc="exercises";value3Desc="ε";value4Desc="ε";explanation="Do 1 repetition of an exercise and pause the time it took you do to so. Then do 2 repetitions and pause the time it took you to do these 2. And so forth.\nOn muscle malfunction reduce the repetitions by 1, then by another and so forth.\n\nAlready at 1 repetition again and time is not over? Start a new ladder!\n\nSingle bell = next exercise\nTripple bell = end";
        break;
    case "Tabata":
        value1=8; value2=20;value3=10;value4=3;value1Desc="rounds per exercise";value2Desc="duration of active time";value3Desc="duration of pause";value4Desc="number exercises";explanation="During active time (green) move on. During pause time (red) pause.\n\nTry to find your ideal tempo (consistent repetitions).\n\nSingle bell = active time begins\nDouble bell = pause time begins\nTripple bell = next exercise or end.";
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

/*  Returns a boolean value, if blanking is disabled
*/
function isBlankingDisabled() {
    var result;
    var returnValue;
    var db = openDatabase();

    try {
    db.transaction( function(tx) {
        result = tx.executeSql('SELECT blankingDisabled FROM meta;')
                })
    } catch (err) {
        console.log("isBlankingDisabled" +err);
    }
    returnValue = result.rows.item(0)["blankingDisabled"]
    if(returnValue === 0) {
        returnValue = false;
    }
    if(returnValue === 1) {
        returnValue = true;
    }
    return returnValue;
}

/*  Updates blanking value in meta-table
*   @param {bool} boleanValue - boolean value if blanking should be disabled
*/
function setBlankingDisabled(boleanValue) {
    var ErrorOccured=false;
    var integerValue;

    if(boleanValue === false) {
        integerValue = 0;
    }
    if(boleanValue === true) {
        integerValue = 1;
    }

    var db = openDatabase();
    try {
        db.transaction(
                function(tx) {
                    //TODO: Why cant I use positional parameter for column?
                    tx.executeSql('UPDATE meta SET blankingDisabled =?;', [integerValue]);
                }
        )
    } catch (err)
    {
        console.log("setBlankingDisabled:"+err);
        ErrorOccured=true;
    }
    return ErrorOccured;
}
