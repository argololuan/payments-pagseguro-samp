<?php
    if(isset($_GET['code']))
    {
	$code = $_GET['code'];
	$email = "YOUR_EMAIL";
	$token = "YOUR_TOKEN";
	print file_get_contents("https://ws.pagseguro.uol.com.br/v2/transactions/".$code."?email=".$email."&token=".$token);
    }
?>
