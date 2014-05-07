<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="shortcut icon" href="http://campus.mbs.net/mbsnow/home/docs-assets/ico/favicon.ico">

    <title>MBS Now, privacy</title>
    <link href="http://campus.mbs.net/mbsnow/home/dist/css/bootstrap.css" rel="stylesheet">

    <link href="http://campus.mbs.net/mbsnow/home/jumbotron-narrow.css" rel="stylesheet">

  </head>

  <body>
    <div class="container">
      <div class="header">
        <ul class="nav nav-pills pull-right">
          <li><a href="http://campus.mbs.net/mbsnow/home/index.php">Home</a></li>
          <li><a href="http://campus.mbs.net/mbsnow/home/forms">Forms</a></li>
          <li><a href="http://campus.mbs.net/mbsnow/home/clubs.php">Clubs</a></li>
          <li><a href="http://campus.mbs.net/mbsnow/home/code">Code</a></li>
          <li class="active"><a href="#">More</a></li>
        </ul>
        <h3 class="text-muted">MBS Now</h3>
      </div>
      <ol class="breadcrumb">
      	<li><a href="http://campus.mbs.net/mbsnow/home/">MBS Now home</a></li>
  		<li><a href="http://campus.mbs.net/mbsnow/home/meta/index.php">Meta home</a></li>
  		<li class="active><a href="#">Privacy</a></li>
		</ol>
      <h2>Privacy</h2>
		<p>Every 300 launches (250 in v3.0.9 and later), we automatically collect some numbers and strings concerning your usage. The information is completely unspecific (no names, emails, device names, IPs, locations, dates, etc.) and only about MBS Now.</p>
		<p>To send yourself your own current data, navigate to 'Data Uploads' from the home tab, and press 'View My Data'.<p>
		<ul>
			<li>Here are sample data: <pre>System name iPhone OS, version 7.0, model iPhone Simulator, height 480.00, width 320.00, forms tapped 9, offline tapped 2, menus tapped 17, contacts tapped 2, launches 200, version 2.4.6, sent before 0, MS grade 0, dress notifications 1, A/B notifications 1, General notifications 1, saved password 1, logins tapped 3, button color grey.</i></pre>
			<li>Here's what we collect:<div class="well well-sm">system name, version number, model, screen dimensions, current button color, forms tapped, offline schedules tapped, lunch menus tapped, contacts copied, launches, version of MBS Now, if you've sent before, if you're an MS student, if you are receiving notifications from MBS Now, if you have access to database credentials, database logins copied.</div></li>
		</ul>

	<p>Just to be clear, here's what you'll see in the app:</p>
	<img border="0" src="http://campus.mbs.net/mbsnow/home/code/screenshots/data.png" alt="data.png" width="320" height="480">
      <div class="footer">
        <?php $last_modified = filemtime("index.php"); print("Last modified "); print(date("m/j/y", $last_modified)); ?>
    </div>
  </body>
</html>