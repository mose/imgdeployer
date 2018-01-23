
$(document).ready(function() {

  var started;
  var intervalId;

  function waitForState(code, callback) {
    intervalId = setInterval(function() {
      $.ajax({
        url: '/info',
        method: 'post'
      }).done(function(data) {
        if (data.state.code === code) {
          clearInterval(intervalId);
          $('#loader').hide();
          callback(data);
        } else {
          $('#message').append(' .');
        }
      })
    }, 2000);
  }

  function waitForOkStatus(callback) {
    intervalId = setInterval(function() {
      $.ajax({
        url: '/info',
        method: 'post'
      }).done(function(data) {
        // console.log(data);
        $('#instance-status').text(data.status.instance_status.status);
        $('#system-status').text(data.status.system_status.status);
        if (data.status.instance_status.status === 'ok' && data.status.system_status.status === 'ok') {
          clearInterval(intervalId);
          callback(data);
        }
      })
    }, 2000);
  }

  function hideAll() {
    $("#create, #start, #stop, #restart, #terminate, #status").hide();
  }

  function showStarted(data) {
    $('#message').text("Your wordpress instance is up and running on ");
    $('#message').append(
      '<a href="http://' + data.public_ip_address + '" ' +
      'class="btn btn-primary btn-xs" target="_new">' + 
      '<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span> ' +
      'http://' + data.public_ip_address + '</a>')
    hideAll();
    $("#stop, #restart, #terminate").show();
  }

  function showStatus(data) {
    $('#status').show();
    waitForOkStatus(showStarted);
  }

  function showStopped() {
    $('#message').text("Your wordpress instance is currently stopped.");
    hideAll();
    $("#start, #terminate").show();
  }

  function showTerminated() {
    $.ajax({
      url: '/forget',
      method: 'post'
    }).done(function(data) {
      $('#message').text("Your wordpress instance has been terminated like Sarah Connor.");
      hideAll();
      $("#create").show();
    });
  }


  // getting initial state
  $.ajax({
    url: '/info',
    method: 'post'
  }).done(function(data) {
    // console.log(data);
    if (data.no_instance) {
      $('#create').show();
      $('#message').text("You can create a Wordpress instance by clicking on that blue Create button just below.");
    } else if (data.error) {
      $('#create').show();
      $('#message').text(data.error);
    } else if (data.state.code === 16) { // started
      if (data.status.instance_status.status === 'ok' && data.status.system_status.status === 'ok') {
        $('#status').show();
        waitForOkStatus(showStarted);
      } else {
        showStarted(data);
      }
    } else {
      $('#message').text("Instance is created but stopped.");
      showStopped();
    }
  })


  // ---- buttons -----
  $('#create').on('click', function () {
    $.ajax({
      url: '/create',
      method: 'post'
    }).done(function(data) {
      if (data.error) {
        $('#message').text(data.error);
      } else {
        $('#message').html('<img id="loader" src="loader-small.gif" align="left" /> ' + data.message + ' ...');
        hideAll();
        waitForState(16, showStatus);
      }
    })
  })

  $('#start').on('click', function () {
    $.ajax({
      url: '/start',
      method: 'post'
    }).done(function(data) {
      if (data.error) {
        $('#message').text(data.error);
      } else {
        $('#message').html('<img id="loader" src="loader-small.gif" align="left" /> ' + data.message + ' ...');
        hideAll();
        waitForState(16, showStatus);
      }
    })
  })

  $('#stop').on('click', function () {
    $.ajax({
      url: '/stop',
      method: 'post'
    }).done(function(data) {
      if (data.error) {
        $('#message').text(data.error);
      } else {
        $('#message').html('<img id="loader" src="loader-small.gif" align="left" /> ' + data.message + ' ...');
        hideAll();
        waitForState(80, showStopped);
      }
    })
  })

  $('#restart').on('click', function () {
    $.ajax({
      url: '/restart',
      method: 'post'
    }).done(function(data) {
      if (data.error) {
        $('#message').text(data.error);
      } else {
        $('#message').html('<img id="loader" src="loader-small.gif" align="left" /> ' + data.message + ' ...');
        hideAll();
        waitForState(16, showStatus);
      }
    })
  })

  $('#terminate').on('click', function () {
    $.ajax({
      url: '/terminate',
      method: 'post'
    }).done(function(data) {
      if (data.error) {
        $('#message').text(data.error);
      } else {
        $('#message').html('<img id="loader" src="loader-small.gif" align="left" /> ' + data.message + ' ...');
        hideAll();
        waitForState(48, showTerminated);
      }
    })
  })

  // $('#forget').on('click', function () {
  //   showTerminated();
  // })

})
