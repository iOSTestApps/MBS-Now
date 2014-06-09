<?php
	$jd=cal_to_jd(CAL_GREGORIAN,date("m"),date("d"),date("Y"));
	$day=(jddayofweek($jd,1));
	$url = 'http://campus.mbs.net/mbsnow/home/forms/lunch' . $day . '.pdf';
	header( 'Location: '. $url )
?>
