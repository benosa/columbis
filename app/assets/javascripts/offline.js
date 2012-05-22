$(function() {

  window.dao = {
  columnsInfo: $('#columns_info').val(),
  syncURL: "/dashboard/claims/all/",

  initialize: function(callback) {

    var self = this;
    this.db = window.openDatabase("tourism", "1.0", "Sync DB", 20000);

    // Testing if the table exists is not needed and is here for logging purpose only. We can invoke createTable
    // no matter what. The 'IF NOT EXISTS' clause will make sure the CREATE statement is issued only if the table
    // does not already exist.
    this.db.transaction(
      function(tx) {
        tx.executeSql("SELECT name FROM sqlite_master WHERE type='table' AND name='claims'", this.txErrorHandler,
        function(tx, results) {
          if (results.rows.length == 1) {
            log('Using existing Calims table in local SQLite database');
          } else {
            log('Calims table does not exist in local SQLite database');
            self.createTable(callback);
          }
        });
      }
    )

  },

  createTable: function(callback) {

    var self = this;
    this.db.transaction(
      function(tx) {
        var sql = 'CREATE TABLE IF NOT EXISTS claims (' + self.columnsInfo + ')';
        tx.executeSql(sql);
      },
      this.txErrorHandler,
      function() {
        log('Table claims successfully CREATED in local SQLite database');
        callback();
      }
    );

  },

  dropTable: function(callback) {

    this.db.transaction(
      function(tx) {
        tx.executeSql('DROP TABLE IF EXISTS claims');
      },
      this.txErrorHandler,
      function() {
        log('Table claims successfully DROPPED in local SQLite database');
        callback();
      }
    );

  },

  findAll: function(callback) {

    this.db.transaction(
      function(tx) {
        var sql = "SELECT * FROM claims";
        log('Local SQLite database: "SELECT * FROM claims"');
        tx.executeSql(sql, this.txErrorHandler,
          function(tx, results) {
            var len = results.rows.length,
              claims = [],
              i = 0;
            for (; i < len; i = i + 1) {
              claims[i] = results.rows.item(i);
            }
            log(len + ' rows found');
            callback(claims);
          }
        );
      }
    );

  },

  getLastSync: function(callback) {

    this.db.transaction(
      function(tx) {
        var sql = "SELECT MAX(updated_at) as updated_at FROM claims";
        tx.executeSql(sql, this.txErrorHandler,
          function(tx, results) {
            var lastSync = results.rows.item(0).updated_at;
            log('Last local timestamp is ' + lastSync);
            callback(lastSync);
          }
        );
      }
    );

  },

  sync: function(callback) {

    var self = this;
    log('Starting synchronization...');
    this.getLastSync(function(lastSync){
      self.getChanges(self.syncURL, lastSync,
        function (changes) {
          if (changes.length > 0) {
            self.applyChanges(changes, callback);
          } else {
            log('Nothing to synchronize');
            callback();
          }
        }
      );
    });

  },

  getChanges: function(syncURL, modifiedSince, callback) {

    $.ajax({
      url: syncURL,
      data: {updated_at: modifiedSince},
      dataType:"json",
      success:function (data) {
        log("The server returned " + data.length + " changes that occurred after " + modifiedSince);
        callback(data);
      },
      error: function(model, response) {
        alert(response.responseText);
      }
    });

  },

  applyChanges: function(employees, callback) {

    this.db.transaction(
      function(tx) {
        var l = employees.length;
        var sql =
          "INSERT OR REPLACE INTO claims (id ) " +
          "VALUES (?)";
        log('Inserting or Updating in local database:');
        var e;
        for (var i = 0; i < l; i++) {
          e = employees[i];
          log(e.id);
          var params = [e.id];
          tx.executeSql(sql, params);
        }
        log('Synchronization complete (' + l + ' items synchronized)');
      },
      this.txErrorHandler,
      function(tx) {
        callback();
      });
    },
    txErrorHandler: function(tx) {
      alert(tx.message);
    }

  };

  dao.initialize(function() {
      console.log('database initialized');
  });

  $('#reset').on('click', function(e) {
    e.preventDefault();
    dao.dropTable(function() {
      dao.createTable();
    });
  });

  $('#sync').on('click', function(e) {
    e.preventDefault();
    dao.sync(renderList);
  });

  $('#render').on('click', function(e) {
    e.preventDefault();
    renderList();
  });

  $('#clearLog').on('click', function(e) {
    e.preventDefault();
    $('#log').val('');
  });

  function renderList(employees) {
      log('Rendering list using local SQLite data...');
//      dao.findAll(function(employees) {
//          $('#list').empty();
//          var l = employees.length;
//          for (var i = 0; i < l; i++) {
//              var employee = employees[i];
//              $('#list').append('<tr>' +
//                  '<td>' + employee.id + '</td>' +
//                  '<td>' +employee.firstName + '</td>' +
//                  '<td>' + employee.lastName + '</td>' +
//                  '<td>' + employee.title + '</td>' +
//                  '<td>' + employee.officePhone + '</td>' +
//                  '<td>' + employee.deleted + '</td>' +
//                  '<td>' + employee.lastModified + '</td></tr>');
//          }
//      });
  }

  function log(msg) {
    $('#log').val($('#log').val() + msg + '\n');
  }

});
