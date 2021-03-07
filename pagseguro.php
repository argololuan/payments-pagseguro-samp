<?php
    if(isset($_GET['code']))
    {
	$code = $_GET['code'];
	$email = "ipsluan@icloud.com";
	$token = " ";
	print file_get_contents("https://ws.pagseguro.uol.com.br/v2/transactions/".$code."?email=".$email."&token=".$token);
    }
?>
