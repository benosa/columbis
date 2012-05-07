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

  function create_storage() {
    drop_table('tourism_claims');
    db.transaction(function(tx) {
      tx.executeSql('SELECT COUNT(*) FROM tourism_claims', [], function(result) { },
        function(tx, error) {
          tx.executeSql('CREATE TABLE tourism_claims (' + columns_info + ')');
      });
    });
  }

  create_storage();

  function fill_storage() {
    $.ajax({
      url: '/dashboard/claims/all/'
    });
  }

  fill_storage();
});
