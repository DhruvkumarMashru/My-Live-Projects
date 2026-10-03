<?php
//Register page Database

if(isset($_POST['submit']))
{
    $uname = $_POST['username'];
    $pwd =$_POST['password'];
    $email = $_POST['email'];

    // Connect to database
    $conn = mysqli_connect("localhost", "root", "", "users");
    
    // Check connection
    if (!$conn)
    {
        die("Connection failed: " . mysqli_connect_error());
    }
    
    // Check if username or email already exists
    $sql = "SELECT * FROM user_info WHERE email='$email'";
    $result = mysqli_query($conn, $sql);
    
    if (mysqli_num_rows($result) > 0) 
    {
        // echo "Username or Email already exists";
        echo '<script src="register.js"></script>';
     }
     else
     {
         // Insert data into database
         $sql = "INSERT INTO user_info (email, username, password) VALUES ('$email', '$uname', '$pwd')";
  
         if (mysqli_query($conn, $sql))
         {
          echo '<script src="ll.js"></script>';
         } 
         else 
         {
             echo "Error: " . $sql . "<br>" . mysqli_error($conn);
         }
     }
    mysqli_close($conn);
  }
?>