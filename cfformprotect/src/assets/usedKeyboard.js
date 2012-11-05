var keysPressed = 0;
//capture when a user uses types on their keyboard
document.onkeypress = logKeys;

function logKeys() {
	//user hit a key, increment the counter
	keysPressed++;
	//load the amount to hidden form field
	try	{
		document.getElementById("formfield1234567892").value = keysPressed;
	}
	catch(excpt) { /* no action to take */ }
	try	{
		document.getElementById("formfield1234567892_a").value = keysPressed;
	}
	catch(excpt) { /* no action to take */ }
}