$(function(){
  var columns_info = $('#columns_info').val();
  var db = null;

  try {
    if (window.openDatabase) {
      db = openDatabase('tourism', '1.0', 'Local storage', 20000);
      if (!db)
        alert("Failed to open the database on disk.  This is probably because the version was bad or there is not enough space left in this domain's quota");
      }
      // else
        //alert("Couldn't open the database.  Please try with a WebKit nightly with this feature enabled");
  } catch(err) {
    db = null;
    //alert("Couldn't open the database.  Please try with a WebKit nightly with this feature enabled");
  }

  function drop_table(table) {
    db.transaction(function(tx) {
      tx.executeSql('DROP TABLE ' + table);
    });
  }

  function create_settings() {
    db.transaction(function(tx) {
      tx.executeSql('CREATE TABLE IF NOT EXISTS tourism_settings (id INTEGER PRIMARY KEY, name TEXT, value TEXT)');
    });

    var now = new Date();
    setting('updated_at', now.toUTCString());
  }

  function setting(name, value) {
    if(value == undefined){
      // getter
      var value;
      db.transaction(function(tx) {
        tx.executeSql('SELECT * FROM tourism_settings WHERE name = ?', [name], function (tx, results) {
          if (results.rows.length == 1) {
            value = results.rows.item(0).value;
          }
        });
      });
      return value;
    } else {
      // setter
      db.transaction(function(tx) {
        tx.executeSql('SELECT * FROM tourism_settings WHERE name = ?', [name], function (tx, results) {
          if (results.rows.length == 1) {
            tx.executeSql("UPDATE tourism_settings SET value = ? WHERE name = ?", [value, name]);
          } else {
            tx.executeSql("INSERT INTO tourism_settings (name, value) VALUES (?, ?)", [name, value]);
          }
        });
      });
    }
  }

  function create_storage() {
    drop_table('tourism_claims');
    db.transaction(function(tx) {
      tx.executeSql('CREATE TABLE IF NOT EXISTS tourism_claims (' + columns_info + ')');
    });
  }

  function fill_storage(updated_at) {
    $.ajax({
      url: '/dashboard/claims/all/',
      data: { updated_at : updated_at },
      success: function(resp) {
        columns = columns_info.split(', ');

        for (var i = 0; i < resp.length; i++) {
          var obj = resp[i];
          var fields = '';
          var values = '';

          for (method in obj) {
            if (obj[method] != '') {
              fields += method + ', ';
              if (columns.indexOf(method + ' TEXT') > 0) {
                values += '\'' + obj[method] + '\', ';
              } else {
                values += obj[method] + ', ';
              }
            }
          }

          fields = '(' + fields.replace(/, $/, ')');
          values = '(' + values.replace(/, $/, ')');

          db.transaction(function(tx) {
            tx.executeSql("INSERT INTO tourism_claims " + fields + " VALUES " + values);
          });
        }
      }
    });
  }

  if (db && $('#columns_info').length > 0) {
    drop_table('tourism_settings');
    create_settings()
    create_storage();
    fill_storage();
  }
});
