(function() {

  function defer_func(func) {
    return function() {
      var deferred = new $.Deferred();
      var args = [];
      for (var i = 0; i < arguments.length; i++)
        args.push(arguments[i]);
      args.push(deferred);
      func.apply(this, args);
      return deferred.promise();
    };
  };

  var Tourism = {

    db: null,
    tables: [],
    tables_info: {},
    content_selector: '#content',
    online: null,
    current_user: window.tourism_current_user || '',
    current_company: window.tourism_current_company || '',
    prefix: 'tourism-' + window.tourism_current_user + '-',

    defer: function(obj) {
      for (var p in obj)
        this[p] = defer_func(obj[p]);
    },

    error: function (error) {
      console.log("Error: ", error);
    },

    message: function(text, status) {
      status = status || 'notice';
    },

    init_db: function() {
      this.db = null;
      if (this.current_user && this.current_user.length) {
        try {
          if (window.openDatabase) {
            this.db = openDatabase(this.prefix + 'db', '1.0', 'Local storage', 10*1024*1024); // 10Mb
            if (!this.db)
              this.message("Failed to open the database on disk. This is probably because there is not enough space left in this domain's quota");
          }
        } catch(err) {
          this.message("Couldn't open the database. This is probably because your browser doesn't support a local database (WebSQL)");
        }
      }
      return !!this.db;
    },

    transaction: function(callback, deferred) {
      if (deferred)
        this.db.transaction(callback, function(err) {
          self.error(err);
          deferred.reject();
        }, function() {
          deferred.resolve();
        });
      else
        this.db.transaction(callback, self.error);
    },

    parse_table_columns: function (table, columns) {
      var info = {};
      var fields = columns.split(', ');

      for (var j = 0; j < fields.length; j++) {
        var chunks = fields[j].split(' ');
        var field = chunks[0], type = chunks[1];
        info[field] = type;
      }

      return info;
    },

    cast_type: function (value, table, field, to_storage) {
      var type = this.tables_info[table][field];

      // while insert
      if (to_storage) {
        if (type == 'INTEGER') {
          if (typeof value == 'number');
          else if (typeof value == 'boolean')
            value = value ? 1 : 0;
          else {
            var i = parseInt(value);
            value = !isNaN(i) ? i : 0;
          }
        } else if (type == 'REAL') {
          if (typeof value == 'number');
          else {
            var f = parseFloat(value);
            value = !isNaN(f) ? f : 0;
          }
        } else if (type == 'TEXT') {
          if (typeof value == 'string' && value.indexOf("'") != -1)
            value = value.replace(/'/g, "''");
          value = "'" + value + "'";
        }
      // while select
      } else {
        if (value === null && (type == 'INTEGER' || type == 'REAL'))
          value = 0;
      }

      return value;
    },

    get_row: function (table, r) {
      // Clone a row object, because it may be cleane by gc
      var row = $.extend({}, r);

      // Cast types
      for (var k in row)
        row[k] = this.cast_type(row[k], table, k);

      return row;
    },

    first_row: function (rows) {
      return rows && rows.length > 0 ? rows.item(0) : {};
    },

    get_first_row: function (table, rows) {
      return this.get_row(table, this.first_row(rows));
    },

    get_rows: function(table, rows) {
      var res = [];
      if (rows && rows.length > 0) {
        for (var i = 0; i < rows.length; i++)
          res[i] = this.get_row(table, rows.item(i));
      }
      return res;
    },

    last_sync: function () {
      return localStorage.getItem(this.prefix + "last_sync");
    },

    set_last_sync: function (time) {
      time = time || new Date().toUTCString();
      localStorage.setItem(this.prefix + "last_sync", time);
    },

    route: function (path) {
      var route = {
        table: null,
        id: null,
        action: null
      };

      var chunks = path != '/' ? path.split('/') : [];
      if (chunks[0] === '') chunks.shift();
      if (chunks[0] == 'offline') chunks.shift();

      if (chunks.length) {
        route['table'] = chunks[0];
        route['action'] = 'index';

        if (chunks.length > 1) {
          if (/^\d+$/.test(chunks[1])) {
            route['id'] = chunks[1];
            route['action'] = 'show';
          } else
            route['action'] = chunks[1];
        }

        if (route['id'] && chunks.length > 2 && chunks[2] == 'edit')
          route['action'] = 'edit';

      } else {
        route['table'] = 'claims';
        route['action'] = 'index';
      }

      return route;
    },

    render: function (template, data) {
      if (!SMT[template]) {
        this.error('Could not find "' + template + '" template');
        return;
      }

      data = $.extend(this.process(data), { settings: this.settings() });
      var content = SMT[template](data);
      $(this.content_selector).html(content);
      if (typeof this.after_render == 'function')
        this.after_render();
    },

    after_render: function() {
      var path = location.pathname, $link;
      $('#documents_to_print_menu').find('a.selected').removeClass('selected');
      $link = $('#documents_to_print_menu').find('a[href="' + path + '"]');
      if ($link.length)
        $link.addClass('selected');
      $('#databases_menu').find('a.selected').removeClass('selected');
      $link = $('#databases_menu').find('a[href="' + path + '"]');
      if ($link.length)
        $link.addClass('selected');
    },

    process: function (data) {

      function _process_data(o, level) {
        for (var k in o) {
          if (!o[k] || typeof o[k] != 'object' || typeof o[k] == 'string') {
            _process_value(data, o, k, o[k]);
          } else if (o[k].constructor == Array) {
            for (var i = 0; i < o[k].length; i++)
              _process_data(o[k][i], level + 1);
          } else
            _process_data(o[k], level + 1);
        }
      };

      function _process_value(data, o, key, value) {
        if (/(^|_)currency$/.test(key))
          o[key + '_up'] = value.toUpperCase();
      };

      _process_data(data, 0);

      return data;
    },

    get_offline_version: function(callback) {
      $('<div style="display: none"><iframe src="/offline" height="0" width="0"></iframe></div>').appendTo(document.body);
    },

    last_cache_update: function() {
      return localStorage.getItem(this.prefix + "last_cache_update");
    },

    set_last_cache_update: function(time) {
      time = time || new Date().toUTCString();
      localStorage.setItem(this.prefix + "last_cache_update", time);
    },

    different_days: function(time1, time2) {
      if (!time1 || !time2)
        return true;

      var t1, t2;
      t1 = (typeof time1 == 'string') ? new Date(time1) : time1;
      t2 = (typeof time2 == 'string') ? new Date(time2) : time2;
      return (t1.getUTCFullYear() + t1.getUTCMonth() + t1.getUTCDate()) != (t2.getUTCFullYear() + t2.getUTCMonth() + t2.getUTCDate());
    },

    settings: function() {
      var settings = {};
      var str = decodeURIComponent(localStorage.getItem(this.prefix + "settings"));
      if (str.length) {
        var chunks = str.split('&');
        for (var i = 0; i < chunks.length; i++) {
          var parts = chunks[i].split('=');
          settings[parts[0]] = parts[1];
        }
      }
      return settings;
    },

    set_settings: function(settings) {
      settings = settings || {};
      var str = '';
      for (var p in settings)
        str += p + '=' + settings[p] + '&';
      str = encodeURIComponent(str.replace(/&$/, ''));

      localStorage.setItem(this.prefix + "settings", str);
    },

    offline_available: function() {
      return this.current_user.length && this.current_company.length;
    },

    // Drop database, clear localStorage data for current user and init one more
    reset_local_data: function() {
      $.ajaxSetup({ cache: false }); // don't use cached ajax responses
      localStorage.removeItem(this.prefix + "last_sync");
      localStorage.removeItem(this.prefix + "last_cache_update");
      localStorage.removeItem(this.prefix + "settings");
      this.drop_tables('all').done(function() {
        Tourism.init();
      });
    }

  };

  (function() {
    var self = Tourism;

    self.actions = {

      tourists: {

        index: function() {
          return {
            sql: 'SELECT * FROM tourists ORDER BY full_name',
            data: function (results) {
              var data = { tourists: [] };
              for (var i = 0; i < results.rows.length; i++) {
                var row = self.get_row('tourists', results.rows.item(i));
                data.tourists.push(row);
              }
              return data;
            }
          };
        },

        show: function(id) {
          return {
            sql: 'SELECT * FROM tourists WHERE id = ?',
            params: [id],
            data: function (results) { return self.get_first_row('tourists', results.rows); }
          };
        },

        edit: function(id) { return self.actions.tourists.show(id); }

      },

      claims: {

        index: function() {
          return {
            sql: 'SELECT * FROM claims ORDER BY id',
            data: function (results) {
              var data = {
                columns: {
                  office: !!self.tables_info['claims']['office'],
                  accountant_list: !!self.tables_info['claims']['profit']
                },
                claims: []
              };
              for (var i = 0; i < results.rows.length; i++) {
                var row = self.get_row('claims', results.rows.item(i));
                data.claims.push(row);
              }
              return data;
            }
          };
        },

        show: function(id) { return $.extend(self.actions.claims.edit(id), { view: 'edit' }); },

        edit: defer_func(function(id, deferred) {
          var self = Tourism;
          var claim;

          self.db.transaction(function(tx) {
            tx.executeSql('SELECT * FROM claims WHERE id = ?', [id], function (tx, results) {

              claim = self.get_first_row('claims', results.rows);

              if (claim.id && self.tables_info['tourists']) {
                tx.executeSql('SELECT * FROM tourists WHERE id = ?', [claim.applicant_id], function (tx, results) {
                  claim.applicant = self.get_first_row('claims', results.rows);
                });

                tx.executeSql('SELECT * FROM tourists WHERE id in (' + claim.dependent_ids + ')', [], function (tx, results) {
                  claim.dependents = [];
                  for (var i = 0; i < results.rows.length; i++) {
                    var row = self.get_row('claims', results.rows.item(i));
                    row.n = i;
                    row.ind = i + 2;
                    claim.dependents.push(row);
                  }
                });
              }

              if (claim.id && self.tables_info['payments']) {
                tx.executeSql('SELECT * FROM payments WHERE claim_id = ?', [id], function (tx, results) {
                  claim.payments_in = [];
                  claim.payments_out = [];
                  for (var i = 0; i < results.rows.length; i++) {
                    var row = self.get_row('claims', results.rows.item(i));
                    if (row['recipient_type'] == 'Company')
                      claim.payments_in.push(row);
                    else
                      claim.payments_out.push(row);
                  }
                });
              }

            });
          }, function(err) {
            self.error(err);
            deferred.reject();
          }, function() {
            deferred.resolve(claim);
          });

        })
      },

      operators: {

        index: function() {
          return {
            sql: 'SELECT * FROM operators ORDER BY name',
            data: function (results) {
              var data = { operators: [] };
              for (var i = 0; i < results.rows.length; i++) {
                var row = self.get_row('operators', results.rows.item(i));
                data.operators.push(row);
              }
              return data;
            }
          };
        },

        show: function(id) {
          return {
            sql: 'SELECT * FROM operators WHERE id = ?',
            params: [id],
            data: function (results) { return self.first_row(results.rows); }
          };
        },

        edit: defer_func(function(id, deferred) {
          var self = Tourism;
          var operator;

          self.db.transaction(function(tx) {
            tx.executeSql('SELECT * FROM operators WHERE id = ?', [id], function (tx, results) {

              operator = self.get_first_row('operators', results.rows);

              if (operator.id && self.tables_info['addresses']) {
                tx.executeSql('SELECT * FROM addresses WHERE id = ?', [operator.address_id], function (tx, results) {
                  operator.address = self.get_first_row('addresses', results.rows);
                });
              }
            });
          }, function(err) {
            self.error(err);
            deferred.reject();
          }, function() {
            deferred.resolve(operator);
          });
        })

      },

      dashboard: {
        edit_company: defer_func(function(id, deferred) {
          var self = Tourism;
          var company;

          self.db.transaction(function(tx) {
            tx.executeSql('SELECT * FROM companies LIMIT 1', [], function (tx, results) {

              company = self.get_first_row('companies', results.rows);

              if (company.id) {
                tx.executeSql('SELECT * FROM addresses WHERE addressable_type = ? AND addressable_id = ?', ['Company', company.id],
                function (tx, results) {
                  company.address = self.get_first_row('addresses', results.rows);
                });

                tx.executeSql('SELECT * FROM cities', [], function (tx, results) {
                  company.cities = self.get_rows('cities', results.rows);
                });

                tx.executeSql('SELECT * FROM offices WHERE company_id = ?', [company.id], function (tx, results) {
                  company.offices = self.get_rows('offices', results.rows);
                });
              }
            });
          }, function(err) {
            self.error(err);
            deferred.reject();
          }, function() {
            deferred.resolve(company);
          });
        }),

        index: function() { return {}; }
      },

      users: {
        edit: function() { return {}; }
      }

    };
  })();

  Tourism.defer({

    check_db: function (deferred) {
      var self = this;

      this.transaction(function(tx) {
        tx.executeSql('SELECT name, sql FROM sqlite_master WHERE type = "table"', [], function (tx, results) {
          var tables = [];
          for (var i = 0; i < results.rows.length; i++) {
            var row = results.rows.item(i);
            var table = row['name'];
            if (!table.match(/^__/)) {
              self.tables.push(row['name']);
              var start = row['sql'].indexOf('(') + 1;
              var end = row['sql'].indexOf(')') - 1;
              var columns = row['sql'].substr(start, end - start + 1);
              self.tables_info[table] = self.parse_table_columns(table, columns);
            }
          }
        });
      }, deferred);
    },

    drop_tables: function(tables, deferred) {
      var self = this,
          drop_all = false;
      if (typeof tables == 'string') {
        drop_all = tables == 'all';
        tables = drop_all ? this.tables : [tables];
      }
      this.transaction(function(tx) {
        for (var i in tables) {
          tx.executeSql('DROP TABLE IF EXISTS ' + tables[i]);
          delete self.tables_info[tables[i]];
        }

        if (drop_all) {
          self.tables = [];
        } else {
          var tmp = [];
          for (var i in self.tables)
            if ($.inArray(table, tables) == -1)
              tmp.push(table);
          self.tables = tmp;
        }
      }, deferred);
    },

    create_tables: function (tables, deferred) {
      var self = this;
      var data = {};

      if (tables)
        data['tables'] = tables;

      $.ajax({
        url: '/dashboard/local_tables/',
        data: data,
        dataType: 'json',
        success: function(json) {
          self.transaction(function(tx) {
            for (var table in json) {
              var columns = json[table].join(', ');
              var sql = 'CREATE TABLE IF NOT EXISTS ' + table + ' (' + columns + ')';
              tx.executeSql(sql);
              self.tables_info[table] = self.parse_table_columns(table, columns);
            }
          }, deferred);
        }
      });
    },

    get_data: function (tables, updated_at, deferred) {
      var self = this;
      var data = {};
      var data_present = false;

      if (updated_at)
        data['updated_at'] = updated_at === true ? new Date().toUTCString() : updated_at;
      if (tables)
        data['tables'] = tables;

      $.ajax({
        context: this,
        url: '/dashboard/local_data/',
        data: data,
        dataType: 'json',
        success: function(json) {
          if (json.settings)
            self.set_settings(json.settings);

          var new_tables;
          if (!tables)
            new_tables = $.grep(json.tables, function(table, i) {
              return $.inArray(table, self.tables) == -1 ? true : false;
            });
          else
            new_tables = false;

          if (new_tables && new_tables.length)
            self.create_tables(new_tables).done(function() {
              var data = {};
              for (var table in json.data) {
                if ($.inArray(table, new_tables) == -1)
                  data[table] = json.data[table];
              }
              var d1 = self.save_data(data);

              var d2 = self.get_data(new_tables, false);

              $.when(d1, d2).done(function() {
                deferred.resolve();
              }).fail(function() {
                deferred.reject();
              });
            });
          else
            self.save_data(json.data, deferred);
        },
        error: function(jqXHR, textStatus, errorThrown) {
          if (jqXHR.status == 200)
            self.error(textStatus);
          deferred.reject();
        }
      });
    },

    save_data: function(data, deferred) {
      var self = this;
      self.db.transaction(function(tx) {
        for (var table in data) {
          for (var i = 0; i < data[table].length; i++) {
            var obj = data[table][i];
            var fields = '';
            var values = '';

            for (var field in obj) {
              if (self.tables_info[table][field] && obj[field] !== '') {
                fields += field + ', ';
                values += self.cast_type(obj[field], table, field, true) + ', ';
              }
            }

            fields = '(' + fields.replace(/, $/, ')');
            values = '(' + values.replace(/, $/, ')');
            var sql = 'INSERT OR REPLACE INTO ' + table + ' ' + fields + ' VALUES ' + values;
            tx.executeSql(sql);
          }
        }
      }, function(err) {
        self.error(err);
        deferred.reject();
      }, function() {
        deferred.resolve();
      });
    },

    check_online: function(deferred) {
      var self = this;

      // Offline mode has been set explicitly
      if (window.tourism_offline)
        deferred.resolve(false);

      // In Chrome navigator.onLine property always is true
      else if ($.browser.webkit) {
        // Check connection by ajax-request
        $.ajax({
          url: '/dashboard/edit_company',
          success: function(data, textStatus, jqXHR) {
            deferred.resolve(true);
          },
          error: function(jqXHR, textStatus, errorThrown) {
            self.error(textStatus);
            deferred.resolve(false);
          }
        });

      // In a common case check navigator.onLine value
      } else
        deferred.resolve(window.navigator.onLine);
    },

    offline: function (path, deferred) {
      var route = this.route(path);
      if (!(route['table'] && route['action'])) {
        deferred.reject();
        return;
      }

      var res;

      if (this.actions[route['table']]) {
        var action = this.actions[route['table']][route['action']];
        if (typeof action == 'function')
          res = action(route['id'] || undefined);
      }

      if (!res) {
        deferred.reject();
        return;
      }

      var self = this;
      var view = res.view || route['action'];
      var template = route['table'] + '/' + view;

      if (typeof res == 'object' && res.done) { // deferred object
        res.done(function(data) {
          self.render(template, data);
          deferred.resolve();
        });
      } else if (res.sql && res.data) {
        this.transaction(function(tx) {
          tx.executeSql(res.sql, res.params || [], function (tx, results) {
            var data = res.data(results);
            self.render(template, data);
            deferred.resolve();
          });
        });
      } else {
        this.render(template, res);
        deferred.resolve();
      }
    }

  });

  Tourism.init = function() {
    // Check availability of offline site version
    if (!this.offline_available()) return;

    var self = this;

    // Check current mode
    self.check_online().done(function(online) {

      self.online = online;

      // Can use a local database
      if (self.init_db()) {

        // Online
        if (self.online) {

          // Check necessary information
          self.check_db().done(function() {
            // Get last data
            self.get_data(false, self.last_sync()).done(function() {
              // Update synchronization time
              self.set_last_sync();
            });
          });

          // Get offline site version one time a day
          // if ( self.different_days(self.last_cache_update(), new Date()) )
            self.get_offline_version();

        // Offline
        } else {

          // To avoid blinking of old content
          $(self.content_selector).css('visibility', 'hidden');

          // Show message about offline mode
          $('<div id="offline_text_box">Оффлайн режим</div>').appendTo(document.body);

          // Can use a local database
          if (self.init_db()) {
            self.check_db().done(function() {
              self.offline(location.pathname).always(function() {
                $(self.content_selector).css('visibility', 'visible');
              });
            });
          } else
            $(self.content_selector).css('visibility', 'visible');

        }
      }

    });
  };

  window.Tourism = Tourism;

})();

$(function() {
  // Tourism.init();
});