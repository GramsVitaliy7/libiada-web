﻿$(function () {
    var scrolledUp = false;
    var scrolledDown = false;
    var savedPosition = 0;

    $('#buttonScrollDown').click(
    function (e) {
        if (scrolledDown) {
            $('html, body').animate({ scrollTop: savedPosition }, 800);
            scrolledDown = false;
            scrolledUp = false;
        } else {
            savedPosition = window.pageYOffset || document.documentElement.scrollTop;
            $('html, body').animate({ scrollTop: $('body').height() }, 800);
            scrolledDown = true;
        }
        
    }
    );
    $('#buttonScrollUp').click(
    function (e) {
        if (scrolledUp) {
            $('html, body').animate({ scrollTop: savedPosition }, 800);
            scrolledDown = false;
            scrolledUp = false;
        } else {
            savedPosition = window.pageYOffset || document.documentElement.scrollTop;
            $('html, body').animate({ scrollTop: '0px' }, 800);
            scrolledUp = true;
        }
        
    }
	);
	//mouseover
	var timeDelay = 10;
	var alphabet = ["f", "e", "c", "a", "8", "6", "4", "2", "0"];
	$('#buttonScrollUp').mouseover(
		function (e) {
			var color;
			var i=0;
			var DescriptorInterval = setInterval(function () {
				color = "#" + "f" + alphabet[i] + "f" + alphabet[i] + "f" + alphabet[i];
				document.getElementById('buttonScrollUp').style.backgroundColor = color;
				i++;
				if (i == alphabet.length) clearInterval(DescriptorInterval);
			}, timeDelay);
	}
	);
	$('#buttonScrollDown').mouseover(
		function (e) {
			var color;
			var i = 0;
			var DescriptorInterval = setInterval(function () {
				color = "#" + "f" + alphabet[i] + "f" + alphabet[i] + "f" + alphabet[i];
				document.getElementById('buttonScrollDown').style.backgroundColor = color;
				i++;
				if (i == alphabet.length) clearInterval(DescriptorInterval);
			}, timeDelay);
		}
	);
	//mouseout
	$('#buttonScrollUp').mouseout(
		function (e) {
			document.getElementById('buttonScrollUp').style.backgroundColor = "#fff";
		}
	);
	$('#buttonScrollDown').mouseout(
		function (e) {
			document.getElementById('buttonScrollDown').style.backgroundColor = "#fff";
		}
	);
	//hide scroll
	if (document.body.clientHeight - document.documentElement.clientHeight <= 0) {
		document.getElementById('scrollUpDown').setAttribute("hidden", true);
	}
	else {
		document.getElementById('scrollUpDown').removeAttribute("hidden");
	}
});
