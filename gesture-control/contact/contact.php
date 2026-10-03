
<?php
//Register page Database

if(isset($_POST['submited']))
{
    $uname = $_POST['name'];
    $email =$_POST['email'];
    $msg = $_POST['message'];

    // Connect to database
    $conn = mysqli_connect("localhost", "root", "", "users");
    
    // Check connection
    if (!$conn)
    {
        die("Connection failed: " . mysqli_connect_error());
    }
    
// Insert data into database
         $sql = "INSERT INTO contact (name,email, msg) VALUES ('$uname', '$email', '$msg')";
  
         if (mysqli_query($conn, $sql))
         {
          echo '<script src="ll.js"></script>';
         } 
         else 
         {
             echo "Error: " . $sql . "<br>" . mysqli_error($conn);
         }
     
    mysqli_close($conn);
  }
?>