<?php

//Register page Database

if(isset($_POST['loginsubmit']))
{
    $pwd =$_POST['lpassword'];
    $email = $_POST['lemail'];

    // Connect to database
    $conn = mysqli_connect("localhost", "root", "", "users");
    
    // Check connection
    if (!$conn)
    {
        die("Connection failed: " . mysqli_connect_error());
    }
    
    // Check if username or email already exists
    $sql = "SELECT * FROM user_info WHERE email='$email' or  password='$pwd'";
    $result = mysqli_query($conn, $sql);
    
    if (mysqli_num_rows($result) > 0 ) 
    {
        // echo "Username or Email already exists";
        echo '<script src="login.js"></script>';
    }
    
    
}
?>
